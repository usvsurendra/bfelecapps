import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:bf_elec_apps/core/widgets/responsive_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MaterialRequisitionPage extends StatefulWidget {
  const MaterialRequisitionPage({super.key});

  @override
  State<MaterialRequisitionPage> createState() => _MaterialRequisitionPageState();
}

class _MaterialRequisitionPageState extends State<MaterialRequisitionPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  static const String _formUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLSe0pyUdCV9d9RwiAPTwms6vVuQkcMlQnxl7ijKaw8klo_iA9g/viewform?pli=1&pli=1';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.contentBg)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_formUrl));
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      currentRoute: '/dashboard/material-requisition',
      title: 'Material Requisition',
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(
                color: AppTheme.primaryBlue,
                backgroundColor: AppTheme.lightGray,
              ),
            ),
        ],
      ),
    );
  }
}
