package com.feosoftware.startools.system;

import android.util.Log;

import com.feosoftware.startools.core.Journal;

import org.json.JSONObject;
import org.json.JSONException;

final class Responder {
    private static final String CATEGORY = "NetworkResponder";

    private static final String IS_CONNECTED_KEY = "IsConnected";

    static JSONObject buildNetworkStateChangedResponse(boolean isConnected) {
        JSONObject response = null;

        try {
            response = new JSONObject();

            response.put(IS_CONNECTED_KEY, isConnected);
        }
        catch (JSONException e) {
            Journal.e(CATEGORY, "Can't buildNetworkStateChangedResponse: " + e.getMessage());
        }

        return response;
    }

}
