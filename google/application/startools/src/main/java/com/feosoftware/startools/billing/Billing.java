package com.feosoftware.startools.billing;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;
import android.support.annotation.Nullable;

import com.android.billingclient.api.AcknowledgePurchaseParams;
import com.android.billingclient.api.AcknowledgePurchaseResponseListener;
import com.android.billingclient.api.BillingClient;

import java.util.AbstractMap;
import java.util.AbstractSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;

import com.android.billingclient.api.BillingClientStateListener;
import com.android.billingclient.api.BillingFlowParams;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.ConsumeParams;
import com.android.billingclient.api.ConsumeResponseListener;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.PurchaseHistoryRecord;
import com.android.billingclient.api.PurchaseHistoryResponseListener;
import com.android.billingclient.api.PurchasesUpdatedListener;
import com.android.billingclient.api.SkuDetails;
import com.android.billingclient.api.SkuDetailsParams;
import com.android.billingclient.api.SkuDetailsResponseListener;

import com.feosoftware.startools.core.FeedbackHelper;
import com.feosoftware.startools.core.Journal;
import com.feosoftware.startools.system.NetworkListener;

import com.unity3d.player.UnityPlayer;

public final class Billing implements
        PurchasesUpdatedListener,
        BillingClientStateListener,
        SkuDetailsResponseListener,
        ConsumeResponseListener,
        AcknowledgePurchaseResponseListener,
        PurchaseHistoryResponseListener,
        Application.ActivityLifecycleCallbacks,
        NetworkListener.INetworkListenerListener
{
    private static final String CATEGORY = "Billing";

    private static final int NOT_LAUNCHED_LAUNCH_STATE = 0;
    private static final int LAUNCHING_LAUNCH_STATE = 1;
    private static final int LAUNCHED_LAUNCH_STATE = 2;

    private BillingClient _billingClient;

    private int _state;
    private AbstractMap<String, Product> _products;
    private AbstractMap<String, String> _pendingProducts;
    private AbstractSet<String> _purchasedTokens;

    /**
     * Ctor
     */

    public Billing()
    {
        _state = NOT_LAUNCHED_LAUNCH_STATE;

        _products = new HashMap<>(32);
        _pendingProducts = new HashMap<>(4);
        _purchasedTokens = new HashSet<>();

        _billingClient = BillingClient.newBuilder(UnityPlayer.currentActivity)
                .enablePendingPurchases()
                .setListener(this)
                .build();

        NetworkListener.addListener(this);

        UnityPlayer.currentActivity.getApplication().registerActivityLifecycleCallbacks(this); // todo: refactor

        Journal.i(CATEGORY, "Billing initialized.");
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
            Journal.w(CATEGORY, "Billing already launched.");
            return;
        }

        Product product = _products.get(identifier);
        if (product == null) {
            product = new Product(identifier, type);
            _products.put(identifier, product);

            Journal.i(CATEGORY, "Added product identifier '" + identifier + "'");
        } else {
            Journal.w(CATEGORY, "Product '" + identifier + "' already added.");
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
            Journal.e(CATEGORY, "Billing already launched.");
            return;
        }

        Journal.i(CATEGORY, "Launch started...");

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
            Journal.e(CATEGORY, "Billing not launched.");
            return;
        }

        Journal.i(CATEGORY, "Purchasing '" + identifier + "'.");

        Product product = _products.get(identifier);
        if (product == null) {
            Journal.e(CATEGORY, "Can't purchase unavailable product.");
            return;
        }

        BillingFlowParams params = BillingFlowParams.newBuilder()
                .setSkuDetails(product.getDetails())
                .build();
        BillingResult billingResult = _billingClient.launchBillingFlow(UnityPlayer.currentActivity, params);

        Journal.i(CATEGORY, "Billing flow launch result: " + billingResult.getResponseCode() + ".");
    }

    public void restorePurchases() {
        synchronized (this) {
            _restorePurchases();
        }
    }

    private void _restorePurchases() {
        _billingClient.queryPurchaseHistoryAsync(BillingClient.SkuType.INAPP, this);
    }

    public void consumePendingPurchase(String token) {
        synchronized (this) {
            _consumePendingPurchase(token);
        }
    }

    private void _consumePendingPurchase(String token) {
        String sku = _pendingProducts.get(token);
        if (sku != null) {
            Journal.i(CATEGORY, "Consuming purchase " + sku);

            ConsumeParams params = ConsumeParams.newBuilder()
                    .setPurchaseToken(token)
                    .build();
            _billingClient.consumeAsync(params, this);
        }
    }

    /**
     * Private
     */

    private void onLaunchSucceeded() {
        Journal.i(CATEGORY, "Launch succeeded. Querying products.");

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
        FeedbackHelper.sendFeedback(FeedbackHelper.LAUNCH_FAILED_KEY,
                Responder.buildLaunchFailedResponse(billingResult));

        _state = NOT_LAUNCHED_LAUNCH_STATE;
    }

    private void onPurchaseSucceeded(String identifier) {
        FeedbackHelper.sendFeedback(FeedbackHelper.PURCHASE_SUCCEEDED_KEY,
                Responder.buildPurchaseSucceededResponse(identifier));
    }

    private void onPurchaseFailed(BillingResult billingResult) {
        FeedbackHelper.sendFeedback(FeedbackHelper.PURCHASE_FAILED_KEY,
                Responder.buildPurchaseFailedResponse(billingResult));
    }

    private void handlePurchase(Purchase purchase) {
        Journal.i(CATEGORY, "Handling purchase for '"
                + purchase.getSku() + "' with state '"
                + purchase.getPurchaseState() + "'.");

        switch (purchase.getPurchaseState()) {
            case Purchase.PurchaseState.PURCHASED: {
                Product product = _products.get(purchase.getSku());
                if (product != null) {
                    switch (product.getType()) {
                        case Product.CONSUMABLE_TYPE: {
                            consumePurchase(purchase);
                            break;
                        }
                        case Product.NONCONSUMABLE_TYPE: {
                            if (!purchase.isAcknowledged()) {
                                acknowledgePurchase(purchase);
                            }
                            break;
                        }
                        default: {
                            Journal.e(CATEGORY, "Not implemented.");
                            // todo: implement
                        }
                    }
                } else {
                    Journal.e(CATEGORY, "Fatal error: purchasing product not presented.");
                    // todo: maybe we need notify client for unlock interface
                }

                break;
            }
            case Purchase.PurchaseState.PENDING: {
                Journal.i(CATEGORY, "Pending purchase.");
                // todo: maybe we need notify client for unlock interface

                break;
            }
            case Purchase.PurchaseState.UNSPECIFIED_STATE: {
                Journal.e(CATEGORY, "UNSPECIFIED_STATE purchase state.");
                // todo: maybe we need notify client for unlock interface

                break;
            }
        }
    }

    private void consumePurchase(Purchase purchase) {
        Journal.i(CATEGORY, "Pending purchase " + purchase.getSku());

        Product product = _products.get(purchase.getSku());
        if (product != null) {
            FeedbackHelper.sendFeedback(FeedbackHelper.PURCHASE_PENDING_KEY,
                    Responder.buildPurchasePendingResponse(purchase, product));

            _pendingProducts.put(purchase.getPurchaseToken(), purchase.getSku());
        }
    }

    private void acknowledgePurchase(Purchase purchase) {
        AcknowledgePurchaseParams params = AcknowledgePurchaseParams.newBuilder()
                .setPurchaseToken(purchase.getPurchaseToken())
                .build();
        _billingClient.acknowledgePurchase(params, this);

        onPurchaseSucceeded(purchase.getSku());
    }

    private void queryPurchases() {
        Journal.i(CATEGORY, "Querying purchases.");

        Purchase.PurchasesResult queryPurchasesResult = _billingClient.queryPurchases(BillingClient.SkuType.INAPP);
        Journal.i(CATEGORY, "Querying purchases result: " + queryPurchasesResult.getResponseCode());

//        List<Purchase> purchases = queryPurchasesResult.getPurchasesList();
//        if (purchases != null) {
//            for (Purchase purchase: purchases) {
//                if (!_purchasedTokens.contains(purchase.getPurchaseToken()) &&
//                    !_pendingProducts.containsKey(purchase.getPurchaseToken())) {
//                    handlePurchase(purchase);
//                }
//            }
//        }

        // todo: SkuType.SUBS
    }

    /**
     * PurchasesUpdatedListener overrides
     */

    @Override
    public void onPurchasesUpdated(BillingResult billingResult, @Nullable List<Purchase> purchases) {
        switch (billingResult.getResponseCode()) {
            case BillingClient.BillingResponseCode.OK:
            case BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED: {
                if (purchases != null) {
                    for (Purchase purchase: purchases) {
                        handlePurchase(purchase);
                    }
                } else {
                    Journal.e(CATEGORY, "OnPurchasesUpdated: Internal error (purchases = null).");
                    onPurchaseFailed(billingResult);
                }
                break;
            }
            default: {
                Journal.e(CATEGORY, "OnPurchasesUpdated: Purchase failed: " + billingResult.getResponseCode());
                onPurchaseFailed(billingResult);
            }
        }


        // todo: ALREADY_OWNED - query purchases?
        // todo: internet interruption
    }

    /**
     * BillingClientStateListener overrides
     */

    @Override
    public void onBillingSetupFinished(BillingResult billingResult) {
        if (billingResult.getResponseCode() != BillingClient.BillingResponseCode.OK) {
            Journal.e(CATEGORY, "Failed to launch billing.");

            onLaunchFailed(billingResult);

            return;
        }

        onLaunchSucceeded();
    }

    @Override
    public void onBillingServiceDisconnected() {
        Journal.w(CATEGORY, "Billing service connection was lost. ");
    }

    /**
     * SkuDetailsResponseListener overrides
     */

    @Override
    public void onSkuDetailsResponse(BillingResult billingResult, List<SkuDetails> skuDetailsList) {
        if (billingResult.getResponseCode() != BillingClient.BillingResponseCode.OK) {
            Journal.e(CATEGORY, "Failed to querying products (" + billingResult.getResponseCode() + ").");

            onLaunchFailed(billingResult);

            return;
        }

        Journal.i(CATEGORY, "Products queried succeeesfully.");

        // fill products
        if (skuDetailsList != null) {
            Journal.i(CATEGORY, "Queried product count: " + skuDetailsList.size());

            for (SkuDetails details: skuDetailsList) {
                Product product = _products.get(details.getSku());
                if (product != null) {
                    product.setDetails(details);
                }
            }
        }

        // respond
        FeedbackHelper.sendFeedback(FeedbackHelper.LAUNCH_SUCCEEDED_KEY,
                Responder.buildLaunchSucceededResponse(_products.values()));

        _state = LAUNCHED_LAUNCH_STATE;

        Journal.i(CATEGORY, "Billing launched.");

        queryPurchases();
    }

    /**
     * ConsumeResponseListener overrides
     */

    @Override
    public void onConsumeResponse(BillingResult billingResult, String purchaseToken) {
        String identifier = _pendingProducts.get(purchaseToken);

        if (billingResult.getResponseCode() != BillingClient.BillingResponseCode.OK) {
            Journal.e(CATEGORY, "[onConsumeResponse] Purchase failed: " + billingResult.getResponseCode());

            onPurchaseFailed(billingResult);

            if (identifier != null) {
                _pendingProducts.remove(purchaseToken);
            }

            return;
        }

        Journal.i(CATEGORY, "[onConsumeResponse] Consuming purchase " + identifier);

        if (identifier == null) {
            Journal.e(CATEGORY, "[onConsumeResponse] Identifier not presented but purchases succeeded. Token '"
                    + purchaseToken + "'.");

            onPurchaseFailed(billingResult);

            return;
        }

        _pendingProducts.remove(purchaseToken);
        _purchasedTokens.add(purchaseToken);

        onPurchaseSucceeded(identifier);
    }

    /**
     * AcknowledgePurchaseResponseListener overrides
     */

    @Override
    public void onAcknowledgePurchaseResponse(BillingResult billingResult) {
        Journal.i(CATEGORY, "Purchase acknowledgement result: " + billingResult.getResponseCode() + ".");
    }

    /**
     * PurchaseHistoryResponseListener overrides
     */

    @Override
    public void onPurchaseHistoryResponse(BillingResult billingResult,
                                          List<PurchaseHistoryRecord> purchaseHistoryRecordList) {
        if (billingResult.getResponseCode() == BillingClient.BillingResponseCode.OK) {
            if (purchaseHistoryRecordList != null) {
                for (PurchaseHistoryRecord record: purchaseHistoryRecordList) {
                    Journal.i(CATEGORY, "PurchaseHistoryRecord: " + record.getSku());

                    if (_products.containsKey(record.getSku())) {
                        Product product = _products.get(record.getSku());
                        if (product != null && product.getType() == Product.NONCONSUMABLE_TYPE) {
                            onPurchaseSucceeded(record.getSku());
                        }
                    } else {
                        Journal.i(CATEGORY, "Product not presented...");
                    }
                }
            }
        } else {
            Journal.e(CATEGORY, "Purchase history response error: " + billingResult.getResponseCode() + ".");
        }
    }

    /**
     * Application.ActivityLifecycleCallbacks
     */

    @Override
    public void onActivityCreated(Activity activity, Bundle savedInstanceState) { }

    @Override
    public void onActivityDestroyed(Activity activity) { }

    @Override
    public void onActivitySaveInstanceState(Activity activity, Bundle outState) { }

    @Override
    public void onActivityStarted(Activity activity) {
        if (activity != UnityPlayer.currentActivity) {
            return;
        }

        NetworkListener.start();
    }

    @Override
    public void onActivityStopped(Activity activity) {
        if (activity != UnityPlayer.currentActivity) {
            return;
        }

        NetworkListener.stop();
    }

    @Override
    public void onActivityResumed(Activity activity) {
        if (activity != UnityPlayer.currentActivity) {
            return;
        }

        Journal.i(CATEGORY, "onActivityResumed");

        NetworkListener.start();

        if (_state == LAUNCHED_LAUNCH_STATE) {
            queryPurchases();
        }
    }

    @Override
    public void onActivityPaused(Activity activity) {
        if (activity != UnityPlayer.currentActivity) {
            return;
        }

        NetworkListener.stop();
    }

    /**
     * NetworkListener.Handler
     */

    @Override
    public void onStateChanged(boolean isConnected) {
        if (isConnected && _state == LAUNCHED_LAUNCH_STATE) {
            queryPurchases();
        }
    }
}
