import 'package:flutter/foundation.dart';

import '../models/owner_monitoring_phase4.dart';
import '../models/system_monitoring.dart';

/// Firebase cost analysis from aggregated metrics — monitoring layer only.
class FirebaseCostOptimizerService extends ChangeNotifier {
  FirebaseCostAnalysis? _analysis;

  FirebaseCostAnalysis? get analysis => _analysis;

  void analyze(SystemMonitoringSnapshot? snapshot) {
    if (snapshot == null) {
      _analysis = null;
      notifyListeners();
      return;
    }

    final reads = snapshot.firestoreReads;
    final writes = snapshot.firestoreWrites;
    final storage = snapshot.storageUsageMb;
    final bandwidth = snapshot.imageStorageMb * 1.8;

    // Demo pricing model (USD) — illustrative only.
    final readCost = reads * 0.00000036;
    final writeCost = writes * 0.00000108;
    final storageCost = storage * 0.00018;
    final bandwidthCost = bandwidth * 0.00012;
    final estimated = readCost + writeCost + storageCost + bandwidthCost;

    final suggestions = <String>[];
    final warnings = <String>[];

    if (reads > 5000) {
      suggestions.add(
        'Batch dashboard reads into aggregated platformMetrics documents.',
      );
    }
    if (snapshot.cacheHitRate < 90) {
      suggestions.add('Increase local caching — current hit rate ${snapshot.cacheHitRate}%.');
    }
    if (storage > 500) {
      suggestions.add('Compress clinic images and move cold storage to cheaper tiers.');
    }
    if (!snapshot.firebaseConnected) {
      warnings.add('Firebase disconnected — retry storms may inflate read costs.');
    }
    if (reads + writes > 20000) {
      warnings.add(
        'Projected daily operations exceed 20K — review real-time listeners on dashboards.',
      );
    }
    if (snapshot.storageUsagePercent >= 80) {
      warnings.add('Storage above 80% — upgrade or purge before automatic overage charges.');
    }
    if (suggestions.isEmpty) {
      suggestions.add('Current usage is within optimized thresholds. Keep using aggregated reads.');
    }

    _analysis = FirebaseCostAnalysis(
      estimatedMonthlyUsd: estimated * 30,
      readOperations: reads,
      writeOperations: writes,
      storageMb: storage,
      bandwidthMb: bandwidth,
      suggestions: suggestions,
      expensiveOperationWarnings: warnings,
    );
    notifyListeners();
  }
}
