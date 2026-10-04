/// Model representing a single shift snag entry from the spreadsheet.
/// Each snag has a PLC complaint/solution and optionally a Hardwire complaint/solution.
class ShiftSnag {
  final String plcTitle;
  final String plcData; // HTML-formatted solution
  final String hardwireTitle;
  final String hardwireData; // HTML-formatted solution

  const ShiftSnag({
    required this.plcTitle,
    required this.plcData,
    required this.hardwireTitle,
    required this.hardwireData,
  });

  /// Parse a CSV row into a ShiftSnag object.
  /// The CSV has 4 columns: PLC, PLCDATA, HARDWIRE, HARDWIREDATA
  /// Fields may contain HTML with commas, so we need robust CSV parsing.
  factory ShiftSnag.fromCsvFields(List<String> fields) {
    return ShiftSnag(
      plcTitle: fields.isNotEmpty ? fields[0].trim() : '',
      plcData: fields.length > 1 ? fields[1].trim() : '',
      hardwireTitle: fields.length > 2 ? fields[2].trim() : '',
      hardwireData: fields.length > 3 ? fields[3].trim() : '',
    );
  }

  /// Strip HTML tags from solution data to produce plain text for display.
  static String stripHtml(String html) {
    // Remove HTML tags
    String text = html.replaceAll(RegExp(r'<[^>]*>'), '');
    // Decode common HTML entities
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    // Collapse multiple whitespace/newlines
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  /// Get a plain-text preview of the PLC solution.
  String get plcPreview => stripHtml(plcData);

  /// Get a plain-text preview of the Hardwire solution.
  String get hardwirePreview => stripHtml(hardwireData);

  /// Check if this snag has PLC data.
  bool get hasPlcData => plcTitle.isNotEmpty && plcTitle != 'ok';

  /// Check if this snag has Hardwire data.
  bool get hasHardwireData => hardwireTitle.isNotEmpty;
}
