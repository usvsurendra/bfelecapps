import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bf_elec_apps/core/theme/app_theme.dart';
import '../../data/models/motor_model.dart';
import '../providers/motor_provider.dart';

class MotorSearchPage extends ConsumerWidget {
  const MotorSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMotors = ref.watch(motorsFutureProvider);
    final isAdvanced = ref.watch(isAdvancedSearchProvider);
    final filteredMotors = ref.watch(filteredMotorsProvider);

    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      appBar: AppBar(
        title: const Text('Motor Name Plate Details', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.pureWhite,
        elevation: 0,
      ),
      body: asyncMotors.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
        data: (allMotors) {
          return Column(
            children: [
              _buildSearchHeader(context, ref, isAdvanced, filteredMotors.length),
              if (isAdvanced) _buildAdvancedFilters(context, ref),
              if (!isAdvanced) _buildSimpleSearch(context, ref),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredMotors.length,
                  itemBuilder: (context, index) {
                    final motor = filteredMotors[index];
                    return _buildMotorCard(context, motor);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context, WidgetRef ref, bool isAdvanced, int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'We have found $count motors.',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
              ),
              Row(
                children: [
                  const Text('Advanced', style: TextStyle(fontWeight: FontWeight.w600)),
                  Switch(
                    value: isAdvanced,
                    activeColor: AppTheme.goldAccent,
                    onChanged: (val) {
                      ref.read(isAdvancedSearchProvider.notifier).toggle(val);
                      // Clear simple search when toggling to advanced
                      if (val) {
                        ref.read(motorSearchQueryProvider.notifier).setQuery('');
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleSearch(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search keywords separated by space...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
          filled: true,
          fillColor: AppTheme.pureWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onChanged: (val) => ref.read(motorSearchQueryProvider.notifier).setQuery(val),
      ),
    );
  }

  Widget _buildAdvancedFilters(BuildContext context, WidgetRef ref) {
    final uniqueVals = ref.watch(uniqueValuesProvider);
    
    return Container(
      color: AppTheme.pureWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.35),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildRangeInput('KW Min', (val) => ref.read(filterKwMinProvider.notifier).setFilter(double.tryParse(val))),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildRangeInput('KW Max', (val) => ref.read(filterKwMaxProvider.notifier).setFilter(double.tryParse(val))),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildRangeInput('RPM Min', (val) => ref.read(filterRpmMinProvider.notifier).setFilter(double.tryParse(val))),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildRangeInput('RPM Max', (val) => ref.read(filterRpmMaxProvider.notifier).setFilter(double.tryParse(val))),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildDropdown('Frame', ref.watch(filterFrameProvider), uniqueVals['frames'] ?? [], (val) => ref.read(filterFrameProvider.notifier).setFilter(val))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildDropdown('Mounting', ref.watch(filterMountingProvider), uniqueVals['mountings'] ?? [], (val) => ref.read(filterMountingProvider.notifier).setFilter(val))),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildDropdown('Area', ref.watch(filterAreaProvider), uniqueVals['areas'] ?? [], (val) => ref.read(filterAreaProvider.notifier).setFilter(val))),
                  const SizedBox(width: 8),
                  Expanded(child: _buildDropdown('Make', ref.watch(filterMakeProvider), uniqueVals['makes'] ?? [], (val) => ref.read(filterMakeProvider.notifier).setFilter(val))),
                ],
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    ref.read(filterKwMinProvider.notifier).setFilter(null);
                    ref.read(filterKwMaxProvider.notifier).setFilter(null);
                    ref.read(filterRpmMinProvider.notifier).setFilter(null);
                    ref.read(filterRpmMaxProvider.notifier).setFilter(null);
                    ref.read(filterFrameProvider.notifier).setFilter(null);
                    ref.read(filterMountingProvider.notifier).setFilter(null);
                    ref.read(filterAreaProvider.notifier).setFilter(null);
                    ref.read(filterMakeProvider.notifier).setFilter(null);
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Filters'),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.dangerRed),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRangeInput(String label, Function(String) onChanged) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildDropdown(String label, String? currentValue, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        value: currentValue,
        items: [
          const DropdownMenuItem(value: null, child: Text('Any')),
          ...items.map((e) => DropdownMenuItem(value: e, child: Text(e))),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildMotorCard(BuildContext context, MotorModel motor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(motor.eqptName.isNotEmpty ? motor.eqptName : 'Unknown Equipment', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('KW: ${motor.kw}  |  RPM: ${motor.speed}'),
              Text('Area: ${motor.area}  |  Make: ${motor.make}'),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.primaryBlue),
        onTap: () {
          context.push('/motors/details', extra: motor);
        },
      ),
    );
  }
}
