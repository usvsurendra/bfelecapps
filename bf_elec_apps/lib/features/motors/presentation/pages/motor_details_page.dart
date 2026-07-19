import 'package:flutter/material.dart';
import 'package:bf_elec_apps/core/theme/app_theme.dart';
import '../../data/models/motor_model.dart';

class MotorDetailsPage extends StatelessWidget {
  final MotorModel motor;

  const MotorDetailsPage({super.key, required this.motor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      appBar: AppBar(
        title: const Text('Motor Name Plate Details', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.pureWhite,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.pureWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildRow('EQPT. NAME', motor.eqptName, isHeader: true),
                const Divider(height: 24, thickness: 1.5),
                _buildRow('KW', motor.kw),
                _buildRow('START_VOL', motor.statrVol),
                _buildRow('STARTOR_CUR', motor.statrCur),
                _buildRow('ROTOR_VOL', motor.rotorVol),
                _buildRow('ROTOR_CUR', motor.rotorCur),
                _buildRow('SPEED', motor.speed),
                _buildRow('MAKE', motor.make),
                _buildRow('MOUNTING', motor.mounting),
                _buildRow('BEARINGS DE', motor.de),
                _buildRow('BEARINGS NDE', motor.nde),
                _buildRow('FRAME', motor.frame),
                _buildRow('AREA', motor.area),
                _buildRow('LOCATION', motor.location),
                _buildRow('COUPLING', motor.coupling),
                const Divider(height: 24, thickness: 1.5),
                _buildRow('REMARKS', motor.remarks, isLast: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isHeader = false, bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isHeader ? 18 : 14,
                color: isHeader ? AppTheme.goldAccent : AppTheme.primaryBlue,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(':', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isNotEmpty ? value : '-',
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
                fontSize: isHeader ? 18 : 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
