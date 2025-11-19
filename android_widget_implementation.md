# Android Desktop Widget Implementation Guide

The Flutter application "Wealth Comes" includes functionality for an Android desktop widget, but the actual implementation requires native Android code since Flutter doesn't directly support home screen widgets.

## Complete Implementation

To implement the desktop widget functionality:

1. Create native Android widget components in the `android/app/src/main/res/layout` directory
2. Implement a `WidgetProvider` service in the `android/app/src/main/java/...` directory
3. Use Flutter's platform channels to communicate between the native widget and Flutter app
4. Schedule periodic updates using Android's `AlarmManager`

### 1. Widget Layout (XML)
Create `appwidget_layout.xml` in `android/app/src/main/res/layout/`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:padding="12dp"
    android:background="@drawable/widget_background"
    android:gravity="center">

    <TextView
        android:id="@+id/widget_title"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="财富累积器"
        android:textSize="14sp"
        android:textStyle="bold"
        android:textColor="#333333" />

    <TextView
        android:id="@+id/widget_period"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="今日累计"
        android:textSize="12sp"
        android:textColor="#666666"
        android:layout_marginTop="4dp" />

    <TextView
        android:id="@+id/widget_salary"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_marginTop="8dp"
        android:text="¥0.00"
        android:textSize="18sp"
        android:textStyle="bold"
        android:textColor="#4CAF50" />

</LinearLayout>
```

### Widget Background Drawable
Create `res/drawable/widget_background.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#FFFFFF" />
    <stroke android:width="1dp" android:color="#CCCCCC" />
    <corners android:radius="8dp" />
</shape>
```

### 2. Widget Configuration (XML)
Create `appwidget_info.xml` in `android/app/src/main/res/xml/`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="250dp"
    android:minHeight="60dp"
    android:updatePeriodMillis="30000"  <!-- Update every 30 seconds -->
    android:initialLayout="@layout/appwidget_layout"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen|keyguard"
    android:previewImage="@drawable/widget_preview">
</appwidget-provider>
```

### 3. Widget Provider (Java/Kotlin)
Create `SalaryWidgetProvider.java` in the main Java directory:

```java
package com.example.wealth_comes; // Replace with your actual package name

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.widget.RemoteViews;

public class SalaryWidgetProvider extends AppWidgetProvider {

    private static final String PREFS_NAME = "SalaryWidgetPrefs";
    private static final String PREF_PREFIX_KEY = "appwidget_";

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        // There may be multiple widgets active, so update all of them
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }

    @Override
    public void onDeleted(Context context, int[] appWidgetIds) {
        // When the user deletes the widget, delete the preference associated with it.
        for (int appWidgetId : appWidgetIds) {
            deleteTitlePref(context, appWidgetId);
        }
    }

    @Override
    public void onEnabled(Context context) {
        // Enter relevant functionality for when the first widget is created
    }

    @Override
    public void onDisabled(Context context) {
        // Enter relevant functionality for when the last widget is disabled
    }

    private void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        // Get data for this specific widget instance
        String period = getPeriodFromPrefs(context, appWidgetId, "今日累计");
        String salaryValue = getSalaryFromPrefs(context, appWidgetId, "¥0.00");

        // Construct the RemoteViews object
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.appwidget_layout);
        views.setTextViewText(R.id.widget_period, period);
        views.setTextViewText(R.id.widget_salary, salaryValue);

        // Create an Intent to launch MainActivity
        Intent intent = new Intent(context, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        views.setOnClickPendingIntent(R.id.widget_title, pendingIntent);
        views.setOnClickPendingIntent(R.id.widget_period, pendingIntent);
        views.setOnClickPendingIntent(R.id.widget_salary, pendingIntent);

        // Instruct the widget manager to update the widget
        appWidgetManager.updateAppWidget(appWidgetId, views);
    }

    // Methods to manage preferences for each widget instance
    static void savePeriodPref(Context context, int appWidgetId, String text) {
        SharedPreferences.Editor prefs = context.getSharedPreferences(PREFS_NAME, 0).edit();
        prefs.putString(PREF_PREFIX_KEY + appWidgetId, text);
        prefs.apply();
    }

    static String getPeriodFromPrefs(Context context, int appWidgetId, String defaultValue) {
        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, 0);
        String period = prefs.getString(PREF_PREFIX_KEY + appWidgetId, null);
        if (period != null) return period;
        return defaultValue;
    }

    static void deleteTitlePref(Context context, int appWidgetId) {
        SharedPreferences.Editor prefs = context.getSharedPreferences(PREFS_NAME, 0).edit();
        prefs.remove(PREF_PREFIX_KEY + appWidgetId);
        prefs.apply();
    }

    // Methods to manage salary value for each widget instance
    static void saveSalaryPref(Context context, int appWidgetId, String salary) {
        SharedPreferences.Editor prefs = context.getSharedPreferences(SalaryWidgetPrefs.SALARY_PREFS_NAME, 0).edit();
        prefs.putString(SalaryWidgetPrefs.SALARY_PREF_PREFIX + appWidgetId, salary);
        prefs.apply();
    }

    static String getSalaryFromPrefs(Context context, int appWidgetId, String defaultValue) {
        SharedPreferences prefs = context.getSharedPreferences(SalaryWidgetPrefs.SALARY_PREFS_NAME, 0);
        String salary = prefs.getString(SalaryWidgetPrefs.SALARY_PREF_PREFIX + appWidgetId, null);
        if (salary != null) return salary;
        return defaultValue;
    }
}
```

