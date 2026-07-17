import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class OfflineManager {
  static const String _motorCsvName = 'motor_data_offline.csv';
  static const String _drawingsCsvName = 'drawings_data_offline.csv';
  static const String _drawingsPdfDir = 'drawings_pdfs';

  static bool get isOfflineSupported => !kIsWeb && Platform.isAndroid;

  static Future<Directory> get _appDir async {
    final dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    return dir;
  }

  static Future<Directory> getPdfDir() async {
    final dir = Directory((await _appDir).path + '/$_drawingsPdfDir');
    await dir.create(recursive: true);
    return dir;
  }

  static Future<Directory> get _pdfDir async => getPdfDir();

  static Future<File> _getFile(String fileName) async {
    final dir = await _appDir;
    return File('${dir.path}/$fileName');
  }

  static Future<bool> isMotorCsvDownloaded() async {
    final file = await _getFile(_motorCsvName);
    return await file.exists();
  }

  static Future<bool> isDrawingsCsvDownloaded() async {
    final file = await _getFile(_drawingsCsvName);
    return await file.exists();
  }

  static Future<File> getMotorCsvFile() async => await _getFile(_motorCsvName);
  static Future<File> getDrawingsCsvFile() async => await _getFile(_drawingsCsvName);

  static Future<String?> getMotorCsvPath() async {
    final file = await _getFile(_motorCsvName);
    if (await file.exists()) return file.path;
    return null;
  }

  static Future<String?> getDrawingsCsvPath() async {
    final file = await _getFile(_drawingsCsvName);
    if (await file.exists()) return file.path;
    return null;
  }

  static Future<File?> getPdfFile(String drawingId) async {
    final dir = await _pdfDir;
    final file = File('${dir.path}/$drawingId.pdf');
    if (await file.exists()) return file;
    return null;
  }

  static Future<List<FileSystemEntity>> getDownloadedPdfs() async {
    final dir = await _pdfDir;
    if (await dir.exists()) {
      return dir.listSync().whereType<File>().toList();
    }
    return [];
  }

  static Future<int> getDownloadedPdfCount() async {
    final files = await getDownloadedPdfs();
    return files.length;
  }

  static Future<int> calculateTotalPdfSize() async {
    final files = await getDownloadedPdfs();
    int total = 0;
    for (final file in files) {
      try {
        total += await (file as File).length();
      } catch (_) {}
    }
    return total;
  }

  static Future<int> getAvailableStorageBytes() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return 500 * 1024 * 1024;
    }
    return 1024 * 1024 * 1024;
  }

  static Future<String> formatBytes(int bytes) async {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  static Future<int> getFileSize(String url) async {
    try {
      final response = await http.head(Uri.parse(url)).timeout(const Duration(seconds: 10));
      final contentLength = response.headers['content-length'];
      if (contentLength != null) {
        return int.tryParse(contentLength) ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  static Future<void> saveMotorCsv(String csvData) async {
    final file = await _getFile(_motorCsvName);
    await file.writeAsString(csvData);
  }

  static Future<void> saveDrawingsCsv(String csvData) async {
    final file = await _getFile(_drawingsCsvName);
    await file.writeAsString(csvData);
  }

  static Future<void> clearAllOfflineData() async {
    try {
      final dir = await _appDir;
      await dir.delete(recursive: true);
      await dir.create(recursive: true);
    } catch (_) {}
  }

  static Future<void> clearPdfs() async {
    try {
      final dir = await _pdfDir;
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        await dir.create(recursive: true);
      }
    } catch (_) {}
  }
}
