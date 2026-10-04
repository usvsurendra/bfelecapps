import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class WebFormViewer extends StatefulWidget {
  final String formUrl;

  const WebFormViewer({
    super.key,
    required this.formUrl,
  });

  @override
  State<WebFormViewer> createState() => _WebFormViewerState();
}

class _WebFormViewerState extends State<WebFormViewer> {
  late String _registeredViewId;

  @override
  void initState() {
    super.initState();
    _registeredViewId = 'google_form_view_${DateTime.now().millisecondsSinceEpoch}';

    // Google Forms URL with embedded=true parameter
    String url = widget.formUrl;
    if (!url.contains('embedded=true')) {
      url = url.contains('?') ? '$url&embedded=true' : '$url?embedded=true';
    }

    ui_web.platformViewRegistry.registerViewFactory(
      _registeredViewId,
      (int viewId) {
        final iframe = web.HTMLIFrameElement()
          ..src = url
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _registeredViewId);
  }
}
