import 'dart:io';
import 'package:bf_elec_apps/core/offline/offline_manager.dart';
import 'package:bf_elec_apps/features/motor_details/domain/models/motor.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MotorRepository {
  static const String csvUrl =
      'https://docs.google.com/spreadsheets/d/1arV6uUAPIGF1BfkwCDKBb5qhtU699oEcURWYVG_pBRI/export?format=csv&gid=0';
  static const String _cachedCsvKey = 'cached_motor_csv';
  static const String _lastUpdatedKey = 'cached_motor_last_updated';

  Future<List<Motor>> loadMotors({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh) {
      try {
        final response = await http.get(Uri.parse(csvUrl)).timeout(
              const Duration(seconds: 10),
            );
        if (response.statusCode == 200) {
          final csvData = response.body;
          if (csvData.isNotEmpty && csvData.contains('EQPTNAME')) {
            await prefs.setString(_cachedCsvKey, csvData);
            await prefs.setString(
                _lastUpdatedKey, DateTime.now().toIso8601String());
            if (OfflineManager.isOfflineSupported) {
              await OfflineManager.saveMotorCsv(csvData);
            }
            return _parseCsv(csvData);
          }
        }
      } catch (e) {
        debugPrint('Online load failed: $e');
      }
    }

    String? cachedCsv = prefs.getString(_cachedCsvKey);
    if (cachedCsv == null || cachedCsv.isEmpty) {
      try {
        if (OfflineManager.isOfflineSupported) {
          final offlinePath = await OfflineManager.getMotorCsvPath();
          if (offlinePath != null) {
            final file = File(offlinePath);
            if (await file.exists()) {
              cachedCsv = await file.readAsString();
            }
          }
        }
      } catch (_) {}
    }

    if (cachedCsv == null || cachedCsv.isEmpty) {
      try {
        cachedCsv = await rootBundle.loadString('assets/motor_data.csv');
      } catch (e) {
        throw Exception('No motor data available. Please connect to the internet.');
      }
    }

    return _parseCsv(cachedCsv);
  }

  Future<String?> getLastUpdatedTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUpdatedKey);
  }

  List<Motor> _parseCsv(String csvString) {
    List<Motor> motors = [];
    List<List<String>> rows = [];
    List<String> currentRow = [];
    StringBuffer currentCell = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < csvString.length; i++) {
      int code = csvString.codeUnitAt(i);
      if (code == 34) {
        inQuotes = !inQuotes;
      } else if (code == 44 && !inQuotes) {
        currentRow.add(currentCell.toString());
        currentCell.clear();
      } else if ((code == 10 || code == 13) && !inQuotes) {
        if (code == 13 &&
            i + 1 < csvString.length &&
            csvString.codeUnitAt(i + 1) == 10) {
          i++;
        }
        currentRow.add(currentCell.toString());
        if (currentRow.isNotEmpty && currentRow.any((c) => c.isNotEmpty)) {
          rows.add(List.from(currentRow));
        }
        currentRow.clear();
        currentCell.clear();
      } else {
        currentCell.writeCharCode(code);
      }
    }

    if (currentCell.isNotEmpty || currentRow.isNotEmpty) {
      currentRow.add(currentCell.toString());
      rows.add(currentRow);
    }

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isNotEmpty && row[0].trim().toUpperCase() != 'EQPTNAME') {
        motors.add(Motor.fromCsvRow(row));
      }
    }

    return motors;
  }

  List<Motor> searchMotors(
    List<Motor> allMotors,
    String query, {
    bool isAdvance = false,
    String frame = '',
    String kw = '',
    String rpm = '',
    String mntng = '',
    String area = '',
    String make = '',
    bool filterByFrame = false,
    bool filterByKw = false,
    bool filterByRpm = false,
    bool filterByMntng = false,
    bool filterByArea = false,
    bool filterByMake = false,
  }) {
    if (!isAdvance) {
      if (query.trim().isEmpty) return allMotors;
      final keywords = query.toLowerCase().split(' ').where((k) => k.isNotEmpty);
      return allMotors.where((motor) {
        final textToSearch = '${motor.eqptName} ${motor.make} ${motor.area} ${motor.location} ${motor.frame}'
            .toLowerCase();
        return keywords.every((kw) => textToSearch.contains(kw));
      }).toList();
    }

    return allMotors.where((motor) {
      if (filterByFrame && frame.isNotEmpty) {
        if (!motor.frame.toLowerCase().contains(frame.toLowerCase())) {
          return false;
        }
      }
      if (filterByKw && kw.isNotEmpty) {
        if (!motor.kw.toLowerCase().contains(kw.toLowerCase())) {
          return false;
        }
      }
      if (filterByRpm && rpm.isNotEmpty) {
        final rpmLower = rpm.toLowerCase();
        if (rpmLower.contains('from') && rpmLower.contains('to')) {
          final parts = rpmLower.split(RegExp(r'from|to')).map((e) => e.trim()).toList();
          if (parts.length >= 3) {
            final minRpm = double.tryParse(parts[1]) ?? 0.0;
            final maxRpm = double.tryParse(parts[2]) ?? 99999.0;
            final motorRpm = double.tryParse(motor.speed) ?? -1.0;
            if (motorRpm < minRpm || motorRpm > maxRpm) {
              return false;
            }
          }
        } else {
          if (!motor.speed.toLowerCase().contains(rpmLower)) {
            return false;
          }
        }
      }
      if (filterByMntng && mntng.isNotEmpty && mntng.toUpperCase() != 'ANY' && mntng.toUpperCase() != 'ALL') {
        if (motor.mntng.toLowerCase() != mntng.toLowerCase()) {
          return false;
        }
      }
      if (filterByArea && area.isNotEmpty && area.toUpperCase() != 'ANY' && area.toUpperCase() != 'ALL') {
        if (motor.area.toLowerCase() != area.toLowerCase()) {
          return false;
        }
      }
      if (filterByMake && make.isNotEmpty && make.toUpperCase() != 'ANY' && make.toUpperCase() != 'ALL') {
        if (motor.make.toLowerCase() != make.toLowerCase()) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}
