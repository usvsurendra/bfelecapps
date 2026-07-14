import 'dart:convert';
import 'package:bf_elec_apps/features/smp/domain/models/smp.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class SmpRepository {
  static const String _csvAssetKey = 'assets/smp_data.csv';
  static const String _lastUpdatedKey = 'smp_last_updated';

  Future<List<SmpItem>> loadSmpItems({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdated = prefs.getString(_lastUpdatedKey);
    if (!forceRefresh && lastUpdated != null) {
      final csvString = await rootBundle.loadString(_csvAssetKey);
      return _parseCsv(csvString);
    }
    final csvString = await rootBundle.loadString(_csvAssetKey);
    final now = DateTime.now().toIso8601String();
    await prefs.setString(_lastUpdatedKey, now);
    return _parseCsv(csvString);
  }

  Future<String?> getLastUpdatedTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUpdatedKey);
  }

  List<SmpItem> searchSmp(List<SmpItem> items, String query) {
    if (query.trim().isEmpty) return items;
    final lower = query.toLowerCase();
    return items
        .where((item) =>
            item.title.toLowerCase().contains(lower) ||
            item.category.toLowerCase().contains(lower) ||
            item.description.toLowerCase().contains(lower))
        .toList();
  }

  List<SmpItem> _parseCsv(String csvString) {
    final lines = const LineSplitter().convert(csvString);
    final items = <SmpItem>[];
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      items.add(SmpItem.fromCsvRow(line));
    }
    return items;
  }
}
