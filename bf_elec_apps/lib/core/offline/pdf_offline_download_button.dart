import 'dart:io';
import 'package:bf_elec_apps/core/offline/offline_manager.dart';
import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PdfOfflineDownloadButton extends StatefulWidget {
  final String title;
  final List<String> pdfUrls;
  final List<String> drawingIds;
  final Future<void> Function() onComplete;

  const PdfOfflineDownloadButton({
    super.key,
    required this.title,
    required this.pdfUrls,
    required this.drawingIds,
    required this.onComplete,
  });

  @override
  State<PdfOfflineDownloadButton> createState() => _PdfOfflineDownloadButtonState();
}

class _PdfOfflineDownloadButtonState extends State<PdfOfflineDownloadButton> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String? _statusText;

  Future<int> _getFileSize(String url) async {
    try {
      final response = await http.head(Uri.parse(url)).timeout(const Duration(seconds: 10));
      final contentLength = response.headers['content-length'];
      if (contentLength != null) {
        return int.tryParse(contentLength) ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _statusText = 'Calculating size...';
    });

    try {
      final sizes = <int>[];
      for (final url in widget.pdfUrls) {
        final size = await _getFileSize(url);
        sizes.add(size);
      }
      final totalBytes = sizes.fold<int>(0, (a, b) => a + b);
      final formattedTotal = await OfflineManager.formatBytes(totalBytes);

      if (!mounted) return;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.download_rounded, color: AppTheme.primaryBlue),
              const SizedBox(width: 12),
              Text('Download PDFs for offline?', style: TextStyle(color: AppTheme.deepNavy, fontWeight: FontWeight.w700)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estimated size: $formattedTotal'),
              const SizedBox(height: 8),
              Text('Files: ${widget.pdfUrls.length}'),
              const SizedBox(height: 8),
              Text('PDFs will be saved privately on this device.', style: TextStyle(color: AppTheme.slateText)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: AppTheme.pureWhite),
              child: const Text('Download'),
            ),
          ],
        ),
      );

      if (confirm != true) {
        setState(() {
          _isDownloading = false;
          _statusText = null;
        });
        return;
      }

      setState(() {
        _isDownloading = true;
        _progress = 0.0;
        _statusText = 'Downloading PDFs...';
      });

      final pdfDir = await OfflineManager.getPdfDir();
      for (int i = 0; i < widget.pdfUrls.length; i++) {
        final url = widget.pdfUrls[i];
        final drawingId = widget.drawingIds[i];

        try {
          final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
          if (response.statusCode == 200) {
            final file = File('${pdfDir.path}/$drawingId.pdf');
            await file.writeAsBytes(response.bodyBytes);
            final progress = widget.pdfUrls.isEmpty ? 1.0 : (i + 1) / widget.pdfUrls.length;
            setState(() => _progress = progress);
          }
        } catch (e) {
          debugPrint('Download failed for $url: $e');
        }
      }

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _progress = 1.0;
          _statusText = 'Download complete';
        });
        await widget.onComplete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${widget.title} saved for offline use'), backgroundColor: AppTheme.successGreen),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _statusText = 'Download failed';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e'), backgroundColor: AppTheme.dangerRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDownloading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.lightGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderGray),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue)),
                const SizedBox(width: 12),
                Expanded(child: Text(_statusText ?? 'Downloading...', style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w600))),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: _progress, minHeight: 6, borderRadius: BorderRadius.circular(3)),
          ],
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: _startDownload,
      icon: const Icon(Icons.download_rounded),
      label: Text('Download ${widget.title} for Offline'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.pureWhite,
      ),
    );
  }
}
