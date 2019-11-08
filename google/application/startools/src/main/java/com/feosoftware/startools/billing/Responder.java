package com.feosoftware.startools.billing;

import android.util.Log;
import android.support.annotation.Nullable;

import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingResult;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Collection;

final class Responder {
    private static final String TAG = "BillingResponder";

    // shared
    private static final String CODE_KEY = "Code";
    private static final String MESSAGE_KEY = "Message";
    private static final String IDENTIFIER_KEY = "Identifier";

    // product
    private static final String LOCALIZED_DESCRIPTION_KEY = "LocalizedDescription";
    private static final String LOCALIZED_TITLE_KEY = "LocalizedTitle";
    private static final String LOCALIZED_PRICE_KEY = "LocalizedPrice";
    private static final String CURRENCY_CODE_KEY = "CurrencyCode";
    private static final String PRICE_KEY = "Price";

    // launch success
    private static final String PRODUCTS_KEY = "Products";

    // purchase failed
    private static final String ISCANCELLED_KEY = "IsCancelled";

    static JSONObject buildLaunchSucceededResponse(@Nullable Collection<Product> products) {
        JSONObject response = null;

        try {
            JSONArray array = new JSONArray();

            if (products != null) {
                for (Product product : products) {
                    if (product.getDetails() == null) {
                        continue;
                    }

                    JSONObject obj = new JSONObject();

                    obj.put(IDENTIFIER_KEY, product.getIdentifier());
                    obj.put(LOCALIZED_DESCRIPTION_KEY, product.getDetails().getDescription());
                    obj.put(LOCALIZED_TITLE_KEY, product.getDetails().getTitle());
                    obj.put(LOCALIZED_PRICE_KEY, product.getDetails().getOriginalPrice());
                    obj.put(CURRENCY_CODE_KEY, product.getDetails().getPriceCurrencyCode());
                    obj.put(PRICE_KEY, (float) product.getDetails().getOriginalPriceAmountMicros() / 1000000.0f);

                    array.put(obj);
                }
            }

            response = new JSONObject();

            response.put(PRODUCTS_KEY, array);
        }
        catch (JSONException e) {
            Log.e(TAG, "Can't buildLaunchSucceededResponse: " + e.getMessage());
        }

        return response;
    }

    static JSONObject buildLaunchFailedResponse(BillingResult billingResult) {
        JSONObject response = null;

        try {
            response = new JSONObject();

            response.put(CODE_KEY, billingResult.getResponseCode());
            response.put(MESSAGE_KEY, billingResult.getDebugMessage());
        }
        catch (JSONException e) {
            Log.e(TAG, "Can't buildLaunchFailedResponse: " + e.getMessage());
        }

        return response;
    }

    static JSONObject buildPurchaseSucceededResponse(String identifier) {
        JSONObject response = null;

        try {
            response = new JSONObject();

            response.put(IDENTIFIER_KEY, identifier);
        }
        catch (JSONException e) {
            Log.e(TAG, "Can't buildPurchaseSucceededResponse: " + e.getMessage());
        }

        return response;
    }

    static JSONObject buildPurchaseFailedResponse(BillingResult billingResult) {
        JSONObject response = null;

        try {
            response = new JSONObject();

            response.put(CODE_KEY, billingResult.getResponseCode());
            response.put(MESSAGE_KEY, billingResult.getDebugMessage());
            response.put(ISCANCELLED_KEY,
                    billingResult.getResponseCode() == BillingClient.BillingResponseCode.USER_CANCELED);
        }
        catch (JSONException e) {
            Log.e(TAG, "Can't buildPurchaseFailedResponse: " + e.getMessage());
        }

        return response;
    }
}
