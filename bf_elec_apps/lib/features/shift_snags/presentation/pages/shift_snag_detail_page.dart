import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:bf_elec_apps/features/shift_snags/domain/models/shift_snag.dart';
import 'package:flutter/material.dart';

class ShiftSnagDetailPage extends StatelessWidget {
  final ShiftSnag snag;
  final bool showPLC;

  const ShiftSnagDetailPage({
    super.key,
    required this.snag,
    this.showPLC = true,
  });

  @override
  Widget build(BuildContext context) {
    final title = showPLC ? snag.plcTitle : snag.hardwireTitle;
    final htmlContent = showPLC ? snag.plcData : snag.hardwireData;

    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: showPLC ? AppTheme.infoBlue : AppTheme.goldAccent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              showPLC ? 'PLC' : 'HARDWIRE',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: showPLC
                      ? [AppTheme.infoBlue, AppTheme.primaryBlue]
                      : [AppTheme.goldAccent, const Color(0xFFD97706)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (showPLC ? AppTheme.infoBlue : AppTheme.goldAccent)
                        .withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    showPLC ? Icons.memory_rounded : Icons.cable_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          showPLC ? 'PLC SOLUTION' : 'HARDWIRE SOLUTION',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderGray),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.deepNavy.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _HtmlRenderer(html: htmlContent),
            ),
          ],
        ),
      ),
    );
  }
}

class _HtmlRenderer extends StatelessWidget {
  final String html;

  const _HtmlRenderer({required this.html});

  @override
  Widget build(BuildContext context) {
    final widgets = _parseBlockElements(html);
    if (widgets.isEmpty) {
      return Text(
        ShiftSnag.stripHtml(html),
        style: const TextStyle(fontSize: 15, height: 1.6, color: AppTheme.darkText),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  List<Widget> _parseBlockElements(String html) {
    final widgets = <Widget>[];
    final blockTags = ['h1', 'h2', 'h4', 'p', 'li'];
    int cursor = 0;
    int stepNumber = 0;

    while (cursor < html.length) {
      int bestStart = html.length;
      String? bestTag;

      for (final tag in blockTags) {
        final openPattern = RegExp('<$tag(\\s|>)', caseSensitive: false);
        final match = openPattern.firstMatch(html.substring(cursor));
        if (match != null && cursor + match.start < bestStart) {
          bestStart = cursor + match.start;
          bestTag = tag;
        }
      }

      if (bestTag == null) break;

      final closeTag = '</$bestTag>';
      final closeIdx = html.indexOf(closeTag, bestStart);
      if (closeIdx == -1) {
        cursor = bestStart + 1;
        continue;
      }

      final openTagEnd = html.indexOf('>', bestStart);
      if (openTagEnd == -1) {
        cursor = bestStart + 1;
        continue;
      }

      final innerHtml = html.substring(openTagEnd + 1, closeIdx);

      switch (bestTag) {
        case 'h1':
          widgets.add(_buildHeading(innerHtml, 20));
          break;
        case 'h2':
          widgets.add(_buildHeading(innerHtml, 17));
          break;
        case 'h4':
          stepNumber++;
          widgets.add(_buildStep(innerHtml, stepNumber));
          break;
        case 'p':
          final stripped = _stripTags(innerHtml).trim();
          if (stripped.isNotEmpty) {
            widgets.add(_buildParagraph(innerHtml));
          }
          break;
        case 'li':
          widgets.add(_buildListItem(innerHtml));
          break;
      }

      cursor = closeIdx + closeTag.length;
    }

    return widgets;
  }

  Widget _buildHeading(String innerHtml, double size) {
    final text = _stripTags(innerHtml).trim();
    final isBlue = innerHtml.contains('#0000ff');
    final color = isBlue ? AppTheme.infoBlue : AppTheme.primaryBlue;

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String innerHtml, int stepNum) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(right: 12, top: 2),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(
              child: Text(
                '$stepNum',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ),
          ),
          Expanded(child: _buildRichText(innerHtml)),
        ],
      ),
    );
  }

  Widget _buildParagraph(String innerHtml) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: _buildRichText(innerHtml),
    );
  }

  Widget _buildListItem(String innerHtml) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, right: 12, left: 4),
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppTheme.accentCyan,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(child: _buildRichText(innerHtml)),
        ],
      ),
    );
  }

  Widget _buildRichText(String html) {
    final spans = <TextSpan>[];

    String decoded = html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"');

    final colorSpanRegex = RegExp(
      r'<span[^>]*color:\s*([#a-fA-F0-9]+)[^>]*>(.*?)</span>',
      caseSensitive: false,
      dotAll: true,
    );

    int cursor = 0;
    for (final match in colorSpanRegex.allMatches(decoded)) {
      if (match.start > cursor) {
        final before = _stripTags(decoded.substring(cursor, match.start));
        if (before.isNotEmpty) {
          spans.add(TextSpan(
            text: before,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.darkText,
              fontWeight: FontWeight.w600,
              height: 1.6,
            ),
          ));
        }
      }

      final colorHex = match.group(1)!.toLowerCase();
      final content = _stripTags(match.group(2) ?? '');
      Color color = AppTheme.darkText;
      if (colorHex == '#ff0000') color = AppTheme.dangerRed;
      if (colorHex == '#0000ff') color = AppTheme.infoBlue;
      if (colorHex == '#000000') color = AppTheme.darkText;

      if (content.isNotEmpty) {
        spans.add(TextSpan(
          text: content,
          style: TextStyle(
            fontSize: 15,
            color: color,
            fontWeight: FontWeight.bold,
            height: 1.6,
            backgroundColor: color == AppTheme.dangerRed
                ? const Color(0xFFFEE2E2)
                : null,
          ),
        ));
      }

      cursor = match.end;
    }

    if (cursor < decoded.length) {
      final remaining = _stripTags(decoded.substring(cursor));
      if (remaining.isNotEmpty) {
        spans.add(TextSpan(
          text: remaining,
          style: const TextStyle(
            fontSize: 15,
            color: AppTheme.darkText,
            fontWeight: FontWeight.w600,
            height: 1.6,
          ),
        ));
      }
    }

    if (spans.isEmpty) {
      final plain = _stripTags(decoded);
      return Text(plain,
          style: const TextStyle(fontSize: 15, height: 1.6, color: AppTheme.darkText));
    }

    return RichText(text: TextSpan(children: spans));
  }

  String _stripTags(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }
}
