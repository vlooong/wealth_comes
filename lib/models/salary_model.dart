import 'package:flutter/material.dart';

class SalaryModel {
  double annualSalary;
  double updateFrequency; // in seconds
  int decimalPlaces;
  String currencySymbol;
  SalaryCalculationMode calculationMode;
  TimeRange workHours;

  SalaryModel({
    required this.annualSalary,
    required this.updateFrequency,
    required this.decimalPlaces,
    required this.currencySymbol,
    required this.calculationMode,
    required this.workHours,
  });

  double get hourlyRate {
    switch (calculationMode) {
      case SalaryCalculationMode.fullYear:
        return annualSalary / 8760; // 365 days * 24 hours
      case SalaryCalculationMode.workDays:
        return annualSalary / (261 * 24); // approx 261 workdays in a year
      case SalaryCalculationMode.workHours:
        // Calculate based on work hours per day
        int workHoursPerDay = _calculateWorkHoursPerDay(workHours);
        return annualSalary / (261 * workHoursPerDay);
    }
  }

  double get perSecondRate {
    return hourlyRate / 3600; // 3600 seconds in an hour
  }

  int _calculateWorkHoursPerDay(TimeRange workHours) {
    // Convert TimeOfDay to minutes since midnight
    int startMinutes = workHours.startTime.hour * 60 + workHours.startTime.minute;
    int endMinutes = workHours.endTime.hour * 60 + workHours.endTime.minute;

    // Handle case where end time is on the next day
    if (endMinutes <= startMinutes) {
      // Add 24 hours worth of minutes (1440 minutes)
      endMinutes += 24 * 60;
    }

    int totalMinutes = endMinutes - startMinutes;
    return totalMinutes ~/ 60; // Integer division to get hours
  }

  Map<String, dynamic> toJson() {
    return {
      'annualSalary': annualSalary,
      'updateFrequency': updateFrequency,
      'decimalPlaces': decimalPlaces,
      'currencySymbol': currencySymbol,
      'calculationMode': calculationMode.index,
      'workHours': {
        'startHour': workHours.startTime.hour,
        'startMinute': workHours.startTime.minute,
        'endHour': workHours.endTime.hour,
        'endMinute': workHours.endTime.minute,
      }
    };
  }

  static SalaryModel fromJson(Map<String, dynamic> json) {
    return SalaryModel(
      annualSalary: json['annualSalary']?.toDouble() ?? 0.0,
      updateFrequency: json['updateFrequency']?.toDouble() ?? 1.0,
      decimalPlaces: json['decimalPlaces'] ?? 2,
      currencySymbol: json['currencySymbol'] ?? '\$',
      calculationMode: SalaryCalculationMode.values[json['calculationMode']] ?? SalaryCalculationMode.fullYear,
      workHours: TimeRange(
        startTime: TimeOfDay(
          hour: json['workHours']['startHour'] ?? 9,
          minute: json['workHours']['startMinute'] ?? 0,
        ),
        endTime: TimeOfDay(
          hour: json['workHours']['endHour'] ?? 18,
          minute: json['workHours']['endMinute'] ?? 0,
        ),
      ),
    );
  }
}

enum SalaryCalculationMode {
  fullYear('全年(365天)'),
  workDays('仅工作日(周一至周五)'),
  workHours('仅工作时段(周一至周五 9点-18点)');

  const SalaryCalculationMode(this.label);
  final String label;
}

class TimeRange {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  TimeRange({required this.startTime, required this.endTime});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeRange &&
        other.startTime == startTime &&
        other.endTime == endTime;
  }

  @override
  int get hashCode => startTime.hashCode ^ endTime.hashCode;

  TimeRange copyWith({TimeOfDay? startTime, TimeOfDay? endTime}) {
    return TimeRange(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}