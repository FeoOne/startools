package com.feosoftware.startools.core;

import android.os.Handler;

import com.feosoftware.startools.system.NetworkListener;

public final class Core {
    private static Handler _mainThreadHandler;
    private static MessageCenter _messageCenter;

    public static void setup() {
        if (_mainThreadHandler == null) {
            _mainThreadHandler = new Handler();
        }

        NetworkListener.setup();
    }

    public static void registerMessageCenterHandler(MessageCenter messageCenterHandler) {
        _messageCenter = messageCenterHandler;
    }

    public static void runOnMainThread(Runnable runnable) {
        if (_mainThreadHandler != null && runnable != null) {
            _mainThreadHandler.post(runnable);
        }
    }

    public static void sendMessageToManaged(final String message, final String data) {
        runOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (_messageCenter != null) {
                    _messageCenter.onMessage(message, data);
                }
            }
        });
    }
}
