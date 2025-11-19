import '../models/salary_model.dart'; // Import the TimeRange class and SalaryCalculationMode

class SalaryCalculator {
  /// Calculates the accumulated salary based on the selected mode
  static double calculateAccumulatedSalary(
    double annualSalary,
    SalaryCalculationMode mode,
    TimeRange workHours,
    DateTime currentTime,
  ) {
    // Determine the time range for the calculation
    DateTime startOfYear = DateTime(currentTime.year, 1, 1);
    DateTime endOfYear = DateTime(currentTime.year, 12, 31, 23, 59, 59);

    double totalSeconds = 0;
    double passedSeconds = 0;

    switch (mode) {
      case SalaryCalculationMode.fullYear:
        totalSeconds = endOfYear.difference(startOfYear).inSeconds.toDouble();
        passedSeconds = currentTime
            .difference(startOfYear)
            .inSeconds
            .toDouble();
        break;

      case SalaryCalculationMode.workDays:
        totalSeconds = _calculateWorkDaySeconds(startOfYear, endOfYear);
        passedSeconds = _calculateWorkDaySeconds(startOfYear, currentTime);
        break;

      case SalaryCalculationMode.workHours:
        totalSeconds = _calculateWorkHourSeconds(
          startOfYear,
          endOfYear,
          workHours,
        );
        passedSeconds = _calculateWorkHourSeconds(
          startOfYear,
          currentTime,
          workHours,
        );
        break;
    }

    // If no seconds have passed in the selected mode, return 0
    if (totalSeconds <= 0) return 0.0;
    // Don't return 0 if passedSeconds is 0 - the day might just have started
    // Instead, we allow 0 seconds passed to result in 0 salary

    // Calculate the accumulated salary
    return annualSalary * (passedSeconds / totalSeconds);
  }

  /// Calculate total seconds in work days between two dates
  static double _calculateWorkDaySeconds(DateTime start, DateTime end) {
    double totalSeconds = 0;
    DateTime current = DateTime(start.year, start.month, start.day);

    while (current.isBefore(end)) {
      // Check if it's a workday (Monday = 1, Sunday = 7)
      if (current.weekday >= 1 && current.weekday <= 5) {
        totalSeconds += const Duration(days: 1).inSeconds.toDouble();
      }
      current = current.add(const Duration(days: 1));
    }

    return totalSeconds;
  }

  /// Calculate total seconds in work hours between two dates
  static double _calculateWorkHourSeconds(
    DateTime start,
    DateTime end,
    TimeRange workHours,
  ) {
    double totalSeconds = 0;
    DateTime current = DateTime(start.year, start.month, start.day);

    while (current.isBefore(end)) {
      // Check if it's a workday (Monday = 1, Sunday = 7)
      if (current.weekday >= 1 && current.weekday <= 5) {
        // Calculate work seconds for this day
        DateTime workStart = DateTime(
          current.year,
          current.month,
          current.day,
          workHours.startTime.hour,
          workHours.startTime.minute,
        );
        DateTime workEnd = DateTime(
          current.year,
          current.month,
          current.day,
          workHours.endTime.hour,
          workHours.endTime.minute,
        );

        // If the end time is earlier than start time, it means it spans to next day
        if (workEnd.isBefore(workStart)) {
          workEnd = workEnd.add(const Duration(days: 1));
        }

        Duration workDuration = workEnd.difference(workStart);
        if (!workDuration.isNegative) {
          totalSeconds += workDuration.inSeconds.toDouble();
        }
      }
      current = current.add(const Duration(days: 1));
    }

    return totalSeconds;
  }

  /// Calculate the accumulated salary for a specific period
  static double calculatePeriodSalary(
    double annualSalary,
    SalaryCalculationMode mode,
    TimeRange workHours,
    DateTime fromTime,
    DateTime toTime,
  ) {
    double startSalary = calculateAccumulatedSalary(
      annualSalary,
      mode,
      workHours,
      fromTime,
    );
    double endSalary = calculateAccumulatedSalary(
      annualSalary,
      mode,
      workHours,
      toTime,
    );
    return endSalary - startSalary;
  }

  /// Check if currently in work hours
  static bool isCurrentlyInWorkHours(
    SalaryCalculationMode mode,
    TimeRange workHours,
    DateTime currentTime,
  ) {
    // If mode is full year or work days, we're always in work time
    if (mode != SalaryCalculationMode.workHours) {
      return true;
    }

    // Check if it's a workday
    if (currentTime.weekday < 1 || currentTime.weekday > 5) {
      return false;
    }

    // Check if it's within work hours
    int currentMinutes = currentTime.hour * 60 + currentTime.minute;
    int workStartMinutes =
        workHours.startTime.hour * 60 + workHours.startTime.minute;
    int workEndMinutes = workHours.endTime.hour * 60 + workHours.endTime.minute;

    // Handle case where work hours span to next day
    if (workEndMinutes < workStartMinutes) {
      return currentMinutes >= workStartMinutes ||
          currentMinutes < workEndMinutes;
    } else {
      return currentMinutes >= workStartMinutes &&
          currentMinutes < workEndMinutes;
    }
  }

  /// Calculate the total work seconds in a period based on the calculation mode
  static double calculatePeriodWorkSeconds(
    SalaryCalculationMode mode,
    TimeRange workHours,
    DateTime startDate,
    DateTime endDate,
  ) {
    double totalSeconds = 0;

    switch (mode) {
      case SalaryCalculationMode.fullYear:
        totalSeconds = endDate.difference(startDate).inSeconds.toDouble();
        break;

      case SalaryCalculationMode.workDays:
        totalSeconds = _calculateWorkDaySeconds(startDate, endDate);
        break;

      case SalaryCalculationMode.workHours:
        totalSeconds = _calculateWorkHourSeconds(startDate, endDate, workHours);
        break;
    }

    return totalSeconds;
  }
}