### 4. Add to AndroidManifest.xml
Add the widget provider to the manifest file in `android/app/src/main/AndroidManifest.xml`:

```xml
<receiver android:name=".SalaryWidgetProvider">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/appwidget_info" />
</receiver>
```

### 5. Service for Periodic Updates
Create `SalaryWidgetService.java` to handle periodic updates:

```java
package com.example.wealth_comes; // Replace with your actual package name

import android.app.Service;
import android.appwidget.AppWidgetManager;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.IBinder;
import android.util.Log;

import java.util.Calendar;

public class SalaryWidgetService extends Service {

    private static final String TAG = "SalaryWidgetService";

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(TAG, "Updating salary widget");
        updateWidget();
        return START_NOT_STICKY;
    }

    private void updateWidget() {
        AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(this);
        int[] appWidgetIds = appWidgetManager.getAppWidgetIds(
            new ComponentName(this, SalaryWidgetProvider.class));

        if (appWidgetIds.length > 0) {
            // Update each of the widgets
            for (int appWidgetId : appWidgetIds) {
                // Calculate current salary based on period setting
                String period = SalaryWidgetProvider.getPeriodFromPrefs(this, appWidgetId, "今日累计");
                String salaryValue = calculateSalaryForPeriod(period);

                // Update the widget
                SalaryWidgetProvider.saveSalaryPref(this, appWidgetId, salaryValue);

                // Update the widget UI
                RemoteViews views = new RemoteViews(getPackageName(), R.layout.appwidget_layout);
                views.setTextViewText(R.id.widget_period, period);
                views.setTextViewText(R.id.widget_salary, salaryValue);

                appWidgetManager.updateAppWidget(appWidgetId, views);
            }
        }

        stopSelf();
    }

    private String calculateSalaryForPeriod(String period) {
        // This should get the actual salary data from shared preferences
        // or through communication with the Flutter app
        SharedPreferences prefs = getSharedPreferences("salary_data", MODE_PRIVATE);
        double annualSalary = prefs.getFloat("annual_salary", 60000.0f);
        String currency = prefs.getString("currency_symbol", "¥");
        int calculationMode = prefs.getInt("calculation_mode", 0); // 0=full_year, 1=work_days, 2=work_hours
        String workHoursStart = prefs.getString("work_hours_start", "09:00");
        String workHoursEnd = prefs.getString("work_hours_end", "18:00");

        // Calculate based on the period
        Calendar now = Calendar.getInstance();

        double periodSalary = 0.0;
        switch (period) {
            case "今日累计":
                // Calculate daily salary
                periodSalary = calculateDailySalary(annualSalary, calculationMode, workHoursStart, workHoursEnd);
                break;
            case "本周累计":
                // Calculate weekly salary
                periodSalary = calculateWeeklySalary(annualSalary, calculationMode, workHoursStart, workHoursEnd);
                break;
            case "本月累计":
                // Calculate monthly salary
                periodSalary = calculateMonthlySalary(annualSalary, calculationMode, workHoursStart, workHoursEnd);
                break;
            case "本年累计":
                // Calculate yearly salary
                periodSalary = calculateYearlySalary(annualSalary, calculationMode, workHoursStart, workHoursEnd);
                break;
        }

        return currency + String.format("%.2f", periodSalary);
    }

    // Placeholder methods - implement based on your calculation logic
    private double calculateDailySalary(double annual, int mode, String start, String end) {
        // Calculate daily salary based on mode
        return annual / 365; // This is just a placeholder
    }

    private double calculateWeeklySalary(double annual, int mode, String start, String end) {
        // Calculate weekly salary based on mode
        return annual / 52; // This is just a placeholder
    }

    private double calculateMonthlySalary(double annual, int mode, String start, String end) {
        // Calculate monthly salary based on mode
        return annual / 12; // This is just a placeholder
    }

    private double calculateYearlySalary(double annual, int mode, String start, String end) {
        // Return the full annual salary
        return annual; // This is just a placeholder
    }
}
```

