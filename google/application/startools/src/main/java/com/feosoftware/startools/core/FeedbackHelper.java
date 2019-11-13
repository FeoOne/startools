package com.feosoftware.startools.core;

import android.support.annotation.Nullable;
import android.util.SparseArray;

import org.json.JSONObject;

public class FeedbackHelper {
    public static final int LAUNCH_SUCCEEDED_KEY = 0;
    public static final int LAUNCH_FAILED_KEY = 1;
    public static final int PURCHASE_SUCCEEDED_KEY = 2;
    public static final int PURCHASE_RESTORED_KEY = 3;
    public static final int PURCHASE_FAILED_KEY = 4;
    public static final int NETWORK_STATE_CHANGED_KEY = 5;

    private static final SparseArray<Feedback> _feedbacks = new SparseArray<>(16);

    public static synchronized void registerFeedback(int key, Feedback feedback) {
        _feedbacks.put(key, feedback);
    }

    /**
     * Thread safe.
     * @param key
     * @param response
     */
    public static void sendFeedback(final int key, @Nullable final JSONObject response) {
        Core.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                Feedback feedback = _feedbacks.get(key);
                if (feedback != null) {
                    feedback.onResponse(response);
                }
            }
        });
    }
}
