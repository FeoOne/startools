package com.feosoftware.startools.core;

import android.util.Log;

public class Journal {
    private static final String TAG = "StarTools";

    public static void i(String message) {
        Log.i(TAG, message);
    }

    public static void i(String category, String message) {
        Log.i(TAG, "[" + category + "] " + message);
    }

    public static void w(String message) {
        Log.w(TAG, message);
    }

    public static void w(String category, String message) {
        Log.w(TAG, "[" + category + "] " + message);
    }

    public static void e(String message) {
        Log.e(TAG, message);
    }

    public static void e(String category, String message) {
        Log.e(TAG, "[" + category + "] " + message);
    }
}
