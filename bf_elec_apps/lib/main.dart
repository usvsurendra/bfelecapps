import 'package:bf_elec_apps/core/theme/app_theme.dart';
import 'package:bf_elec_apps/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:bf_elec_apps/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Skip Firebase on web until real API keys are configured in firebase_options.dart
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
    }
  }
  runApp(const BfElecApps());
}

class BfElecApps extends StatelessWidget {
  const BfElecApps({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blast Furnace Apps',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const DashboardPage(),
    );
  }
}
