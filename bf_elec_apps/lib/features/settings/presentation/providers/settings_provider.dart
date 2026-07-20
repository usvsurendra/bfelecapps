import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models/settings_item.dart';
import '../../domain/models/settings_detail_item.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final settingsItemsProvider = FutureProvider<List<SettingsItem>>((ref) async {
  final repository = ref.read(settingsRepositoryProvider);
  return repository.getSettingsItems();
});

final settingsDetailProvider = FutureProvider.family<List<SettingsDetailItem>, String>((ref, url) async {
  final repository = ref.read(settingsRepositoryProvider);
  return repository.getSettingsDetails(url);
});
