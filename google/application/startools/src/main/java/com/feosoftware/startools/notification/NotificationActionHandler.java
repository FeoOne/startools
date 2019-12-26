package com.feosoftware.startools.notification;

import android.app.NotificationManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.unity3d.player.UnityPlayer;

public class NotificationActionHandler extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        int id = intent.getIntExtra("id", 0);
        String gameObject = intent.getStringExtra("gameObject");
        String handlerMethod = intent.getStringExtra("handlerMethod");
        String actionId = intent.getStringExtra("actionId");
        boolean foreground = intent.getBooleanExtra("foreground", true);

        NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.cancel(id);

        if (foreground) {
            Intent launchIntent = new Intent(context, UnityPlayer.currentActivity.getClass());
            launchIntent.setPackage(null);
            launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP);
            context.startActivity(launchIntent);
        }

        UnityPlayer.UnitySendMessage(gameObject, handlerMethod, actionId);
    }
}
