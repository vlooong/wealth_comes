package com.example.wealth_comes;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.widget.RemoteViews;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.Calendar;

public class WealthWidgetProvider extends AppWidgetProvider {

    private static final String PREFS_NAME = "FlutterSharedPreferences";

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }

    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.wealth_widget);

        // Get data from SharedPreferences
        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        
        double annualSalary = Double.longBitsToDouble(prefs.getLong("flutter.annual_salary", 0));
        String currencySymbol = prefs.getString("flutter.currency_symbol", "¥");
        int calculationMode = prefs.getInt("flutter.calculation_mode", 0);
        
        // Get salary data
        String todaySalary = prefs.getString("flutter.today_salary", currencySymbol + "0.00");
        String totalSalary = prefs.getString("flutter.current_total_salary", currencySymbol + "0.00");
        
        // Calculate today's progress
        Calendar calendar = Calendar.getInstance();
        int currentHour = calendar.get(Calendar.HOUR_OF_DAY);
        int currentMinute = calendar.get(Calendar.MINUTE);
        int totalMinutes = currentHour * 60 + currentMinute;
        int dayMinutes = 24 * 60;
        int progressPercent = (int) ((totalMinutes * 100.0) / dayMinutes);
        
        // Update views
        views.setTextViewText(R.id.today_salary, todaySalary);
        views.setTextViewText(R.id.total_salary, totalSalary);
        views.setProgressBar(R.id.today_progress, 100, progressPercent, false);
        views.setTextViewText(R.id.today_progress_text, progressPercent + "%");
        
        // Update time
        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm", Locale.getDefault());
        String updateTime = sdf.format(new Date());
        views.setTextViewText(R.id.update_time, updateTime);

        // Create an Intent to launch the app when clicked
        Intent intent = new Intent(context, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(
            context, 
            0, 
            intent, 
            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );
        views.setOnClickPendingIntent(R.id.content, pendingIntent);

        // Update the widget
        appWidgetManager.updateAppWidget(appWidgetId, views);
    }

    @Override
    public void onEnabled(Context context) {
        // Called when the first widget is created
        super.onEnabled(context);
    }

    @Override
    public void onDisabled(Context context) {
        // Called when the last widget is removed
        super.onDisabled(context);
    }
}
