package com.feosoftware.startools.system;

import com.feosoftware.startools.core.FeedbackHelper;
import com.feosoftware.startools.core.Journal;

import java.io.IOException;
import java.net.Socket;
import java.net.InetSocketAddress;
import java.util.AbstractSet;
import java.util.HashSet;
import java.util.Timer;
import java.util.TimerTask;

public final class NetworkListener {
    private static Timer _timer;
    private static boolean _isConnected;

    private static final int TIMER_PERIOD = 1000;
    private static final int TIMEOUT_INTERVAL = 600;

    public interface INetworkListenerListener {
         void onStateChanged(boolean isConnected);
    }

    private static AbstractSet<INetworkListenerListener> _listeners = new HashSet<>();

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

                    for (INetworkListenerListener listener: _listeners) {
                        listener.onStateChanged(isConnected);
                    }

                    FeedbackHelper.sendFeedback(FeedbackHelper.NETWORK_STATE_CHANGED_KEY,
                            Responder.buildNetworkStateChangedResponse(isConnected));
                }
            }
        }, 0, TIMER_PERIOD);
    }

    public static void stop() {
        if (_timer == null) {
            return;
        }

        _timer.cancel();
        _timer.purge();

        _timer = null;
    }

    public static void addListener(INetworkListenerListener listener) {
        if (!_listeners.contains(listener)) {
            _listeners.add(listener);
        } else {
            Journal.w("NetworkListener", "Listener already added.");
        }
    }

    public static void removeListener(INetworkListenerListener listener) {
        _listeners.remove(listener);
    }

    private static boolean isConnected() {
        try {
            Socket socket = new Socket();
            socket.connect(new InetSocketAddress("8.8.8.8", 53), TIMEOUT_INTERVAL);
            socket.close();

            return true;
        }
        catch (IOException e) {
            return false;
        }
    }
}
