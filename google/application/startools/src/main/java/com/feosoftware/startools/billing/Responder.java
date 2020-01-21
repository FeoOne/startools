package com.feosoftware.startools.billing;

import android.support.annotation.Nullable;

import com.android.billingclient.api.BillingClient;
import com.android.billingclient.api.BillingResult;
import com.android.billingclient.api.Purchase;
import com.feosoftware.startools.core.Journal;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Collection;

final class Responder {
    private static final String CATEGORY = "BillingResponder";

    // shared
    private static final String CODE_KEY = "Code";
    private static final String MESSAGE_KEY = "Message";
    private static final String IDENTIFIER_KEY = "Identifier";

    // purchase
    private static final String TOKEN_KEY = "Token";
    private static final String RECEIPT_KEY = "Receipt";
    private static final String SIGNATURE_KEY = "Signature";

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
                    obj.put(PRICE_KEY, (float)product.getDetails().getOriginalPriceAmountMicros() / 1000000.0f);

                    array.put(obj);
                }
            }

            response = new JSONObject();

            response.put(PRODUCTS_KEY, array);
        }
        catch (JSONException e) {
            Journal.e(CATEGORY, "Can't buildLaunchSucceededResponse: " + e.getMessage());
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
            Journal.e(CATEGORY, "Can't buildLaunchFailedResponse: " + e.getMessage());
        }

        return response;
    }

    static JSONObject buildPurchasePendingResponse(Purchase purchase, Product product) {
        JSONObject response = null;

        try {
            response = new JSONObject();

            response.put(TOKEN_KEY, purchase.getPurchaseToken());
            response.put(RECEIPT_KEY, purchase.getOriginalJson());
            response.put(SIGNATURE_KEY, purchase.getSignature());
            response.put(CURRENCY_CODE_KEY, product.getDetails().getPriceCurrencyCode());
            response.put(PRICE_KEY, (float)product.getDetails().getOriginalPriceAmountMicros() / 1000000.0f);
        }
        catch (JSONException e) {
            Journal.e(CATEGORY, "Can't buildPurchasePendingResponse: " + e.getMessage());
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
            Journal.e(CATEGORY, "Can't buildPurchaseSucceededResponse: " + e.getMessage());
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
            Journal.e(CATEGORY, "Can't buildPurchaseFailedResponse: " + e.getMessage());
        }

        return response;
    }
}
