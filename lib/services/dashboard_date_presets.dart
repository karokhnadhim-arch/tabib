import 'package:flutter/material.dart';

import '../models/system_monitoring.dart';

/// Shared date-range helpers for dashboard filters and analytics.
class DashboardDatePresets {
  DashboardDatePresets._();

  static DateTime _startOfDay(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTimeRange today() {
    final now = DateTime.now();
    return DateTimeRange(start: _startOfDay(now), end: now);
  }

  static DateTimeRange yesterday() {
    final now = DateTime.now();
    final day = now.subtract(const Duration(days: 1));
    return DateTimeRange(
      start: _startOfDay(day),
      end: _startOfDay(now).subtract(const Duration(milliseconds: 1)),
    );
  }

  static DateTimeRange last7Days() {
    final now = DateTime.now();
    return DateTimeRange(
      start: _startOfDay(now.subtract(const Duration(days: 6))),
      end: now,
    );
  }

  static DateTimeRange thisMonth() {
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year, now.month),
      end: now,
    );
  }

  static DateTimeRange thisYear() {
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year),
      end: now,
    );
  }

  static DateTimeRange? forAnalyticsRange(
    AnalyticsRange range, {
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    return switch (range) {
      AnalyticsRange.today => today(),
      AnalyticsRange.yesterday => yesterday(),
      AnalyticsRange.week => last7Days(),
      AnalyticsRange.month => thisMonth(),
      AnalyticsRange.year => thisYear(),
      AnalyticsRange.custom =>
        customStart != null && customEnd != null
            ? DateTimeRange(start: customStart, end: customEnd)
            : null,
    };
  }
}
