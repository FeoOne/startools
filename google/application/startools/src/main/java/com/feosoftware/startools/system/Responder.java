package com.feosoftware.startools.system;

import android.util.Log;

import org.json.JSONObject;
import org.json.JSONException;

final class Responder {
    private static final String TAG = "NetworkResponder";

    private static final String IS_CONNECTED_KEY = "Code";

    static JSONObject buildNetworkStateChangedResponse(boolean isConnected) {
        JSONObject response = null;

        try {
            response = new JSONObject();

            response.put(IS_CONNECTED_KEY, isConnected);
        }
        catch (JSONException e) {
            Log.e(TAG, "Can't buildNetworkStateChangedResponse: " + e.getMessage());
        }

        return response;
    }

}
