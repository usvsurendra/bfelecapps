import 'dart:io';
import 'package:bf_elec_apps/core/offline/offline_manager.dart';
import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawingPdfPage extends StatefulWidget {
  final String title;
  final String pdfUrl;
  final String drawingId;

  const DrawingPdfPage({
    super.key,
    required this.title,
    required this.pdfUrl,
    this.drawingId = '',
  });

  @override
  State<DrawingPdfPage> createState() => _DrawingPdfPageState();
}

class _DrawingPdfPageState extends State<DrawingPdfPage> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _isOffline = false;
  
  File? _pdfFile;
  
  // Search state
  final PdfViewerController _pdfViewerController = PdfViewerController();
  PdfTextSearchResult _searchResult = PdfTextSearchResult();
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _downloadCurrentPdfForOffline() async {
    if (_pdfFile == null || widget.drawingId.isEmpty) return;
    try {
      final pdfDir = await OfflineManager.getPdfDir();
      final offlineFile = File('${pdfDir.path}/${widget.drawingId}.pdf');
      await _pdfFile!.copy(offlineFile.path);
      if (mounted) {
        setState(() => _isOffline = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF saved for offline use'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save PDF: $e'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pdfViewerController.dispose();
    _searchResult.removeListener(_onSearchResultUpdated);
    super.dispose();
  }

  void _onSearchResultUpdated() {
    if (mounted) setState(() {});
  }

  Future<void> _loadPdf() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      _pdfFile = null;
      _isOffline = false;
      _searchResult.clear();
      _isSearching = false;
    });

    try {
      if (widget.drawingId.isNotEmpty && OfflineManager.isOfflineSupported) {
        final localFile = await OfflineManager.getPdfFile(widget.drawingId);
        if (localFile != null && await localFile.exists()) {
          _pdfFile = localFile;
          _isOffline = true;
          if (mounted) setState(() => _isLoading = false);
          return;
        }
      }

      if (widget.pdfUrl.isNotEmpty) {
        if (!kIsWeb) {
          // Download to temp file to support "Save Offline" later
          await _tryDownloadAndOpenPdf(Uri.parse(widget.pdfUrl));
        } else {
          // On Web, we can just use network URL natively through SfPdfViewer
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'No PDF available';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _tryDownloadAndOpenPdf(Uri uri) async {
    try {
      final response = await http.get(
        uri,
        headers: const {'User-Agent': 'Mozilla/5.0 BFELECAPPS'},
      ).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        final tempDir = await Directory.systemTemp.createTemp('bfelec_');
        final tempFile = File('${tempDir.path}/${widget.drawingId.isEmpty ? "drawing" : widget.drawingId}.pdf');
        await tempFile.writeAsBytes(response.bodyBytes);
        _pdfFile = tempFile;
        if (mounted) setState(() => _isLoading = false);
      } else {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Unable to download PDF';
            _isLoading = false;
          });
        }
      }
    } on SocketException catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Network unavailable. Please check your internet connection.';
          _isLoading = false;
        });
      }
    } on HttpException catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Network error. Please check your internet connection.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: AppTheme.darkText),
                decoration: const InputDecoration(
                  hintText: 'Search in PDF...',
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (value) async {
                  if (value.isNotEmpty) {
                    _searchResult.removeListener(_onSearchResultUpdated);
                    _searchResult = await _pdfViewerController.searchText(value);
                    _searchResult.addListener(_onSearchResultUpdated);
                    if (mounted) setState(() {});
                  }
                },
              )
            : Text(widget.title),
        backgroundColor: AppTheme.pureWhite,
        foregroundColor: AppTheme.primaryBlue,
        elevation: 0,
        actions: [
          if (_isSearching && _searchResult.hasResult) ...[
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_up_rounded),
              onPressed: () {
                _searchResult.previousInstance();
                setState(() {});
              },
            ),
            Center(
              child: Text(
                '${_searchResult.currentInstanceIndex}/${_searchResult.totalInstanceCount}',
                style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              onPressed: () {
                _searchResult.nextInstance();
                setState(() {});
              },
            ),
          ],
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            tooltip: _isSearching ? 'Close Search' : 'Search',
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchResult.removeListener(_onSearchResultUpdated);
                  _searchResult.clear();
                  _searchController.clear();
                }
              });
            },
          ),
          if (!kIsWeb && Platform.isAndroid && !_isOffline && _pdfFile != null && widget.drawingId.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Save Offline',
              onPressed: _downloadCurrentPdfForOffline,
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reload',
            onPressed: _loadPdf,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return _buildErrorState();
    }

    if (_isLoading) {
      return Container(
        color: AppTheme.softWhite,
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue, strokeWidth: 3),
        ),
      );
    }

    if (widget.pdfUrl.isEmpty && (widget.drawingId.isEmpty || _pdfFile == null)) {
      return _buildEmptyState();
    }

    if (!kIsWeb && _pdfFile != null) {
      return SfPdfViewer.file(
        _pdfFile!,
        controller: _pdfViewerController,
        canShowScrollHead: false,
        canShowScrollStatus: false,
        currentSearchTextHighlightColor: Colors.orange.withValues(alpha: 0.6),
        otherSearchTextHighlightColor: Colors.yellow.withValues(alpha: 0.3),
        onDocumentLoadFailed: (details) {
          if (mounted) {
            setState(() {
              _hasError = true;
              _errorMessage = details.description;
            });
          }
    } else if (kIsWeb && widget.pdfUrl.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, size: 40, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 24),
              Text(
                'Open Drawing',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.deepNavy,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'For the web version, this PDF drawing will securely open in a new browser tab.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.slateText),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  launchUrl(
                    Uri.parse(widget.pdfUrl),
                    mode: LaunchMode.externalApplication,
                  );
                },
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open PDF Drawing'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: AppTheme.pureWhite,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return _buildEmptyState();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(Icons.picture_as_pdf_rounded, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepNavy,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No PDF link available for this drawing.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppTheme.slateText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
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
              child: const Icon(Icons.wifi_off_rounded, size: 40, color: AppTheme.dangerRed),
            ),
            const SizedBox(height: 20),
            Text(
              'Unable to load drawing',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepNavy,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'The PDF may be unavailable or the network connection is weak.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppTheme.slateText),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loadPdf,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: AppTheme.pureWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
