import 'package:bf_elec_apps/features/shift_snags/domain/models/shift_snag.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Repository that loads shift snag data from Google Sheets CSV,
/// with fallback to SharedPreferences cache → bundled asset.
class ShiftSnagRepository {
  static const String _csvUrl =
      'https://docs.google.com/spreadsheets/d/1LpDYQ-h6lxX0HXLXXXLuHi2EeSEz4iM-m329Izz31DI/export?format=csv';
  static const String _cacheKey = 'shift_snags_csv_cache';

  Future<List<ShiftSnag>> loadSnags() async {
    String csvData = '';

    // 1. Try fetching from Google Sheets online
    try {
      final response = await http
          .get(Uri.parse(_csvUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        csvData = response.body;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, csvData);
      }
    } catch (_) {
      // Network or CORS failure — try cache
    }

    // 2. Load from cache
    if (csvData.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        csvData = prefs.getString(_cacheKey) ?? '';
      } catch (_) {}
    }

    // 3. Fallback to bundled asset
    if (csvData.isEmpty) {
      try {
        csvData = await rootBundle.loadString('assets/shift_snags_data.csv');
      } catch (_) {
        return [];
      }
    }

    return _parseCsv(csvData);
  }

  /// Parse the entire CSV handling multi-line quoted fields correctly.
  List<ShiftSnag> _parseCsv(String csvData) {
    final rows = _parseMultiLineCsv(csvData);
    if (rows.isEmpty) return [];

    // Skip header row (PLC, PLCDATA, HARDWIRE, HARDWIREDATA)
    final snags = <ShiftSnag>[];
    for (int i = 1; i < rows.length; i++) {
      try {
        final snag = ShiftSnag.fromCsvFields(rows[i]);
        if (snag.plcTitle.isNotEmpty) {
          snags.add(snag);
        }
      } catch (_) {
        // Skip malformed rows
      }
    }
    return snags;
  }

  /// Robust CSV parser that handles multi-line quoted fields.
  /// The HTML solution data spans multiple lines within quoted CSV fields.
  static List<List<String>> _parseMultiLineCsv(String csvData) {
    final rows = <List<String>>[];
    final fields = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < csvData.length; i++) {
      final char = csvData[i];

      if (char == '"') {
        // Handle escaped double-quote ("")
        if (inQuotes && i + 1 < csvData.length && csvData[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        // Field separator outside quotes
        fields.add(buffer.toString());
        buffer.clear();
      } else if ((char == '\r' || char == '\n') && !inQuotes) {
        // Record separator outside quotes
        if (char == '\r' && i + 1 < csvData.length && csvData[i + 1] == '\n') {
          i++; // Skip \n in \r\n
        }
        fields.add(buffer.toString());
        buffer.clear();
        if (fields.any((f) => f.trim().isNotEmpty)) {
          rows.add(List<String>.from(fields));
        }
        fields.clear();
      } else {
        // Regular character (including \n inside quotes — part of HTML content)
        buffer.write(char);
      }
    }

    // Handle last record if file doesn't end with newline
    fields.add(buffer.toString());
    if (fields.any((f) => f.trim().isNotEmpty)) {
      rows.add(List<String>.from(fields));
    }

    return rows;
  }
}
