import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class WebPdfViewer extends StatefulWidget {
  final String pdfUrl;
  final String viewId;

  const WebPdfViewer({
    super.key,
    required this.pdfUrl,
    required this.viewId,
  });

  @override
  State<WebPdfViewer> createState() => _WebPdfViewerState();
}

class _WebPdfViewerState extends State<WebPdfViewer> {
  late String _registeredViewId;

  @override
  void initState() {
    super.initState();
    final cleanId = widget.viewId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    _registeredViewId = 'pdf_view_${cleanId}_${DateTime.now().millisecondsSinceEpoch}';
    
    final embedUrl = 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(widget.pdfUrl)}';

    ui_web.platformViewRegistry.registerViewFactory(
      _registeredViewId,
      (int viewId) {
        // Parent container with relative positioning
        final container = web.HTMLDivElement();
        container.style.position = 'relative';
        container.style.width = '100%';
        container.style.height = '100%';
        container.style.overflow = 'hidden';

        // Embedded PDF iframe
        final iframe = web.HTMLIFrameElement();
        iframe.src = embedUrl;
        iframe.style.border = 'none';
        iframe.style.width = '100%';
        iframe.style.height = '100%';

        // HTML DOM mask element positioned directly over top-right corner to obscure and block the pop-out button
        final mask = web.HTMLDivElement();
        mask.style.position = 'absolute';
        mask.style.top = '0px';
        mask.style.right = '0px';
        mask.style.width = '60px';
        mask.style.height = '50px';
        mask.style.backgroundColor = '#323639';
        mask.style.zIndex = '999999';

        container.appendChild(iframe);
        container.appendChild(mask);
        return container;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _registeredViewId);
  }
}
