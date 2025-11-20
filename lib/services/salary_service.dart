import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/salary_model.dart';
import '../utils/salary_calculator.dart';

class SalaryService extends ChangeNotifier {
  SalaryModel _salaryModel = SalaryModel(
    annualSalary: 60000.0,
    updateFrequency: 1.0,
    decimalPlaces: 2,
    currencySymbol: '\$',
    calculationMode: SalaryCalculationMode.fullYear,
    workHours: TimeRange(
      startTime: TimeOfDay(hour: 9, minute: 0),
      endTime: TimeOfDay(hour: 18, minute: 0),
    ),
  );

  SalaryModel get salaryModel => _salaryModel;

  double _currentSalary = 0.0;
  double get currentSalary => _currentSalary;

  Timer? _timer;

  SalaryService() {
    _loadFromPreferences();
    _calculateCurrentSalary();
  }

  Future<void> _loadFromPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedData = prefs.getString('salaryModel');
      if (savedData != null) {
        // Parse the JSON string and create SalaryModel from it
        final Map<String, dynamic> jsonData = json.decode(savedData);
        _salaryModel = SalaryModel.fromJson(jsonData);
        _startTimer();
        notifyListeners();
      }
    } catch (e) {
      // If there's an error loading, just use default values
      print('Error loading preferences: $e');
    }
  }

  Future<void> _saveToPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Convert the model to JSON and save it
      final jsonData = _salaryModel.toJson();
      final jsonString = json.encode(jsonData);
      await prefs.setString('salaryModel', jsonString);
    } catch (e) {
      print('Error saving preferences: $e');
    }
  }

  Future<void> updateSalaryModel(SalaryModel newModel) async {
    _salaryModel = newModel;
    await _saveToPreferences();
    _startTimer();
    notifyListeners();
  }

  void _calculateCurrentSalary() {
    _currentSalary = SalaryCalculator.calculateAccumulatedSalary(
      _salaryModel.annualSalary,
      _salaryModel.calculationMode,
      _salaryModel.workHours,
      DateTime.now(),
    );
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(Duration(milliseconds: (_salaryModel.updateFrequency * 1000).toInt()), (timer) {
      _calculateCurrentSalary();
    });
  }

  String getFormattedSalary() {
    String formatted = _currentSalary.toStringAsFixed(_salaryModel.decimalPlaces);
    return '${_salaryModel.currencySymbol}$formatted';
  }

  String getFormattedSalaryForPeriod(DateTime startDate, DateTime endDate) {
    // Calculate the salary accumulated from the start of the period to the current time
    // If current time is beyond the end of the period, use the end of the period
    DateTime now = DateTime.now();
    DateTime calculationEnd = now.isAfter(endDate) ? endDate : now;

    // Calculate how much salary has accumulated from the start of the period to now (or end of period)
    double startSalary = SalaryCalculator.calculateAccumulatedSalary(
      _salaryModel.annualSalary,
      _salaryModel.calculationMode,
      _salaryModel.workHours,
      startDate,
    );

    double endSalary = SalaryCalculator.calculateAccumulatedSalary(
      _salaryModel.annualSalary,
      _salaryModel.calculationMode,
      _salaryModel.workHours,
      calculationEnd,
    );

    double periodSalary = endSalary - startSalary;

    // If the period salary is negative, return 0
    if (periodSalary < 0) {
      periodSalary = 0;
    }

    String formatted = periodSalary.toStringAsFixed(_salaryModel.decimalPlaces);
    return '${_salaryModel.currencySymbol}$formatted';
  }

  double getProgressPercentage(DateTime startDate, DateTime endDate) {
    // Calculate progress based on the selected calculation mode
    DateTime now = DateTime.now();

    if (_salaryModel.calculationMode == SalaryCalculationMode.fullYear) {
      // For full year mode, calculate simple time-based progress
      Duration totalDuration = endDate.difference(startDate);
      Duration elapsedDuration = now.isAfter(endDate)
          ? totalDuration
          : now.difference(startDate);

      double progress = totalDuration.inSeconds > 0
          ? elapsedDuration.inSeconds / totalDuration.inSeconds
          : 0.0;
      return progress > 1.0 ? 1.0 : progress;
    } else {
      // For work days and work hours modes, calculate progress based on available work time
      double totalWorkSeconds = SalaryCalculator.calculatePeriodWorkSeconds(
        _salaryModel.calculationMode,
        _salaryModel.workHours,
        startDate,
        endDate,
      );

      DateTime calculationEnd = now.isAfter(endDate) ? endDate : now;
      double elapsedWorkSeconds = SalaryCalculator.calculatePeriodWorkSeconds(
        _salaryModel.calculationMode,
        _salaryModel.workHours,
        startDate,
        calculationEnd,
      );

      double progress = totalWorkSeconds > 0
          ? elapsedWorkSeconds / totalWorkSeconds
          : 0.0;
      return progress > 1.0 ? 1.0 : progress;
    }
  }

  // Update Android widget with current salary data
  Future<void> updateAndroidWidget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save current salary data to shared preferences
    await prefs.setDouble('annual_salary', _salaryModel.annualSalary);
    await prefs.setString('currency_symbol', _salaryModel.currencySymbol);
    await prefs.setInt('calculation_mode', _salaryModel.calculationMode.index);
    await prefs.setString('work_hours_start',
      '${_salaryModel.workHours.startTime.hour.toString().padLeft(2, '0')}:${_salaryModel.workHours.startTime.minute.toString().padLeft(2, '0')}');
    await prefs.setString('work_hours_end',
      '${_salaryModel.workHours.endTime.hour.toString().padLeft(2, '0')}:${_salaryModel.workHours.endTime.minute.toString().padLeft(2, '0')}');

    // Update salary for each potential period that might be shown on widget
    DateTime now = DateTime.now();

    // Today's salary
    DateTime todayStart = DateTime(now.year, now.month, now.day);
    DateTime todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    double todaySalary = SalaryCalculator.calculatePeriodSalary(
      _salaryModel.annualSalary,
      _salaryModel.calculationMode,
      _salaryModel.workHours,
      todayStart,
      todayEnd,
    );
    await prefs.setString('today_salary', '${_salaryModel.currencySymbol}${todaySalary.toStringAsFixed(_salaryModel.decimalPlaces)}');

    // This week's salary
    int daysSinceMonday = now.weekday - 1;
    DateTime weekStart = DateTime(now.year, now.month, now.day - daysSinceMonday);
    DateTime weekEnd = weekStart.add(const Duration(days: 6));
    double weekSalary = SalaryCalculator.calculatePeriodSalary(
      _salaryModel.annualSalary,
      _salaryModel.calculationMode,
      _salaryModel.workHours,
      weekStart,
      weekEnd,
    );
    await prefs.setString('week_salary', '${_salaryModel.currencySymbol}${weekSalary.toStringAsFixed(_salaryModel.decimalPlaces)}');

    // This month's salary
    DateTime monthStart = DateTime(now.year, now.month, 1);
    DateTime monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    double monthSalary = SalaryCalculator.calculatePeriodSalary(
      _salaryModel.annualSalary,
      _salaryModel.calculationMode,
      _salaryModel.workHours,
      monthStart,
      monthEnd,
    );
    await prefs.setString('month_salary', '${_salaryModel.currencySymbol}${monthSalary.toStringAsFixed(_salaryModel.decimalPlaces)}');

    // This year's salary
    DateTime yearStart = DateTime(now.year, 1, 1);
    DateTime yearEnd = DateTime(now.year, 12, 31, 23, 59, 59);
    double yearSalary = SalaryCalculator.calculatePeriodSalary(
      _salaryModel.annualSalary,
      _salaryModel.calculationMode,
      _salaryModel.workHours,
      yearStart,
      yearEnd,
    );
    await prefs.setString('year_salary', '${_salaryModel.currencySymbol}${yearSalary.toStringAsFixed(_salaryModel.decimalPlaces)}');

    // Also save the current total salary
    await prefs.setString('current_total_salary', getFormattedSalary());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}