import 'dart:io';
import 'package:bf_elec_apps/core/offline/offline_manager.dart';
import 'package:bf_elec_apps/features/drawings/domain/models/drawing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DrawingRepository {
  static const String _csvUrl =
      'https://docs.google.com/spreadsheets/d/1CLtMZxYV8YE3G28B_gU9Knor3036xeNYvddjRYfMVx8/export?format=csv&gid=2079200137';
  static const String _cacheKey = 'drawings_csv_cache';

  Future<List<Drawing>> loadDrawings() async {
    String csvData = '';

    try {
      final response = await http
          .get(Uri.parse(_csvUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        csvData = response.body;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, csvData);
        await OfflineManager.saveDrawingsCsv(csvData);
      }
    } catch (_) {}

    if (csvData.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        csvData = prefs.getString(_cacheKey) ?? '';
      } catch (_) {}
    }

    if (csvData.isEmpty) {
      try {
        final offlinePath = await OfflineManager.getDrawingsCsvPath();
        if (offlinePath != null) {
          final file = File(offlinePath);
          if (await file.exists()) {
            csvData = await file.readAsString();
          }
        }
      } catch (_) {}
    }

    if (csvData.isEmpty) {
      try {
        csvData = await rootBundle.loadString('assets/drawings_data.csv');
      } catch (_) {
        return [];
      }
    }

    return _parseCsv(csvData);
  }

  List<Drawing> _parseCsv(String csvData) {
    final lines = csvData
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) return [];

    final dataLines = lines.skip(1);
    final List<Drawing> drawings = [];

    for (final line in dataLines) {
      try {
        final drawing = Drawing.fromCsvRow(line);
        if (drawing.title.isNotEmpty) {
          drawings.add(drawing);
        }
      } catch (_) {}
    }

    return drawings;
  }
}
