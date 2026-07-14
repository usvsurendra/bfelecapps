import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class NamePlatePage extends StatelessWidget {
  final Map<String, String> details;

  const NamePlatePage({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      appBar: AppBar(
        title: const Text('Name Plate Details'),
        backgroundColor: AppTheme.pureWhite,
        foregroundColor: AppTheme.primaryBlue,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'NAME PLATE PAGE',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.deepNavy,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderGray),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.deepNavy.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ListView(
                children: details.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 140,
                          child: Text(
                            e.key,
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.darkText, fontSize: 14),
                          ),
                        ),
                        const Text(': ', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.darkText)),
                        Expanded(
                          child: Text(e.value, style: const TextStyle(color: AppTheme.slateText)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text('Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: AppTheme.pureWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
