import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  AnalyticsService._();

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // ---------- Private Helper ----------

  static void _logEvent(String name, [Map<String, Object>? parameters]) {
    _analytics.logEvent(name: name, parameters: parameters).catchError((_) {
      // Never allow analytics failures
      // to affect the user experience.
    });
  }

  // ---------- App ----------

  static void appOpened() {
    _analytics.logAppOpen().catchError((_) {});
  }

  // ---------- Projects ----------

  static void projectCreated() {
    debugPrint("📊 Analytics: project_created");

    _logEvent("project_created");
  }

  static void projectLoaded() {
    _logEvent("project_loaded");
  }

  static void projectDeleted() {
    _logEvent("project_deleted");
  }

  // ---------- Exports ----------

  static void pdfExported() {
    _logEvent("pdf_exported");
  }

  static void dxfExported() {
    _logEvent("dxf_exported");
  }

  // ---------- Optimization ----------

  static void optimizationStarted({required int partCount}) {
    _logEvent("optimization_started", {"part_count": partCount});
  }

  static void optimizationCompleted({
    required int partCount,
    required int sheetCount,
    required double utilization,
  }) {
    _logEvent("optimization_completed", {
      "part_count": partCount,
      "sheet_count": sheetCount,
      "utilization": utilization,
    });
  }
}
