import 'dart:io';
import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:bf_elec_apps/core/widgets/responsive_scaffold.dart';
import 'package:bf_elec_apps/core/offline/offline_download_button.dart';
import 'package:bf_elec_apps/features/motor_details/data/repositories/motor_repository.dart';
import 'package:bf_elec_apps/features/motor_details/domain/models/motor.dart';
import 'package:bf_elec_apps/features/motor_details/presentation/pages/name_plate_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class MotorSearchPage extends StatefulWidget {
  const MotorSearchPage({super.key});

  @override
  State<MotorSearchPage> createState() => _MotorSearchPageState();
}

class _MotorSearchPageState extends State<MotorSearchPage> {
  final MotorRepository _repository = MotorRepository();
  
  List<Motor> _allMotors = [];
  List<Motor> _filteredMotors = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _lastUpdated = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_runSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final motors = await _repository.loadMotors(forceRefresh: forceRefresh);
      final lastUpdated = await _repository.getLastUpdatedTime();

      setState(() {
        _allMotors = motors;
        
        if (lastUpdated != null) {
          final dt = DateTime.parse(lastUpdated);
          _lastUpdated = '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
        } else {
          _lastUpdated = 'Never';
        }

        _runSearch();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load spreadsheet database.\nEnsure you have an internet connection.';
        _isLoading = false;
      });
    }
  }

  void _runSearch() {
    setState(() {
      _filteredMotors = _repository.searchMotors(
        _allMotors,
        _searchController.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      currentRoute: '/dashboard/motor-details',
      title: 'Motor Details',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue, strokeWidth: 3))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.error_outline_rounded, size: 40, color: AppTheme.dangerRed),
                        ),
                        const SizedBox(height: 20),
                        Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => _loadData(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: AppTheme.pureWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    _buildStatusBar(),
                    if (!kIsWeb && Platform.isAndroid)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: OfflineDownloadButton(
                          title: 'Motor Nameplate Details',
                          fileName: 'motor_data_offline.csv',
                          downloadUrls: [MotorRepository.csvUrl],
                          onComplete: () async {
                            _loadData(forceRefresh: true);
                          },
                        ),
                      ),
                    _buildSearchBar(),
                    Expanded(
                      child: _filteredMotors.isEmpty
                          ? _buildEmptyState()
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredMotors.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final motor = _filteredMotors[index];
                                return _MotorCard(motor: motor, index: index + 1);
                              },
                            ),
                    ),
                    _buildFooter(),
                  ],
                ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      color: AppTheme.pureWhite,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Found ${_filteredMotors.length} of ${_allMotors.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            'Synced: $_lastUpdated',
            style: TextStyle(fontSize: 11, color: AppTheme.slateText),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppTheme.pureWhite,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderGray),
          boxShadow: [
            BoxShadow(
              color: AppTheme.deepNavy.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by equipment, make, area...',
            prefixIcon: Icon(Icons.search_rounded, color: AppTheme.primaryBlue),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.search_off_rounded, size: 40, color: AppTheme.mediumGray),
          ),
          const SizedBox(height: 20),
          Text(
            'No motors match your search criteria.',
            style: TextStyle(color: AppTheme.slateText, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        gradient: AppTheme.heroGradient,
      ),
      child: const Text(
        'COPY RIGHT @ RINL, VSP',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white, letterSpacing: 0.5),
      ),
    );
  }
}

class _MotorCard extends StatelessWidget {
  final Motor motor;
  final int index;

  const _MotorCard({required this.motor, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderGray),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepNavy.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NamePlatePage(
                details: motor.toMap(),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      motor.eqptName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'KW: ${motor.kw} | SPEED: ${motor.speed} RPM | MAKE: ${motor.make}\nFRAME: ${motor.frame} | AREA: ${motor.area}',
                      style: TextStyle(fontSize: 12, color: AppTheme.slateText, height: 1.4),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.primaryBlue, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
