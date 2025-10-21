import 'package:flutter/material.dart';

class SpecialtyTheme {
  final String specialty;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final IconData icon;
  final String iconAsset;
  final LinearGradient gradient;

  SpecialtyTheme({
    required this.specialty,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.icon,
    required this.iconAsset,
    required this.gradient,
  });
}

class SpecialtyThemes {
  static final Map<String, SpecialtyTheme> _themes = {
    'طب الأطفال': SpecialtyTheme(
      specialty: 'طب الأطفال',
      primaryColor: Color(0xFF4CAF50),
      secondaryColor: Color(0xFF81C784),
      backgroundColor: Color(0xFFE8F5E8),
      icon: Icons.child_care,
      iconAsset: '👶',
      gradient: LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    'طب العيون': SpecialtyTheme(
      specialty: 'طب العيون',
      primaryColor: Color(0xFF2196F3),
      secondaryColor: Color(0xFF64B5F6),
      backgroundColor: Color(0xFFE3F2FD),
      icon: Icons.visibility,
      iconAsset: '👁️',
      gradient: LinearGradient(
        colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    'طب القلب': SpecialtyTheme(
      specialty: 'طب القلب',
      primaryColor: Color(0xFFE91E63),
      secondaryColor: Color(0xFFF06292),
      backgroundColor: Color(0xFFFCE4EC),
      icon: Icons.favorite,
      iconAsset: '❤️',
      gradient: LinearGradient(
        colors: [Color(0xFFE91E63), Color(0xFFF06292)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    'طب الأسنان': SpecialtyTheme(
      specialty: 'طب الأسنان',
      primaryColor: Color(0xFF00BCD4),
      secondaryColor: Color(0xFF4DD0E1),
      backgroundColor: Color(0xFFE0F2F1),
      icon: Icons.medical_services,
      iconAsset: '🦷',
      gradient: LinearGradient(
        colors: [Color(0xFF00BCD4), Color(0xFF4DD0E1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    'طب الجلدية': SpecialtyTheme(
      specialty: 'طب الجلدية',
      primaryColor: Color(0xFFFF9800),
      secondaryColor: Color(0xFFFFB74D),
      backgroundColor: Color(0xFFFFF3E0),
      icon: Icons.healing,
      iconAsset: '🧴',
      gradient: LinearGradient(
        colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    'طب النساء والولادة': SpecialtyTheme(
      specialty: 'طب النساء والولادة',
      primaryColor: Color(0xFF9C27B0),
      secondaryColor: Color(0xFFBA68C8),
      backgroundColor: Color(0xFFF3E5F5),
      icon: Icons.pregnant_woman,
      iconAsset: '🤱',
      gradient: LinearGradient(
        colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    'طب العظام': SpecialtyTheme(
      specialty: 'طب العظام',
      primaryColor: Color(0xFF795548),
      secondaryColor: Color(0xFFA1887F),
      backgroundColor: Color(0xFFEFEBE9),
      icon: Icons.accessibility_new,
      iconAsset: '🦴',
      gradient: LinearGradient(
        colors: [Color(0xFF795548), Color(0xFFA1887F)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    'طب الأنف والأذن والحنجرة': SpecialtyTheme(
      specialty: 'طب الأنف والأذن والحنجرة',
      primaryColor: Color(0xFF607D8B),
      secondaryColor: Color(0xFF90A4AE),
      backgroundColor: Color(0xFFECEFF1),
      icon: Icons.hearing,
      iconAsset: '👂',
      gradient: LinearGradient(
        colors: [Color(0xFF607D8B), Color(0xFF90A4AE)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    'طب الأعصاب': SpecialtyTheme(
      specialty: 'طب الأعصاب',
      primaryColor: Color(0xFF3F51B5),
      secondaryColor: Color(0xFF7986CB),
      backgroundColor: Color(0xFFE8EAF6),
      icon: Icons.psychology,
      iconAsset: '🧠',
      gradient: LinearGradient(
        colors: [Color(0xFF3F51B5), Color(0xFF7986CB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    'طب النفسية': SpecialtyTheme(
      specialty: 'طب النفسية',
      primaryColor: Color(0xFF673AB7),
      secondaryColor: Color(0xFF9575CD),
      backgroundColor: Color(0xFFEDE7F6),
      icon: Icons.psychology_alt,
      iconAsset: '🧘',
      gradient: LinearGradient(
        colors: [Color(0xFF673AB7), Color(0xFF9575CD)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    'الطب العام': SpecialtyTheme(
      specialty: 'الطب العام',
      primaryColor: Color(0xFF009688),
      secondaryColor: Color(0xFF4DB6AC),
      backgroundColor: Color(0xFFE0F2F1),
      icon: Icons.local_hospital,
      iconAsset: '🏥',
      gradient: LinearGradient(
        colors: [Color(0xFF009688), Color(0xFF4DB6AC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  };

  static SpecialtyTheme getTheme(String specialty) {
    return _themes[specialty] ?? _themes['الطب العام']!;
  }

  static List<String> getAllSpecialties() {
    return _themes.keys.toList();
  }

  static Color getPrimaryColor(String specialty) {
    return getTheme(specialty).primaryColor;
  }

  static Color getSecondaryColor(String specialty) {
    return getTheme(specialty).secondaryColor;
  }

  static Color getBackgroundColor(String specialty) {
    return getTheme(specialty).backgroundColor;
  }

  static IconData getIcon(String specialty) {
    return getTheme(specialty).icon;
  }

  static String getIconAsset(String specialty) {
    return getTheme(specialty).iconAsset;
  }

  static LinearGradient getGradient(String specialty) {
    return getTheme(specialty).gradient;
  }
}

