import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import '../models/motor_model.dart';

class MotorRepository {
  static const String sheetUrl =
      'https://docs.google.com/spreadsheets/d/1arV6uUAPIGF1BfkwCDKBb5qhtU699oEcURWYVG_pBRI/export?format=csv';

  Future<List<MotorModel>> fetchMotors() async {
    try {
      final response = await http.get(Uri.parse(sheetUrl));

      if (response.statusCode == 200) {
        final List<List<dynamic>> csvTable = Csv().decode(response.body);

        if (csvTable.isEmpty) return [];

        // Skip the header row (index 0) and parse the rest
        return csvTable.skip(1).map((row) => MotorModel.fromCsvRow(row)).toList();
      } else {
        throw Exception('Failed to load motor data. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching motor data: $e');
    }
  }
}
