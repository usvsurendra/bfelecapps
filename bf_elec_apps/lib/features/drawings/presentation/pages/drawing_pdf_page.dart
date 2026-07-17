import 'dart:convert';
import 'package:bf_elec_apps/core/offline/offline_manager.dart';
import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            // On web the page finishes as soon as the wrapper HTML loads;
            // the inner <iframe> then streams the PDF. Hide the overlay here.
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = error.description;
                _isLoading = false;
              });
            }
          },
        ),
      );
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      if (widget.drawingId.isNotEmpty && OfflineManager.isOfflineSupported) {
        final localFile = await OfflineManager.getPdfFile(widget.drawingId);
        if (localFile != null && await localFile.exists()) {
          await _controller.loadRequest(Uri.file(localFile.path));
          if (mounted) setState(() => _isLoading = false);
          return;
        }
      }

      if (widget.pdfUrl.isNotEmpty) {
        final uri = Uri.parse(widget.pdfUrl);
        if (kIsWeb) {
          // webview_flutter_web renders an <iframe>; a raw binary PDF does not
          // display inside it on some browsers. Wrap the PDF in a Google Docs viewer.
          final googleDocsUrl = 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(uri.toString())}';
          final html = '''
            <!DOCTYPE html>
            <html>
              <head>
                <meta charset="utf-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <style>
                  html, body { margin: 0; padding: 0; height: 100%; background: #fff; }
                  iframe { display: block; width: 100%; height: 100%; border: 0; }
                </style>
              </head>
              <body>
                <iframe src="$googleDocsUrl" allow="fullscreen"></iframe>
              </body>
            </html>
          ''';
          await _controller.loadHtmlString(html);
        } else {
          await _controller.loadRequest(uri);
        }
        if (mounted) setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppTheme.pureWhite,
        foregroundColor: AppTheme.primaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reload',
            onPressed: _loadPdf,
          ),
          if (widget.pdfUrl.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.open_in_browser_rounded),
              tooltip: 'Open in browser',
              onPressed: () async {
                final uri = Uri.parse(widget.pdfUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
        ],
      ),
      body: widget.pdfUrl.isEmpty && (widget.drawingId.isEmpty || _hasError)
          ? _buildEmptyState()
          : _hasError
              ? _buildErrorState()
              : Stack(
                  children: [
                    Positioned.fill(
                      child: WebViewWidget(controller: _controller),
                    ),
                    if (_isLoading)
                      Container(
                        color: AppTheme.softWhite,
                        child: const Center(
                          child: CircularProgressIndicator(color: AppTheme.primaryBlue, strokeWidth: 3),
                        ),
                      ),
                  ],
                ),
    );
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
            Text(
              'No PDF link available for this drawing.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: AppTheme.slateText),
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
            Row(
              children: [
                Expanded(
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
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(widget.pdfUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.open_in_browser_rounded),
                    label: const Text('Browser'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      foregroundColor: AppTheme.pureWhite,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
