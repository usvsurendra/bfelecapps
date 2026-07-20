import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:bf_elec_apps/core/widgets/responsive_scaffold.dart';
import '../providers/settings_provider.dart';
import '../../domain/models/settings_item.dart';

class SettingsListPage extends ConsumerStatefulWidget {
  const SettingsListPage({super.key});

  @override
  ConsumerState<SettingsListPage> createState() => _SettingsListPageState();
}

class _SettingsListPageState extends ConsumerState<SettingsListPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final settingsAsyncValue = ref.watch(settingsItemsProvider);

    return ResponsiveScaffold(
      currentRoute: '/dashboard/settings',
      title: 'Settings & Parameters',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderGray),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.deepNavy.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search parameter...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.slateText),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          Expanded(
            child: settingsAsyncValue.when(
              data: (items) {
                final filteredItems = items.where((item) {
                  return item.name.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredItems.isEmpty) {
                  return const Center(
                    child: Text('No parameters found.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return _SettingsCard(item: item);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryBlue),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load parameters.',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(settingsItemsProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final SettingsItem item;

  const _SettingsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepNavy.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 52,
              height: 52,
              child: item.imageUrl.isNotEmpty
                  ? Image.network(
                      item.imageUrl,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.lightGray,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.settings_rounded,
                          size: 28,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    )
                  : Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.lightGray,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.settings_rounded,
                        size: 28,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
            ),
          ),
          title: Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.darkText),
          ),
          trailing: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.chevron_right_rounded, color: AppTheme.primaryBlue, size: 20),
          ),
          onTap: () {
            context.push('/dashboard/settings/detail', extra: item);
          },
        ),
      ),
    );
  }
}
