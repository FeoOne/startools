package com.feosoftware.startools.billing;

import android.util.Log;
import android.util.SparseArray;
import android.support.annotation.Nullable;

import com.android.billingclient.api.BillingClient;

import java.util.AbstractMap;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import com.android.billingclient.api.BillingClientStateListener;
import com.android.billingclient.api.BillingFlowParams;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.ConsumeParams;
import com.android.billingclient.api.ConsumeResponseListener;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.PurchasesUpdatedListener;
import com.android.billingclient.api.SkuDetails;
import com.android.billingclient.api.SkuDetailsParams;
import com.android.billingclient.api.SkuDetailsResponseListener;
import com.unity3d.player.UnityPlayer;

import org.json.JSONException;

import com.feosoftware.startools.core.Feedback;

public final class Billing implements
        PurchasesUpdatedListener,
        BillingClientStateListener,
        SkuDetailsResponseListener,
        ConsumeResponseListener
{
    private static final String TAG = "Billing";

    private static final int NOT_LAUNCHED_LAUNCH_STATE = 0;
    private static final int LAUNCHING_LAUNCH_STATE = 1;
    private static final int LAUNCHED_LAUNCH_STATE = 2;

    private static final int LAUNCH_SUCCEEDED_FEEDBACK_KEY = 0;
    private static final int LAUNCH_FAILED_FEEDBACK_KEY = 1;
    private static final int PURCHASE_SUCCEEDED_FEEDBACK_KEY = 2;
    private static final int PURCHASE_RESTORED_FEEDBACK_KEY = 3;
    private static final int PURCHASE_FAILED_FEEDBACK_KEY = 4;

    private BillingClient _billingClient;

    private int _state;
    private SparseArray<Feedback> _feedbacks;
    private AbstractMap<String, Product> _products;
    private AbstractMap<String, String> _pendingProducts;

    /**
     * Ctor
     */

    public Billing()
    {
        _state = NOT_LAUNCHED_LAUNCH_STATE;

        _feedbacks = new SparseArray<>(5);
        _products = new HashMap<>(32);
        _pendingProducts = new HashMap<>(4);

        _billingClient = BillingClient.newBuilder(UnityPlayer.currentActivity)
                .enablePendingPurchases()
                .setListener(this)
                .build();

        Log.i(TAG, "Billing initialized.");
    }

    /**
     * Feedback
     */

    public void registerFeedback(int key, Feedback feedback) {
        synchronized (this) {
            _registerFeedback(key, feedback);
        }
    }

    private void _registerFeedback(int key, Feedback feedback) {
        _feedbacks.put(key, feedback);
    }

    /**
     * Facade
     */

    public void registerProduct(String identifier, int type) {
        synchronized (this) {
            _registerProduct(identifier, type);
        }
    }

    private void _registerProduct(String identifier, int type) {
        if (_state != NOT_LAUNCHED_LAUNCH_STATE) {
            Log.w(TAG, "Billing launched. Late to drink borjomi.");
            return;
        }

        Product product = _products.get(identifier);
        if (product == null) {
            product = new Product(identifier, type);
            _products.put(identifier, product);

            Log.i(TAG, "Added product identifier '" + identifier + "'");
        } else {
            Log.w(TAG, "Product '" + identifier + "' already added.");
        }
    }

    public void launch() {
        synchronized (this) {
            _launch();
        }
    }

    private void _launch()
    {
        if (_state != NOT_LAUNCHED_LAUNCH_STATE) {
            Log.e(TAG, "Billing already launched.");
            return;
        }

        Log.i(TAG, "Launch started...");

        _state = LAUNCHING_LAUNCH_STATE;

        _billingClient.startConnection(this);
    }

    public void purchase(String identifier) {
        synchronized (this) {
            _purchase(identifier);
        }
    }

    private void _purchase(String identifier) {
        if (_state != LAUNCHED_LAUNCH_STATE) {
            Log.e(TAG, "Billing not launched.");
            return;
        }

        Log.i(TAG, "Purchasing '" + identifier + "'.");

        Product product = _products.get(identifier);
        if (product == null) {
            Log.e(TAG, "Can't purchase unavailable product.");
            return;
        }

        BillingFlowParams params = BillingFlowParams.newBuilder()
                .setSkuDetails(product.getDetails())
                .build();
        BillingResult billingResult = _billingClient.launchBillingFlow(UnityPlayer.currentActivity, params);

        Log.i(TAG, "Billing flow result: " + billingResult.getResponseCode() + ".");
    }

    /**
     * Private
     */

    private void onLaunchSucceeded() {
        Log.i(TAG, "Launch succeeded. Querying products.");

        List<String> skuList = new ArrayList<>();
        for (Product product: _products.values()) {
            int type = product.getType();
            if ((type & (Product.CONSUMABLE_TYPE | Product.NONCONSUMABLE_TYPE)) == type) {
                skuList.add(product.getIdentifier());
            }
        }

        SkuDetailsParams params = SkuDetailsParams.newBuilder()
                .setSkusList(skuList)
                .setType(BillingClient.SkuType.INAPP)
                .build();
        _billingClient.querySkuDetailsAsync(params, this);

        // todo: manage SkuType.SUBS
    }

    private void onLaunchFailed(BillingResult billingResult) {
        Feedback feedback = _feedbacks.get(LAUNCH_FAILED_FEEDBACK_KEY);
        if (feedback != null) {
            try {
                feedback.onResponse(Responder.buildLaunchFailedResponse(billingResult));
            }
            catch (JSONException e) {
                Log.e(TAG, "Can't respond: " + e.getMessage());
            }
        }

        _state = NOT_LAUNCHED_LAUNCH_STATE;
    }

    private void onPurchaseFailed(BillingResult billingResult) {
        Feedback feedback = _feedbacks.get(PURCHASE_FAILED_FEEDBACK_KEY);
        if (feedback != null) {
            try {
                feedback.onResponse(Responder.buildPurchaseFailedResponse(billingResult));
            }
            catch (JSONException e) {
                Log.e(TAG, "Can't respond: " + e.getMessage());
            }
        }
    }

    /**
     * PurchasesUpdatedListener overrides
     */

    @Override
    public void onPurchasesUpdated(BillingResult billingResult, @Nullable List<Purchase> purchases) {
        if (billingResult.getResponseCode() != BillingClient.BillingResponseCode.OK) {
            onPurchaseFailed(billingResult);

            return;
        }

        if (purchases != null) {
            for (Purchase purchase: purchases) {
                Log.i(TAG, "Handling purchase for '" + purchase.getSku() + "' with state '" + purchase.getPurchaseState() + "'.");

                if (purchase.getPurchaseState() == Purchase.PurchaseState.PURCHASED) {
                    _pendingProducts.put(purchase.getPurchaseToken(), purchase.getSku());

                    ConsumeParams params = ConsumeParams.newBuilder()
                            .setPurchaseToken(purchase.getPurchaseToken())
                            .build();
                    _billingClient.consumeAsync(params, this);
                }
            }
        } else {
            Log.w(TAG, "OnPurchasesUpdated internal error: purchases = null.");
        }
    }

    /**
     * BillingClientStateListener overrides
     */

    @Override
    public void onBillingSetupFinished(BillingResult billingResult) {
        if (billingResult.getResponseCode() != BillingClient.BillingResponseCode.OK) {
            Log.e(TAG, "Failed to launch billing.");

            onLaunchFailed(billingResult);

            return;
        }

        onLaunchSucceeded();
    }

    @Override
    public void onBillingServiceDisconnected() {
        Log.w(TAG, "Billing service connection was lost. ");
    }

    /**
     * SkuDetailsResponseListener overrides
     */

    @Override
    public void onSkuDetailsResponse(BillingResult billingResult, List<SkuDetails> skuDetailsList) {
        if (billingResult.getResponseCode() != BillingClient.BillingResponseCode.OK) {
            Log.e(TAG, "Failed to querying products.");

            onLaunchFailed(billingResult);

            return;
        }

        // fill products
        if (skuDetailsList != null) {
            for (SkuDetails details: skuDetailsList) {
                Product product = _products.get(details.getSku());
                if (product != null) {
                    product.setDetails(details);
                }
            }
        }

        // respond
        Feedback feedback = _feedbacks.get(LAUNCH_SUCCEEDED_FEEDBACK_KEY);
        if (feedback != null) {
            try {
                feedback.onResponse(Responder.buildLaunchSucceededResponse(_products.values()));
            }
            catch (JSONException e) {
                Log.e(TAG, "Can't respond: " + e.getMessage());
            }
        }

        _state = LAUNCHED_LAUNCH_STATE;
    }

    /**
     * ConsumeResponseListener overrides
     */

    @Override
    public void onConsumeResponse(BillingResult billingResult, String purchaseToken) {
        String identifier = _pendingProducts.get(purchaseToken);

        if (billingResult.getResponseCode() != BillingClient.BillingResponseCode.OK) {
            Log.e(TAG, "Purchase failed.");

            onPurchaseFailed(billingResult);

            if (identifier != null) {
                _pendingProducts.remove(identifier);
            }

            return;
        }

        if (identifier == null) {
            Log.e(TAG, "Identifier not presented but purchases succeeded. Token '" + purchaseToken + "'.");

            onPurchaseFailed(billingResult);

            return;
        }

        _pendingProducts.remove(identifier);

        Feedback feedback = _feedbacks.get(PURCHASE_SUCCEEDED_FEEDBACK_KEY);
        if (feedback != null) {
            try {
                feedback.onResponse(Responder.buildPurchaseSucceededResponse(identifier));
            }
            catch (JSONException e) {
                Log.e(TAG, "Can't respond: " + e.getMessage());
            }
        }
    }
}
