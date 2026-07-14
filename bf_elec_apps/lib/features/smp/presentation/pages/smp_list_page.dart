import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:bf_elec_apps/features/smp/data/repositories/smp_repository.dart';
import 'package:bf_elec_apps/features/smp/domain/models/smp.dart';
import 'package:flutter/material.dart';

class SmpListPage extends StatefulWidget {
  const SmpListPage({super.key});

  @override
  State<SmpListPage> createState() => _SmpListPageState();
}

class _SmpListPageState extends State<SmpListPage> {
  final SmpRepository _repository = SmpRepository();
  List<SmpItem> _allItems = [];
  List<SmpItem> _filteredItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _lastUpdated = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItems();
    _searchController.addListener(_runSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadItems({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final items = await _repository.loadSmpItems(forceRefresh: forceRefresh);
      final lastUpdated = await _repository.getLastUpdatedTime();
      setState(() {
        _allItems = items;
        if (lastUpdated != null) {
          final dt = DateTime.parse(lastUpdated);
          _lastUpdated =
              '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
        } else {
          _lastUpdated = 'Never';
        }
        _runSearch();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load SMP documents.';
        _isLoading = false;
      });
    }
  }

  void _runSearch() {
    setState(() {
      _filteredItems =
          _repository.searchSmp(_allItems, _searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      appBar: AppBar(
        title: const Text('STANDARD MAINTENANCE PROCEDURE'),
        backgroundColor: AppTheme.pureWhite,
        foregroundColor: AppTheme.primaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Sync documents',
            onPressed: () => _loadItems(forceRefresh: true),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryBlue,
                strokeWidth: 3,
              ),
            )
          : _errorMessage != null
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
                          child: const Icon(Icons.error_outline_rounded,
                              size: 40, color: AppTheme.dangerRed),
                        ),
                        const SizedBox(height: 20),
                        Text(_errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppTheme.darkText,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => _loadItems(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
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
                    _buildSearchBar(),
                    Expanded(
                      child: _filteredItems.isEmpty
                          ? _buildEmptyState()
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: _filteredItems.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final item = _filteredItems[index];
                                return _SmpCard(
                                  item: item,
                                  index: index + 1,
                                );
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
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Found ${_filteredItems.length} of ${_allItems.length}',
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
            hintText: 'Search SMP documents...',
            prefixIcon: Icon(Icons.search_rounded, color: AppTheme.primaryBlue),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _searchController.clear();
                      _runSearch();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
            child: Icon(Icons.folder_off_rounded,
                size: 40, color: AppTheme.mediumGray),
          ),
          const SizedBox(height: 20),
          Text(
            'No SMP documents found.',
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
        style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: Colors.white,
            letterSpacing: 0.5),
      ),
    );
  }
}

class _SmpCard extends StatelessWidget {
  final SmpItem item;
  final int index;

  const _SmpCard({required this.item, required this.index});

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening: ${item.title}'),
              behavior: SnackBarBehavior.floating,
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
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.category,
                      style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.slateText,
                          height: 1.4),
                    ),
                  ],
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.lightGray,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.picture_as_pdf_rounded,
                    color: AppTheme.primaryBlue, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
