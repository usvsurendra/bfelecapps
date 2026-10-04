import 'dart:io';

void main() {
  final csvData = File('assets/shift_snags_data.csv').readAsStringSync();
  final rows = _parseMultiLineCsv(csvData);
  for (int i = 0; i < rows.length; i++) {
    final fields = rows[i];
    final plcTitle = fields.isNotEmpty ? fields[0].trim() : '';
    final hardwireTitle = fields.length > 2 ? fields[2].trim() : '';
    print('Row $i: PLC="$plcTitle", HARDWIRE="$hardwireTitle"');
  }
}

List<List<String>> _parseMultiLineCsv(String csvData) {
  final rows = <List<String>>[];
  final fields = <String>[];
  final buffer = StringBuffer();
  bool inQuotes = false;

  for (int i = 0; i < csvData.length; i++) {
    final char = csvData[i];
    if (char == '"') {
      if (inQuotes && i + 1 < csvData.length && csvData[i + 1] == '"') {
        buffer.write('"');
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (char == ',' && !inQuotes) {
      fields.add(buffer.toString());
      buffer.clear();
    } else if ((char == '\r' || char == '\n') && !inQuotes) {
      if (char == '\r' && i + 1 < csvData.length && csvData[i + 1] == '\n') {
        i++;
      }
      fields.add(buffer.toString());
      buffer.clear();
      if (fields.any((f) => f.trim().isNotEmpty)) {
        rows.add(List<String>.from(fields));
      }
      fields.clear();
    } else {
      buffer.write(char);
    }
  }
  fields.add(buffer.toString());
  if (fields.any((f) => f.trim().isNotEmpty)) {
    rows.add(List<String>.from(fields));
  }
  return rows;
}
