import 'dart:io';
import 'package:bf_elec_apps/core/offline/offline_manager.dart';
import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  int _downloadedCount = 0;
  int _totalToDownload = 0;
  int? _existingCount;

  @override
  void initState() {
    super.initState();
    _checkExistingDownloads();
  }

  @override
  void didUpdateWidget(PdfOfflineDownloadButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.drawingIds != widget.drawingIds) {
      _checkExistingDownloads();
    }
  }

  Future<void> _checkExistingDownloads() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      final pdfDir = await OfflineManager.getPdfDir();
      int count = 0;
      for (final id in widget.drawingIds) {
        final file = File('${pdfDir.path}/$id.pdf');
        if (await file.exists()) {
          count++;
        }
      }
      if (mounted) {
        setState(() {
          _existingCount = count;
        });
      }
    } catch (_) {}
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _statusText = 'Calculating size...';
    });

    try {
      final pdfDir = await OfflineManager.getPdfDir();
      final missingUrls = <String>[];
      final missingIds = <String>[];

      for (int i = 0; i < widget.pdfUrls.length; i++) {
        final id = widget.drawingIds[i];
        final url = widget.pdfUrls[i];
        final file = File('${pdfDir.path}/$id.pdf');
        if (!await file.exists()) {
          missingUrls.add(url);
          missingIds.add(id);
        }
      }

      if (missingUrls.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isDownloading = false;
          _statusText = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('All ${widget.title} are already downloaded'), backgroundColor: AppTheme.successGreen),
        );
        return;
      }

      if (!mounted) return;

      if (!mounted) return;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.download_rounded, color: AppTheme.primaryBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Download PDFs for offline?', style: TextStyle(color: AppTheme.deepNavy, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Files to download: ${missingUrls.length} (Skipping ${widget.pdfUrls.length - missingUrls.length} already saved)'),
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
        _downloadedCount = 0;
        _totalToDownload = missingUrls.length;
      });

      for (int i = 0; i < missingUrls.length; i++) {
        final url = missingUrls[i];
        final drawingId = missingIds[i];

        try {
          final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
          if (response.statusCode == 200) {
            final file = File('${pdfDir.path}/$drawingId.pdf');
            await file.writeAsBytes(response.bodyBytes);
            final progress = missingUrls.isEmpty ? 1.0 : (i + 1) / missingUrls.length;
            setState(() {
              _progress = progress;
              _downloadedCount = i + 1;
            });
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
          _existingCount = widget.drawingIds.length;
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
    if (kIsWeb || !Platform.isAndroid) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.lightGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderGray),
        ),
        child: Row(
          children: [
            Icon(Icons.phone_android_rounded, size: 18, color: AppTheme.mediumGray),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Offline downloads available on Android app',
                style: TextStyle(color: AppTheme.slateText, fontWeight: FontWeight.w500, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

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
            if (_totalToDownload > 0)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$_downloadedCount out of $_totalToDownload downloaded',
                    style: TextStyle(fontSize: 12, color: AppTheme.slateText, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _startDownload,
          icon: const Icon(Icons.download_rounded),
          label: Text('Download ${widget.title} for Offline'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: AppTheme.pureWhite,
          ),
        ),
        if (_existingCount != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '$_existingCount of ${widget.drawingIds.length} ${widget.title.toLowerCase()} currently downloaded',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.slateText, fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }
}
