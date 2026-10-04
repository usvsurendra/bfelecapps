import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import '../../domain/models/settings_item.dart';
import '../../domain/models/settings_detail_item.dart';

class SettingsRepository {
  static const String _mainCsvUrl =
      'https://docs.google.com/spreadsheets/d/1cskszZtwsjDpqz0lFfzP4GtZFsufFof-mh9cLl9PuTg/export?format=csv';

  Future<List<SettingsItem>> getSettingsItems() async {
    try {
      final response = await http.get(Uri.parse(_mainCsvUrl));
      if (response.statusCode == 200) {
        final List<List<dynamic>> csvData = Csv().decode(response.body);

        if (csvData.isEmpty) return [];

        // Skip header row
        return csvData.skip(1).map((row) => SettingsItem.fromCsvRow(row)).toList();
      } else {
        throw Exception('Failed to load settings data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load settings data: $e');
    }
  }

  Future<List<SettingsDetailItem>> getSettingsDetails(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<List<dynamic>> csvData = Csv().decode(response.body);

        if (csvData.isEmpty) return [];

        final headers = csvData.first;
        if (csvData.length == 1) return []; // Only headers

        // Skip header row
        return csvData
            .skip(1)
            .map((row) => SettingsDetailItem.fromCsvRow(headers, row))
            .toList();
      } else {
        throw Exception('Failed to load settings details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load settings details: $e');
    }
  }
}
