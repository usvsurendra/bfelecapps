import 'package:flutter/material.dart';

class WebPdfViewer extends StatelessWidget {
  final String pdfUrl;
  final String viewId;

  const WebPdfViewer({
    super.key,
    required this.pdfUrl,
    required this.viewId,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
