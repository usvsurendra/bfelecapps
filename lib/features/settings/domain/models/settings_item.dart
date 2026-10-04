class SettingsItem {
  final String imageUrl;
  final String name;
  final String excelLink;

  SettingsItem({
    required this.imageUrl,
    required this.name,
    required this.excelLink,
  });

  factory SettingsItem.fromCsvRow(List<dynamic> row) {
    return SettingsItem(
      imageUrl: row.isNotEmpty ? row[0].toString() : '',
      name: row.length > 1 ? row[1].toString() : '',
      excelLink: row.length > 2 ? row[2].toString() : '',
    );
  }
}
