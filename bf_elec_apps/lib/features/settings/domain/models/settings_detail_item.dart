class SettingsDetailItem {
  final Map<String, String> data;

  SettingsDetailItem({required this.data});

  factory SettingsDetailItem.fromCsvRow(List<dynamic> headers, List<dynamic> row) {
    Map<String, String> rowData = {};
    for (int i = 0; i < headers.length; i++) {
      String key = headers[i].toString().trim();
      String value = i < row.length ? row[i].toString().trim() : '';
      if (key.isNotEmpty) {
        rowData[key] = value;
      }
    }
    return SettingsDetailItem(data: rowData);
  }
}
