import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:bf_elec_apps/features/shift_snags/data/repositories/shift_snag_repository.dart';
import 'package:bf_elec_apps/features/shift_snags/domain/models/shift_snag.dart';
import 'package:bf_elec_apps/features/shift_snags/presentation/pages/shift_snag_detail_page.dart';
import 'package:flutter/material.dart';

class ShiftSnagsPage extends StatefulWidget {
  const ShiftSnagsPage({super.key});

  @override
  State<ShiftSnagsPage> createState() => _ShiftSnagsPageState();
}

class _ShiftSnagsPageState extends State<ShiftSnagsPage>
    with SingleTickerProviderStateMixin {
  final ShiftSnagRepository _repository = ShiftSnagRepository();
  final TextEditingController _searchController = TextEditingController();

  List<ShiftSnag> _allSnags = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSnags();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSnags() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final snags = await _repository.loadSnags();
      setState(() {
        _allSnags = snags;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load snags: $e';
        _isLoading = false;
      });
    }
  }

  List<ShiftSnag> get _filteredSnags {
    if (_searchQuery.isEmpty) return _allSnags;
    final query = _searchQuery.toLowerCase();
    return _allSnags.where((s) {
      return s.plcTitle.toLowerCase().contains(query) ||
          s.hardwireTitle.toLowerCase().contains(query) ||
          s.plcPreview.toLowerCase().contains(query) ||
          s.hardwirePreview.toLowerCase().contains(query);
    }).toList();
  }

  List<ShiftSnag> get _plcSnags =>
      _filteredSnags.where((s) => s.plcData.isNotEmpty).toList();

  List<ShiftSnag> get _hardwireSnags =>
      _filteredSnags.where((s) => s.hasHardwireData).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SHIFT SNAGS',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, letterSpacing: 0.5),
            ),
            Text(
              'Common Complaints & Solutions',
              style: TextStyle(fontSize: 12, color: AppTheme.accentCyan, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh from online',
            onPressed: _loadSnags,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.steelBlue, AppTheme.deepNavy],
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.accentCyan,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: [
                Tab(
                  icon: const Icon(Icons.memory_rounded, size: 18),
                  text: 'PLC (${_isLoading ? "..." : _plcSnags.length})',
                ),
                Tab(
                  icon: const Icon(Icons.cable_rounded, size: 18),
                  text: 'HARDWIRE (${_isLoading ? "..." : _hardwireSnags.length})',
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppTheme.accentCyan, strokeWidth: 3),
                        SizedBox(height: 16),
                        Text('Loading shift snags...', style: TextStyle(color: AppTheme.slateText)),
                      ],
                    ),
                  )
                : _errorMessage != null
                    ? _buildError()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildSnagList(_plcSnags, isPLC: true),
                          _buildSnagList(_hardwireSnags, isPLC: false),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppTheme.deepNavy,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.deepNavy.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search complaints...',
            prefixIcon: Icon(Icons.search_rounded, color: AppTheme.primaryBlue),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
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
            Text(_errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.darkText)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadSnags,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: AppTheme.pureWhite),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnagList(List<ShiftSnag> snags, {required bool isPLC}) {
    if (snags.isEmpty) {
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
              child: Icon(
                isPLC ? Icons.memory_rounded : Icons.cable_rounded,
                size: 40,
                color: AppTheme.mediumGray,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No results for "$_searchQuery"'
                  : 'No ${isPLC ? "PLC" : "Hardwire"} snags found.',
              style: const TextStyle(color: AppTheme.slateText, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: snags.length,
      itemBuilder: (context, index) {
        final snag = snags[index];
        return _SnagCard(
          snag: snag,
          isPLC: isPLC,
          index: index + 1,
        );
      },
    );
  }
}

class _SnagCard extends StatelessWidget {
  final ShiftSnag snag;
  final bool isPLC;
  final int index;

  const _SnagCard({
    required this.snag,
    required this.isPLC,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final title = isPLC ? snag.plcTitle : snag.hardwireTitle;
    final preview = isPLC ? snag.plcPreview : snag.hardwirePreview;
    final color = isPLC ? AppTheme.infoBlue : AppTheme.goldAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ShiftSnagDetailPage(
                snag: snag,
                showPLC: isPLC,
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
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: color,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppTheme.darkText,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: color.withOpacity(0.3)),
                          ),
                          child: Text(
                            isPLC ? 'PLC' : 'HW',
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (preview.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.slateText,
                          height: 1.5,
                        ),
                      ),
                    ],
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
