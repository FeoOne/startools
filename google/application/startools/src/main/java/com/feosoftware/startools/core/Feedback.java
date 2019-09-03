package com.feosoftware.startools.core;

import org.json.JSONObject;

public interface Feedback {
    void onResponse(JSONObject response);
}