### 6. Update Flutter Code
Update your Flutter code to communicate salary data to the native Android code:

In your `SalaryService` (`lib/services/salary_service.dart`), add a method to update the widget:

```dart
import 'package:shared_preferences/shared_preferences.dart';

// In the SalaryService class, add a method to update Android widget
void updateAndroidWidget() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Save current salary data to shared preferences
  await prefs.setDouble('annual_salary', _salaryModel.annualSalary);
  await prefs.setString('currency_symbol', _salaryModel.currencySymbol);
  await prefs.setInt('calculation_mode', _salaryModel.calculationMode.index);
  await prefs.setString('work_hours_start',
    '${_salaryModel.workHours.startTime.hour.toString().padLeft(2, '0')}:${_salaryModel.workHours.startTime.minute.toString().padLeft(2, '0')}');
  await prefs.setString('work_hours_end',
    '${_salaryModel.workHours.endTime.hour.toString().padLeft(2, '0')}:${_salaryModel.workHours.endTime.minute.toString().padLeft(2, '0')}');

  // Save current period values
  DateTime now = DateTime.now();
  DateTime startDate = DateTime(now.year, now.month, now.day); // Today
  DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

  double todaySalary = SalaryCalculator.calculatePeriodSalary(
    _salaryModel.annualSalary,
    _salaryModel.calculationMode,
    _salaryModel.workHours,
    startDate,
    endDate,
  );

  await prefs.setString('current_period_salary', '${_salaryModel.currencySymbol}${todaySalary.toStringAsFixed(_salaryModel.decimalPlaces)}');
}
```

### 7. Add Service to AndroidManifest.xml
Also add the service to the manifest:

```xml
<service android:name=".SalaryWidgetService" />
```

### 8. Initialize Widget Updates
In your MainActivity.java, set up periodic updates:

```java
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import java.util.Calendar;

// In your MainActivity's onCreate method
private void setupWidgetUpdates() {
    AlarmManager alarmManager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
    Intent intent = new Intent(this, SalaryWidgetService.class);
    PendingIntent pendingIntent = PendingIntent.getService(
        this,
        0,
        intent,
        PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
    );

    // Update every 30 seconds
    alarmManager.setRepeating(
        AlarmManager.RTC_WAKEUP,
        Calendar.getInstance().getTimeInMillis(),
        30 * 1000, // 30 seconds
        pendingIntent
    );
}
```

## Periodic Updates
The widget will now update every 30 seconds, showing the accumulated salary for the selected period (今日累计, 本周累计, 本月累计, 本年累计).

## Testing the Widget
After implementing the native widget:
1. Run `flutter build apk` to build the application
2. Install the APK on an Android device
3. Add the widget to your home screen through the widget picker
4. The widget will show the selected period's accumulated salary
5. Verify that it updates correctly based on your salary settings

Note: The actual implementation will need to include the proper salary calculation logic based on the current time and configured settings.