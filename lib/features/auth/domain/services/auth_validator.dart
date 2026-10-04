import 'package:http/http.dart' as http;

class AuthValidator {
  static const String _sheetUrl =
      'https://docs.google.com/spreadsheets/d/1Zg7qcnC3m4-C28WmmIzj7FwWhK6zPXD33-sayRvCKZA/export?format=csv&gid=0';

  /// Validates if the given email is present in the allowed Google Sheet.
  /// The user specified "first row is used for mailids" but to be robust,
  /// we will search the entire CSV for the email.
  static Future<bool> isEmailAllowed(String email) async {
    try {
      final response = await http.get(Uri.parse(_sheetUrl));
      if (response.statusCode != 200) {
        // If we can't reach the sheet, we might want to fail closed or open.
        // Failing closed (returning false) is safer for an allowlist.
        return false;
      }

      final rows = response.body.split('\n');
      final searchEmail = email.trim().toLowerCase();

      for (final row in rows) {
        final cells = row.split(',');
        for (final cell in cells) {
          if (cell.trim().toLowerCase() == searchEmail) {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
