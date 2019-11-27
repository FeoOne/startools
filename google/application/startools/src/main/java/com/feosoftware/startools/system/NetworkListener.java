package com.feosoftware.startools.system;

import com.feosoftware.startools.core.FeedbackHelper;

import java.io.IOException;
import java.net.Socket;
import java.net.InetSocketAddress;
import java.util.Timer;
import java.util.TimerTask;

public final class NetworkListener {
    private static Timer _timer;
    private static boolean _isConnected;

    public static void start() {
        if (_timer != null) {
            return;
        }

        _isConnected = true;

        _timer = new Timer();
        _timer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                boolean isConnected = isConnected();
                if (_isConnected != isConnected) {
                    _isConnected = isConnected;

                    FeedbackHelper.sendFeedback(FeedbackHelper.NETWORK_STATE_CHANGED_KEY,
                            Responder.buildNetworkStateChangedResponse(isConnected));
                }
            }
        }, 0, 1100);
    }

    public static void stop() {
        if (_timer == null) {
            return;
        }

        _timer.cancel();
        _timer.purge();

        _timer = null;
    }

    private static boolean isConnected() {
        try {
            Socket socket = new Socket();
            socket.connect(new InetSocketAddress("8.8.8.8", 53), 1000);
            socket.close();

            return true;
        }
        catch (IOException e) {
            return false;
        }
    }
}
