import 'package:flutter/foundation.dart';

@immutable
class SmpItem {
  final String id;
  final String title;
  final String category;
  final String fileUrl;
  final String? thumbnailUrl;
  final String description;

  const SmpItem({
    required this.id,
    required this.title,
    required this.category,
    required this.fileUrl,
    this.thumbnailUrl,
    this.description = '',
  });

  factory SmpItem.fromCsvRow(String row) {
    final fields = _parseCsvRow(row);
    return SmpItem(
      id: fields.isNotEmpty ? fields[0].trim() : '',
      title: fields.length > 1 ? fields[1].trim() : '',
      category: fields.length > 2 ? fields[2].trim() : '',
      fileUrl: fields.length > 3 ? fields[3].trim() : '',
      thumbnailUrl: fields.length > 4 ? fields[4].trim() : null,
      description: fields.length > 5 ? fields[5].trim() : '',
    );
  }

  static List<String> _parseCsvRow(String row) {
    final List<String> fields = [];
    bool inQuotes = false;
    final buffer = StringBuffer();

    for (int i = 0; i < row.length; i++) {
      final char = row[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        fields.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    fields.add(buffer.toString());
    return fields;
  }
}
