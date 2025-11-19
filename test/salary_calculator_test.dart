// Basic test for the salary accumulator functionality
import 'package:flutter_test/flutter_test.dart';
import 'package:wealth_comes/utils/salary_calculator.dart';
import 'package:wealth_comes/models/salary_model.dart';
import 'package:flutter/material.dart';

void main() {
  group('SalaryCalculator Tests', () {
    test('calculateAccumulatedSalary with full year mode', () {
      double annualSalary = 60000.0;
      var mode = SalaryCalculationMode.fullYear;
      var workHours = TimeRange(
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 18, minute: 0),
      );

      // Test with the beginning of the year
      var startOfYear = DateTime(DateTime.now().year, 1, 1);
      double result = SalaryCalculator.calculateAccumulatedSalary(
        annualSalary,
        mode,
        workHours,
        startOfYear,
      );

      expect(result, 0.0);

      // Test with the middle of the year (approximately half the salary)
      var midOfYear = DateTime(DateTime.now().year, 7, 2);
      result = SalaryCalculator.calculateAccumulatedSalary(
        annualSalary,
        mode,
        workHours,
        midOfYear,
      );

      // Expected result should be approximately half the annual salary
      double expected = annualSalary * 0.5;
      expect(result, closeTo(expected, expected * 0.01)); // Allow 1% variance
    });

    test('calculateAccumulatedSalary with work days mode', () {
      double annualSalary = 60000.0;
      var mode = SalaryCalculationMode.workDays;
      var workHours = TimeRange(
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 18, minute: 0),
      );

      // Test with a Monday later in the year to ensure work days have accumulated
      var monday = DateTime(2023, 6, 5); // A Monday in June 2023
      double result = SalaryCalculator.calculateAccumulatedSalary(
        annualSalary,
        mode,
        workHours,
        monday,
      );

      // Since it's later in the year, there should be accumulated salary
      expect(result, greaterThan(0.0));
    });

    test('calculateAccumulatedSalary with work hours mode', () {
      double annualSalary = 60000.0;
      var mode = SalaryCalculationMode.workHours;
      var workHours = TimeRange(
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 18, minute: 0),
      );

      // Test with a work day within work hours
      var workDay = DateTime(2023, 1, 2, 10, 30); // Monday at 10:30 AM
      double result = SalaryCalculator.calculateAccumulatedSalary(
        annualSalary,
        mode,
        workHours,
        workDay,
      );

      // Should be greater than 0
      expect(result, greaterThan(0.0));
    });

    test('isCurrentlyInWorkHours function', () {
      var mode = SalaryCalculationMode.workHours;
      var workHours = TimeRange(
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 18, minute: 0),
      );

      // Test within work hours on a weekday
      var workTime = DateTime(2023, 1, 2, 10, 30); // Monday at 10:30 AM
      bool inWorkHours = SalaryCalculator.isCurrentlyInWorkHours(
        mode,
        workHours,
        workTime,
      );

      expect(inWorkHours, true);

      // Test outside work hours on a weekday
      var outsideWorkTime = DateTime(2023, 1, 2, 19, 30); // Monday at 7:30 PM
      inWorkHours = SalaryCalculator.isCurrentlyInWorkHours(
        mode,
        workHours,
        outsideWorkTime,
      );

      expect(inWorkHours, false);

      // Test on a weekend with work hours mode
      var weekendTime = DateTime(2023, 1, 7, 10, 30); // Saturday at 10:30 AM
      inWorkHours = SalaryCalculator.isCurrentlyInWorkHours(
        mode,
        workHours,
        weekendTime,
      );

      expect(inWorkHours, false);

      // Test with full year mode (should always return true)
      var anytime = DateTime(2023, 1, 7, 10, 30); // Saturday at 10:30 AM
      inWorkHours = SalaryCalculator.isCurrentlyInWorkHours(
        SalaryCalculationMode.fullYear,
        workHours,
        anytime,
      );

      expect(inWorkHours, true);
    });
  });
}