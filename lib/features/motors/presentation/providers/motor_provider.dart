import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/motor_model.dart';
import '../../data/repositories/motor_repository.dart';

final motorRepositoryProvider = Provider((ref) => MotorRepository());

final motorsFutureProvider = FutureProvider<List<MotorModel>>((ref) async {
  final repository = ref.watch(motorRepositoryProvider);
  return await repository.fetchMotors();
});

class MotorSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setQuery(String q) => state = q;
}
final motorSearchQueryProvider = NotifierProvider<MotorSearchQueryNotifier, String>(() => MotorSearchQueryNotifier());

class IsAdvancedSearchNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle(bool val) => state = val;
}
final isAdvancedSearchProvider = NotifierProvider<IsAdvancedSearchNotifier, bool>(() => IsAdvancedSearchNotifier());

class DoubleFilterNotifier extends Notifier<double?> {
  @override
  double? build() => null;
  void setFilter(double? val) => state = val;
}
final filterKwMinProvider = NotifierProvider<DoubleFilterNotifier, double?>(() => DoubleFilterNotifier());
final filterKwMaxProvider = NotifierProvider<DoubleFilterNotifier, double?>(() => DoubleFilterNotifier());
final filterRpmMinProvider = NotifierProvider<DoubleFilterNotifier, double?>(() => DoubleFilterNotifier());
final filterRpmMaxProvider = NotifierProvider<DoubleFilterNotifier, double?>(() => DoubleFilterNotifier());

class StringFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setFilter(String? val) => state = val;
}
final filterFrameProvider = NotifierProvider<StringFilterNotifier, String?>(() => StringFilterNotifier());
final filterMountingProvider = NotifierProvider<StringFilterNotifier, String?>(() => StringFilterNotifier());
final filterAreaProvider = NotifierProvider<StringFilterNotifier, String?>(() => StringFilterNotifier());
final filterMakeProvider = NotifierProvider<StringFilterNotifier, String?>(() => StringFilterNotifier());

// Derived list of filtered motors
final filteredMotorsProvider = Provider<List<MotorModel>>((ref) {
  final asyncMotors = ref.watch(motorsFutureProvider);
  
  return asyncMotors.maybeWhen(
    data: (motors) {
      var filtered = List<MotorModel>.from(motors);

      final isAdvanced = ref.watch(isAdvancedSearchProvider);

      if (isAdvanced) {
        // Apply Advanced Filters
        final kwMin = ref.watch(filterKwMinProvider);
        final kwMax = ref.watch(filterKwMaxProvider);
        if (kwMin != null || kwMax != null) {
          filtered = filtered.where((m) {
            final kw = double.tryParse(m.kw) ?? 0.0;
            if (kwMin != null && kw < kwMin) return false;
            if (kwMax != null && kw > kwMax) return false;
            return true;
          }).toList();
        }

        final rpmMin = ref.watch(filterRpmMinProvider);
        final rpmMax = ref.watch(filterRpmMaxProvider);
        if (rpmMin != null || rpmMax != null) {
          filtered = filtered.where((m) {
            final rpm = double.tryParse(m.speed) ?? 0.0;
            if (rpmMin != null && rpm < rpmMin) return false;
            if (rpmMax != null && rpm > rpmMax) return false;
            return true;
          }).toList();
        }

        final frame = ref.watch(filterFrameProvider);
        if (frame != null && frame.isNotEmpty) {
          filtered = filtered.where((m) => m.frame.toLowerCase() == frame.toLowerCase()).toList();
        }

        final mounting = ref.watch(filterMountingProvider);
        if (mounting != null && mounting.isNotEmpty) {
          filtered = filtered.where((m) => m.mounting.toLowerCase() == mounting.toLowerCase()).toList();
        }

        final area = ref.watch(filterAreaProvider);
        if (area != null && area.isNotEmpty) {
          filtered = filtered.where((m) => m.area.toLowerCase() == area.toLowerCase()).toList();
        }

        final make = ref.watch(filterMakeProvider);
        if (make != null && make.isNotEmpty) {
          filtered = filtered.where((m) => m.make.toLowerCase() == make.toLowerCase()).toList();
        }

      } else {
        // Apply Simple Keyword Search
        final query = ref.watch(motorSearchQueryProvider).toLowerCase();
        if (query.isNotEmpty) {
          final keywords = query.split(' ').where((k) => k.isNotEmpty).toList();
          filtered = filtered.where((m) {
            final rowString = '${m.eqptName} ${m.kw} ${m.statrVol} ${m.statrCur} ${m.rotorVol} ${m.rotorCur} ${m.speed} ${m.make} ${m.mounting} ${m.de} ${m.nde} ${m.frame} ${m.area} ${m.location} ${m.coupling} ${m.remarks}'.toLowerCase();
            return keywords.every((kw) => rowString.contains(kw));
          }).toList();
        }
      }

      return filtered;
    },
    orElse: () => [],
  );
});

// Providers to extract unique values for dropdowns
final uniqueValuesProvider = Provider((ref) {
  final asyncMotors = ref.watch(motorsFutureProvider);
  return asyncMotors.maybeWhen(
    data: (motors) {
      final frames = motors.map((m) => m.frame).where((e) => e.isNotEmpty).toSet().toList()..sort();
      final mountings = motors.map((m) => m.mounting).where((e) => e.isNotEmpty).toSet().toList()..sort();
      final areas = motors.map((m) => m.area).where((e) => e.isNotEmpty).toSet().toList()..sort();
      final makes = motors.map((m) => m.make).where((e) => e.isNotEmpty).toSet().toList()..sort();
      return {
        'frames': frames,
        'mountings': mountings,
        'areas': areas,
        'makes': makes,
      };
    },
    orElse: () => {
        'frames': <String>[],
        'mountings': <String>[],
        'areas': <String>[],
        'makes': <String>[],
    },
  );
});
