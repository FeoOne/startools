package com.feosoftware.startools.system;

import android.app.Application;
import android.net.Network;
import android.net.NetworkRequest;
import android.os.Build;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.support.annotation.RequiresApi;
import android.util.Log;

import com.unity3d.player.UnityPlayer;

import java.util.LinkedList;
import java.util.List;

public final class NetworkListener extends BroadcastReceiver {
    public interface Handler {
        void onStateChanged(boolean isConnected);
    }

    private static final String TAG = "NetworkListener";

    private static final String CONNECTIVITY_ACTION = "com.feosoftware.startools.system.CONNECTIVITY_CHANGE";

    private static List<Handler> _handlers = new LinkedList<>();

    public static void registerHandler(Handler handler) {
        if (!_handlers.contains(handler)) {
            _handlers.add(handler);
        }
    }

    public static void unregisterHandler(Handler handler) {
        _handlers.remove(handler);
    }

    public static void setup() {
        IntentFilter filter = new IntentFilter();

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            createConnectivityMonitor();
            filter.addAction(CONNECTIVITY_ACTION);
        } else {
            filter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
        }

        NetworkListener broadcastReceiver = new NetworkListener();
        UnityPlayer.currentActivity.registerReceiver(broadcastReceiver, filter);

        Log.i(TAG, "Setup.");
    }

    @RequiresApi(Build.VERSION_CODES.N)
    private static void createConnectivityMonitor() {
        final Intent intent = new Intent(CONNECTIVITY_ACTION);
        final Application application = UnityPlayer.currentActivity.getApplication();

        ConnectivityManager connectivityManager =
                (ConnectivityManager)UnityPlayer.currentActivity.getSystemService(Context.CONNECTIVITY_SERVICE);

        if (connectivityManager != null) {
            connectivityManager.registerNetworkCallback(new NetworkRequest.Builder().build(),
                    new ConnectivityManager.NetworkCallback() {
                        @Override
                        public void onAvailable(Network network) {
                            application.sendBroadcast(intent);
                        }

                        @Override
                        public void onLost(Network network) {
                            application.sendBroadcast(intent);
                        }
                    });
        } else {
            Log.e(TAG, "Failed to create connectivity monitor (manager == null).");
        }
    }

    private boolean isConnected(Context context) {
        ConnectivityManager connectivityManager =
                (ConnectivityManager)context.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo activeNetwork = connectivityManager.getActiveNetworkInfo();

        return activeNetwork != null && activeNetwork.isConnected();
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        boolean flag = isConnected(context);

        Log.i(TAG, "State changed: " + flag);

        for (Handler handler: _handlers) {
            handler.onStateChanged(flag);
        }
    }
}
