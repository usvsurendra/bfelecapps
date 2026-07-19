import 'package:http/http.dart' as http;

void main() async {
  const originalUrl = 'https://docs.google.com/spreadsheets/d/1LpDYQ-h6lxX0HXLXXXLuHi2EeSEz4iM-m329Izz31DI/export?format=csv';
  final proxyUrl = 'https://corsproxy.io/?url=${Uri.encodeComponent(originalUrl)}';
  try {
    print('Fetching from Google Sheets via corsproxy...');
    final response = await http.get(Uri.parse(proxyUrl));
    print('Status Code: ${response.statusCode}');
    print('Body Length: ${response.body.length}');
    if (response.body.length > 100) {
      print('First 100 chars: ${response.body.substring(0, 100)}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
