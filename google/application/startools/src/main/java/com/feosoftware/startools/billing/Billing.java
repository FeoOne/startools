package com.feosoftware.startools.billing;

import android.util.Log;
import android.support.annotation.Nullable;

import com.android.billingclient.api.BillingClient;

import java.util.AbstractMap;
import java.util.HashMap;
import java.util.List;
import java.util.Set;
import java.util.HashSet;

import com.android.billingclient.api.BillingClientStateListener;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.Purchase;
import com.android.billingclient.api.PurchasesUpdatedListener;
import com.unity3d.player.UnityPlayer;

import com.feosoftware.startools.FeedbackHandler;

import org.json.JSONException;
import org.json.JSONObject;

public final class Billing implements
        PurchasesUpdatedListener,
        BillingClientStateListener
{
    private static final String TAG = "Billing";



    private static final String LAUNCH_SUCCESS_KEY = "success";
    private static final String LAUNCH_FAIL_KEY = "fail";

    private Set<String> _identifiers = new HashSet<>();
    private AbstractMap<String, FeedbackHandler> _feedbacks = new HashMap<>();

    private BillingClient _billingClient;

    public Billing()
    {
        _billingClient = BillingClient.newBuilder(UnityPlayer.currentActivity)
                .enablePendingPurchases()
                .setListener(this)
                .build();
    }

    public void registerProduct(String identifier, int type)
    {
        if (_identifiers.add(identifier)) {
            Log.i(TAG, "Product '" + identifier + "' registered.");
        } else {
            Log.w(TAG, "Product '" + identifier + "' already registered.");
        }
    }

    public void launch(FeedbackHandler onSuccess, FeedbackHandler onFail)
    {
        if (_feedbacks.containsKey(LAUNCH_SUCCESS_KEY) || _feedbacks.containsKey(LAUNCH_FAIL_KEY)) {
            Log.e(TAG, "Launch already initiated. Ignoring request.");
            return;
        }

        _feedbacks.put(LAUNCH_SUCCESS_KEY, onSuccess);
        _feedbacks.put(LAUNCH_FAIL_KEY, onFail);

        Log.i(TAG, "Launch initiated...");

        _billingClient.startConnection(this);
    }

    private void launchSucceeded() {
        FeedbackHandler feedback = _feedbacks.get(LAUNCH_SUCCESS_KEY);
        if (feedback == null) {
            Log.e(TAG, "Fatal error. Can't find launch success feedback.");
            return;
        }



        launchFinalized();
    }

    private void launchFailed(BillingResult billingResult) {
        FeedbackHandler feedback = _feedbacks.get(LAUNCH_FAIL_KEY);
        if (feedback == null) {
            Log.e(TAG, "Fatal error. Can't find launch fail feedback.");
            return;
        }

        JSONObject response = new JSONObject();
        try {
            response.put("Code", billingResult.getResponseCode());
            response.put("Message", billingResult.getDebugMessage());
        }
        catch (JSONException exception) {
            Log.e(TAG, "Can't bake response json.");

            exception.printStackTrace();

            response = null;
        }

        feedback.onResponse(response);

        launchFinalized();
    }

    private void launchFinalized() {
        _feedbacks.remove(LAUNCH_SUCCESS_KEY);
        _feedbacks.remove(LAUNCH_FAIL_KEY);
    }

    /**
     * PurchasesUpdatedListener overrides
     */

    @Override
    public void onPurchasesUpdated(BillingResult billingResult, @Nullable List<Purchase> purchases) {
        switch (billingResult.getResponseCode()) {
            case BillingClient.BillingResponseCode.OK: {
                // todo
                break;
            }
            default: {
                // todo
            }
        }
    }

    /**
     * BillingClientStateListener overrides
     */

    @Override
    public void onBillingSetupFinished(BillingResult billingResult) {
        switch (billingResult.getResponseCode()) {
            case BillingClient.BillingResponseCode.OK: {
                launchSucceeded();
                break;
            }
            default: {
                launchFailed(billingResult);
            }
        }
    }

    @Override
    public void onBillingServiceDisconnected() {
        Log.w(TAG, "Billing service connection was lost. ");
    }
}
