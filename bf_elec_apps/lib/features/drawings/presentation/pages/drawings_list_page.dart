import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:bf_elec_apps/core/offline/pdf_offline_download_button.dart';
import 'package:bf_elec_apps/features/drawings/data/repositories/drawing_repository.dart';
import 'package:bf_elec_apps/features/drawings/domain/models/drawing.dart';
import 'package:bf_elec_apps/features/drawings/presentation/pages/drawing_pdf_page.dart';
import 'package:flutter/material.dart';

class DrawingsListPage extends StatefulWidget {
  const DrawingsListPage({super.key});

  @override
  State<DrawingsListPage> createState() => _DrawingsListPageState();
}

class _DrawingsListPageState extends State<DrawingsListPage> {
  bool _isAreaWise = false;
  String _searchQuery = '';
  String _selectedArea = 'BF1';
  List<Drawing> _allDrawings = [];
  bool _isLoading = true;
  String? _errorMessage;

  final DrawingRepository _repository = DrawingRepository();
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _areaTabs = [
    'BF1',
    'BF2',
    'BF3',
    'BHS1&2',
    'BHS3',
    'AUX.',
  ];

  @override
  void initState() {
    super.initState();
    _loadDrawings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDrawings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final drawings = await _repository.loadDrawings();
      setState(() {
        _allDrawings = drawings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load drawings: $e';
        _isLoading = false;
      });
    }
  }

  List<Drawing> get _filteredDrawings {
    List<Drawing> result = _allDrawings;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result
          .where((d) => d.title.toLowerCase().contains(query))
          .toList();
    }
    return result;
  }

  List<Drawing> get _areaFilteredDrawings {
    return _allDrawings.where((d) => d.area == _selectedArea).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      appBar: AppBar(
        title: Text(_isAreaWise ? 'AREA WISE LIST' : 'SINGLE LIST'),
        backgroundColor: AppTheme.pureWhite,
        foregroundColor: AppTheme.primaryBlue,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTopBar(),
          if (_allDrawings.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: PdfOfflineDownloadButton(
                title: 'Drawings',
                pdfUrls: _allDrawings.where((d) => d.drawingLink.isNotEmpty).map((d) => d.drawingLink).toList(),
                drawingIds: _allDrawings.where((d) => d.drawingLink.isNotEmpty).map((d) => d.fileName).toList(),
                onComplete: () async {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PDFs saved for offline use'), backgroundColor: AppTheme.successGreen),
                    );
                  }
                },
              ),
            ),
          if (_isAreaWise) _buildAreaTabs() else _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue, strokeWidth: 3))
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
                                child: const Icon(Icons.error_outline_rounded, size: 40, color: AppTheme.dangerRed),
                              ),
                              const SizedBox(height: 20),
                              Text(_errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: AppTheme.darkText)),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _loadDrawings,
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
                    : _isAreaWise
                        ? _buildAreaWiseList()
                        : _buildSingleList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final count = _isAreaWise
        ? _areaFilteredDrawings.length
        : _filteredDrawings.length;
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.heroGradient,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'BF ELEC. DRAWINGS',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 0.5),
          ),
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      '$count drawings',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _isAreaWise,
                    onChanged: (val) {
                      setState(() {
                        _isAreaWise = val;
                      });
                    },
                    activeThumbColor: AppTheme.pureWhite,
                    activeTrackColor: AppTheme.accentCyan,
                    inactiveThumbColor: AppTheme.pureWhite,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
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
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search drawings...',
            prefixIcon: Icon(Icons.search_rounded, color: AppTheme.primaryBlue),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleList() {
    final drawings = _filteredDrawings;
    if (drawings.isEmpty) {
      return Center(
        child: Text('No drawings found.',
            style: TextStyle(fontSize: 15, color: AppTheme.slateText, fontWeight: FontWeight.w600)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: drawings.length,
      itemBuilder: (context, index) {
        final drawing = drawings[index];
        return _DrawingTile(drawing: drawing);
      },
    );
  }

  Widget _buildAreaTabs() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _areaTabs
              .map(
                (area) => GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedArea = area;
                    });
                  },
                  child: _AreaTab(
                    title: area,
                    isSelected: _selectedArea == area,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildAreaWiseList() {
    final drawings = _areaFilteredDrawings;
    if (drawings.isEmpty) {
      return Center(
        child: Text('No drawings found for $_selectedArea.',
            style: const TextStyle(fontSize: 15, color: AppTheme.slateText, fontWeight: FontWeight.w600)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: drawings.length,
      itemBuilder: (context, index) {
        final drawing = drawings[index];
        return _DrawingTile(drawing: drawing);
      },
    );
  }
}

class _DrawingTile extends StatelessWidget {
  final Drawing drawing;

  const _DrawingTile({required this.drawing});

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
            color: AppTheme.deepNavy.withValues(alpha: 0.04),
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
              child: drawing.iconUrl.isNotEmpty
                  ? Image.network(
                      drawing.iconUrl,
                      width: 52,
                      height: 52,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.lightGray,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.architecture_rounded,
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
                      child: Icon(
                        Icons.architecture_rounded,
                        size: 28,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
            ),
          ),
          title: Text(
            drawing.title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.darkText),
          ),
          subtitle: Text(
            drawing.area,
            style: const TextStyle(color: AppTheme.slateText, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          trailing: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chevron_right_rounded, color: AppTheme.primaryBlue, size: 20),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DrawingPdfPage(
                  title: drawing.title,
                  pdfUrl: drawing.drawingLink,
                  drawingId: drawing.fileName,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AreaTab extends StatelessWidget {
  final String title;
  final bool isSelected;

  const _AreaTab({required this.title, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isSelected ? AppTheme.accentCyan : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}
