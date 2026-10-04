import 'package:flutter/material.dart';
import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:bf_elec_apps/core/widgets/responsive_scaffold.dart';
import '../../domain/models/settings_item.dart';

class SettingsDetailPage extends StatelessWidget {
  final SettingsItem item;

  const SettingsDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      currentRoute: '/dashboard/settings/detail',
      title: item.name,
      body: Container(
        color: AppTheme.contentBg,
        width: double.infinity,
        height: double.infinity,
        child: item.imageUrl.isNotEmpty
            ? InteractiveViewer(
                panEnabled: true,
                minScale: 1.0,
                maxScale: 5.0,
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryBlue,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'No image available',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
