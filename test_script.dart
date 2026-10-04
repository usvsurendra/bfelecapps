import 'dart:io';

void main() async {
  const originalUrl = 'https://docs.google.com/spreadsheets/d/1LpDYQ-h6lxX0HXLXXXLuHi2EeSEz4iM-m329Izz31DI/export?format=csv';
  final proxyUrl = 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(originalUrl)}';
  final url = proxyUrl;
  try {
    print('Fetching from Google Sheets...');
    final request = await HttpClient().getUrl(Uri.parse(url));
    final response = await request.close();
    print('Status Code: ${response.statusCode}');
    
    final contents = await response.transform(SystemEncoding().decoder).join();
    print('Body Length: ${contents.length}');
    if (contents.length > 100) {
      print('First 100 chars: ${contents.substring(0, 100)}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
