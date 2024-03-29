package com.feosoftware.startools.notification;

import android.annotation.TargetApi;
import android.app.Activity;
import android.app.AlarmManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.PendingIntent;
import android.app.TaskStackBuilder;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.media.AudioAttributes;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.NotificationCompat;

import com.unity3d.player.UnityPlayer;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

public class NotificationManager extends BroadcastReceiver
{
    private static Set<String> channels = new HashSet<>();

    public static void createChannel(String identifier,
                                     String name,
                                     String description,
                                     int importance,
                                     String soundName,
                                     int enableLights,
                                     int lightColor,
                                     int enableVibration,
                                     long[] vibrationPattern,
                                     String bundle) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return;
        }

        channels.add(identifier);

        Activity activity = UnityPlayer.currentActivity;

        NotificationChannel channel = new NotificationChannel(identifier, name, importance);
        channel.setDescription(description);
        if (soundName != null) {
            Resources resources = activity.getResources();
            int id = resources.getIdentifier("raw/" + soundName,
                    null,
                    activity.getPackageName());
            AudioAttributes audioAttributes = new AudioAttributes
                    .Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build();
            channel.setSound(Uri.parse("android.resource://" + bundle + "/" + id), audioAttributes);
        }
        channel.enableLights(enableLights == 1);
        channel.setLightColor(lightColor);
        channel.enableVibration(enableVibration == 1);
        if (vibrationPattern == null) {
            vibrationPattern = new long[]{1000L, 1000L};
        }
        channel.setVibrationPattern(vibrationPattern);

        android.app.NotificationManager nm = (android.app.NotificationManager)activity
                .getSystemService(Context.NOTIFICATION_SERVICE);
        nm.createNotificationChannel(channel);
    }

    @TargetApi(24)
    private static void createChannelIfNeeded(String identifier,
                                              String name,
                                              String soundName,
                                              boolean enableLights,
                                              boolean enableVibration,
                                              String bundle) {
        if (channels.contains(identifier)) {
            return;
        }

        channels.add(identifier);

        createChannel(identifier,
                name,
                identifier + " notifications",
                android.app.NotificationManager.IMPORTANCE_DEFAULT,
                soundName,
                enableLights ? 1 : 0,
                Color.GREEN,
                enableVibration ? 1 : 0,
                null,
                bundle);
    }

    public static void setNotification(int id,
                                       long delayMs,
                                       String title,
                                       String message,
                                       String ticker,
                                       boolean enableSound,
                                       String soundName,
                                       boolean enableVibration,
                                       boolean enableLights,
                                       String largeIconResource,
                                       String smallIconResource,
                                       int bgColor,
                                       String bundle,
                                       String channel,
                                       ArrayList<NotificationAction> actions)
    {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            if (channel == null) {
                channel = "default";
            }

            createChannelIfNeeded(channel, title, soundName, enableLights, enableVibration, bundle);
        }

        Activity activity = UnityPlayer.currentActivity;

        Intent intent = new Intent(activity, NotificationManager.class);
        intent.putExtra("ticker", ticker);
        intent.putExtra("title", title);
        intent.putExtra("message", message);
        intent.putExtra("id", id);
        intent.putExtra("color", bgColor);
        intent.putExtra("sound", enableSound);
        intent.putExtra("soundName", soundName);
        intent.putExtra("vibrate", enableVibration);
        intent.putExtra("lights", enableLights);
        intent.putExtra("l_icon", largeIconResource);
        intent.putExtra("s_icon", smallIconResource);
        intent.putExtra("bundle", bundle);
        intent.putExtra("channel", channel);

        Bundle b = new Bundle();
        b.putParcelableArrayList("actions", actions);

        intent.putExtra("actionsBundle", b);

        AlarmManager am = (AlarmManager)activity.getSystemService(Context.ALARM_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            am.setExact(AlarmManager.RTC_WAKEUP,
                    System.currentTimeMillis() + delayMs,
                    PendingIntent.getBroadcast(activity, id, intent, PendingIntent.FLAG_UPDATE_CURRENT));
        } else {
            am.set(AlarmManager.RTC_WAKEUP,
                    System.currentTimeMillis() + delayMs,
                    PendingIntent.getBroadcast(activity, id, intent, PendingIntent.FLAG_UPDATE_CURRENT));
        }
    }

    public static void setRepeatingNotification(int id,
                                                long delayMs,
                                                String title,
                                                String message,
                                                String ticker,
                                                long rep,
                                                boolean enableSound,
                                                String soundName,
                                                boolean enableVibration,
                                                boolean enableLights,
                                                String largeIconResource,
                                                String smallIconResource,
                                                int bgColor,
                                                String bundle,
                                                String channel,
                                                ArrayList<NotificationAction> actions)
    {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            if (channel == null) {
                channel = "default";
            }

            createChannelIfNeeded(channel, title, soundName, enableLights, enableVibration, bundle);
        }

        Activity currentActivity = UnityPlayer.currentActivity;

        Intent intent = new Intent(currentActivity, NotificationManager.class);
        intent.putExtra("ticker", ticker);
        intent.putExtra("title", title);
        intent.putExtra("message", message);
        intent.putExtra("id", id);
        intent.putExtra("color", bgColor);
        intent.putExtra("sound", enableSound);
        intent.putExtra("soundName", soundName);
        intent.putExtra("vibrate", enableVibration);
        intent.putExtra("lights", enableLights);
        intent.putExtra("l_icon", largeIconResource);
        intent.putExtra("s_icon", smallIconResource);
        intent.putExtra("bundle", bundle);
        intent.putExtra("channel", channel);

        Bundle b = new Bundle();
        b.putParcelableArrayList("actions", actions);

        intent.putExtra("actionsBundle", b);

        long triggerAtMills = System.currentTimeMillis() + delayMs;
        PendingIntent pendingIntent = PendingIntent.getBroadcast(currentActivity, id, intent, PendingIntent.FLAG_UPDATE_CURRENT);

        AlarmManager am = (AlarmManager)currentActivity.getSystemService(Context.ALARM_SERVICE);
        am.setRepeating(AlarmManager.RTC_WAKEUP, triggerAtMills, rep, pendingIntent);
    }

    public void onReceive(Context context, Intent intent)
    {
        android.app.NotificationManager notificationManager = (android.app.NotificationManager)context.getSystemService(Context.NOTIFICATION_SERVICE);

        String ticker = intent.getStringExtra("ticker");
        String title = intent.getStringExtra("title");
        String message = intent.getStringExtra("message");
        String s_icon = intent.getStringExtra("s_icon");
        String l_icon = intent.getStringExtra("l_icon");
        int color = intent.getIntExtra("color", 0);
        String bundle = intent.getStringExtra("bundle");
        boolean sound = intent.getBooleanExtra("sound", false);
        String soundName = intent.getStringExtra("soundName");
        boolean vibrate = intent.getBooleanExtra("vibrate", false);
        boolean lights = intent.getBooleanExtra("lights", false);
        int id = intent.getIntExtra("id", 0);
        String channel = intent.getStringExtra("channel");
        Bundle b = intent.getBundleExtra("actionsBundle");
        ArrayList<NotificationAction> actions = null;
        if (b != null && b.containsKey("actions")) {
            actions = b.getParcelableArrayList("actions");
        }

        Resources res = context.getResources();

        Intent notificationIntent = context.getPackageManager().getLaunchIntentForPackage(bundle);

        TaskStackBuilder stackBuilder = TaskStackBuilder.create(context);
        stackBuilder.addNextIntent(notificationIntent);

        PendingIntent pendingIntent = PendingIntent.getActivity(context, 0,
                notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT);

        if (channel == null) {
            channel = "default";
        }

        NotificationCompat.Builder builder = new NotificationCompat.Builder(context, channel);

        builder.setContentIntent(pendingIntent)
                .setAutoCancel(true)
                .setContentTitle(title)
                .setContentText(message);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            builder.setColor(color);
        }

        if (ticker != null && ticker.length() > 0) {
            builder.setTicker(ticker);
        }

        if (s_icon != null && s_icon.length() > 0) {
            builder.setSmallIcon(res.getIdentifier(s_icon, "drawable", context.getPackageName()));
        }

        if (l_icon != null && l_icon.length() > 0) {
            builder.setLargeIcon(BitmapFactory.decodeResource(res, res.getIdentifier(l_icon, "drawable", context.getPackageName())));
        }

        if (sound) {
            if (soundName != null) {
                int identifier = res.getIdentifier("raw/" + soundName, null, context.getPackageName());
                builder.setSound(Uri.parse("android.resource://" + bundle + "/" + identifier));
            } else {
                builder.setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION));
            }
        }

        if (vibrate) {
            builder.setVibrate(new long[]{
                    1000L, 1000L
            });
        }

        if (lights) {
            builder.setLights(Color.GREEN, 3000, 3000);
        }

        if (actions != null) {
            for (int i = 0; i < actions.size(); i++) {
                NotificationAction action = actions.get(i);
                int icon = 0;
                if (action.getIcon() != null && action.getIcon().length() > 0) {
                    icon = res.getIdentifier(action.getIcon(), "drawable", context.getPackageName());
                }
                builder.addAction(icon, action.getTitle(), buildActionIntent(action, i, context));
            }
        }

        Notification notification = builder.build();
        notificationManager.notify(id, notification);
    }

    private static PendingIntent buildActionIntent(NotificationAction action, int id, Context context) {
        Intent intent = new Intent(context, NotificationActionHandler.class);

        intent.putExtra("id", id);
        intent.putExtra("gameObject", action.getGameObject());
        intent.putExtra("handlerMethod", action.getHandlerMethod());
        intent.putExtra("actionId", action.getIdentifier());
        intent.putExtra("foreground", action.isForeground());

        return PendingIntent.getBroadcast(context, id, intent, PendingIntent.FLAG_UPDATE_CURRENT);
    }

    public static void cancelPendingNotification(int id)
    {
        Activity currentActivity = UnityPlayer.currentActivity;
        Intent intent = new Intent(currentActivity, NotificationManager.class);
        PendingIntent pendingIntent = PendingIntent.getBroadcast(currentActivity, id, intent, PendingIntent.FLAG_UPDATE_CURRENT);

        AlarmManager am = (AlarmManager)currentActivity.getSystemService(Context.ALARM_SERVICE);
        am.cancel(pendingIntent);
    }

    public static void clearShowingNotifications()
    {
        Activity currentActivity = UnityPlayer.currentActivity;
        android.app.NotificationManager nm = (android.app.NotificationManager)currentActivity.getSystemService(Context.NOTIFICATION_SERVICE);
        nm.cancelAll();
    }
}
