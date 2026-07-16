import 'package:bf_elec_apps/core/theme/app_theme.dart'; 
import 'package:bf_elec_apps/features/auth/presentation/pages/splash_page.dart'; 
import 'package:flutter/material.dart'; 
 
void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const SplashPage(), 
    ); 
  } 
} 
