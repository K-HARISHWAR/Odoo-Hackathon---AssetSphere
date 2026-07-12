import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF3F51B5); // Indigo
  static const Color primaryLight = Color(0xFF757DE8);
  static const Color primaryDark = Color(0xFF002984);
  static const Color secondary = Color(0xFF5C6BC0);
  
  // Background and surface
  static const Color background = Color(0xFFF8F9FA); // Softer light gray
  static const Color surface = Colors.white;
  static const Color surfaceContainer = Color(0xFFF1F3F4);
  
  // Typography
  static const Color textPrimary = Color(0xFF1F2937); // Dark gray, softer than pure black
  static const Color textSecondary = Color(0xFF6B7280); // Gray
  static const Color textDisabled = Color(0xFF9CA3AF);
  
  // State colors
  static const Color success = Color(0xFF10B981); // Modern emerald
  static const Color warning = Color(0xFFF59E0B); // Modern amber
  static const Color error = Color(0xFFEF4444); // Modern red
  static const Color info = Color(0xFF3B82F6); // Modern blue
  static const Color neutral = Color(0xFF9CA3AF); // Neutral gray
  
  // Asset Semantic colors
  static const Color statusAvailable = success;
  static const Color statusAllocated = info;
  static const Color statusMaintenance = warning;
  static const Color statusReserved = Color(0xFF8B5CF6); // Purple
  static const Color statusLost = error;
  static const Color statusRetired = neutral;
  static const Color statusDisposed = Color(0xFF4B5563); // Darker gray
  
  // Borders and dividers
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);
}
