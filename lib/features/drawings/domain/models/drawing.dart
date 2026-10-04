/// Model representing a single drawing entry from the spreadsheet.
class Drawing {
  final String title;
  final String drawingLink;
  final String iconUrl;

  const Drawing({
    required this.title,
    required this.drawingLink,
    required this.iconUrl,
  });

  /// Parse a CSV row into a Drawing object.
  /// Handles quoted fields (e.g., titles containing commas).
  factory Drawing.fromCsvRow(String row) {
    final fields = _parseCsvRow(row);
    return Drawing(
      title: fields.isNotEmpty ? fields[0].trim() : '',
      drawingLink: fields.length > 1 ? fields[1].trim() : '',
      iconUrl: fields.length > 2 ? fields[2].trim() : '',
    );
  }

  /// Determines the area/category prefix from the title.
  String get area {
    final upper = title.toUpperCase();
    if (upper.startsWith('BF1')) return 'BF1';
    if (upper.startsWith('BF2')) return 'BF2';
    if (upper.startsWith('BF3')) return 'BF3';
    if (upper.startsWith('BHS 1') || upper.startsWith('BHS1')) return 'BHS1&2';
    if (upper.startsWith('BHS 2') || upper.startsWith('BHS2')) return 'BHS1&2';
    if (upper.startsWith('BHS 3') || upper.startsWith('BHS3')) return 'BHS3';
    if (upper.startsWith('LRS') ||
        upper.startsWith('PSY') ||
        upper.startsWith('SSY') ||
        upper.startsWith('PCM') ||
        upper.startsWith('TILTING') ||
        upper.startsWith('SCHNEIDER') ||
        upper.startsWith('NITROGEN')) {
      return 'AUX.';
    }
    return 'OTHER';
  }

  /// Safe file name for offline PDF storage.
  String get fileName {
    final safe = title.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    return '${area}_$safe';
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
