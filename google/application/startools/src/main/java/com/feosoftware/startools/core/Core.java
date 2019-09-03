package com.feosoftware.startools.core;

import android.os.Handler;

public final class Core {
    private static Handler _mainThreadHandler;
    private static MessageCenter _messageCenter;

    /**
     * This method must be called from main thread.
     * This is achieved by `RuntimeInitializeOnLoadMethod` unity C# attribute.
     * Thats why we create main thread handler.
     * @param messageCenterHandler Managed class relation.
     */
    public static void RegisterMessageCenterHandler(MessageCenter messageCenterHandler) {
        _messageCenter = messageCenterHandler;

        if (_mainThreadHandler == null) {
            _mainThreadHandler = new Handler();
        }
    }

    public static void RunOnMainThread(Runnable runnable) {
        if (_mainThreadHandler != null && runnable != null) {
            _mainThreadHandler.post(runnable);
        }
    }

    public static void SendMessageToManaged(final String message, final String data) {
        RunOnMainThread(new Runnable() {
            @Override
            public void run() {
                if (_messageCenter != null) {
                    _messageCenter.onMessage(message, data);
                }
            }
        });
    }
}
