import 'package:cloud_firestore/cloud_firestore.dart';

// نطاق ساعات العمل
class WorkingHourRange {
  final String startTime; // HH:mm 24‑ساعة
  final String endTime; // HH:mm 24‑ساعة

  WorkingHourRange({required this.startTime, required this.endTime});

  factory WorkingHourRange.fromMap(Map<String, dynamic> map) {
    return WorkingHourRange(
      startTime: _to24Format(map['startTime'] ?? ''),
      endTime: _to24Format(map['endTime'] ?? ''),
    );
  }

  Map<String, dynamic> toMap() => {'startTime': startTime, 'endTime': endTime};

  // تطبيع الأرقام العربية وتحويل AM/PM أو ص/م إلى 24‑ساعة
  static String _normalizeDigits(String input) {
    const eastern = [
      '\u0660',
      '\u0661',
      '\u0662',
      '\u0663',
      '\u0664',
      '\u0665',
      '\u0666',
      '\u0667',
      '\u0668',
      '\u0669',
    ];
    const extended = [
      '\u06F0',
      '\u06F1',
      '\u06F2',
      '\u06F3',
      '\u06F4',
      '\u06F5',
      '\u06F6',
      '\u06F7',
      '\u06F8',
      '\u06F9',
    ];
    for (int i = 0; i < 10; i++) {
      input = input.replaceAll(eastern[i], i.toString());
      input = input.replaceAll(extended[i], i.toString());
    }
    return input;
  }

  static String _to24Format(String timeString) {
    final normalized = _normalizeDigits(timeString).trim();
    final lower = normalized.toLowerCase();
    final pm = lower.contains('pm') || lower.contains('م');
    final am = lower.contains('am') || lower.contains('ص');

    final match = RegExp(r'(\d{1,2}):(\d{1,2})').firstMatch(lower);
    if (match != null) {
      int hour = int.tryParse(match.group(1)!) ?? 0;
      final int minute = int.tryParse(match.group(2)!) ?? 0;
      if (pm && hour < 12) hour += 12;
      if (am && hour == 12) hour = 0;
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }
    return timeString; // fallback
  }
}

class DoctorModel {
  final String uid;
  final String fullName;
  final String specialty;
  final String clinicName;
  final String clinicAddress;
  final double? latitude;
  final double? longitude;
  final Map<String, List<WorkingHourRange>> workingHours;
  final String? bio;
  final String? imageUrl;
  final double averageRating;
  final int totalRatings;
  final Map<String, String>? socialMedia;

  DoctorModel({
    required this.uid,
    required this.fullName,
    required this.specialty,
    required this.clinicName,
    required this.clinicAddress,
    this.latitude,
    this.longitude,
    required this.workingHours,
    this.bio,
    this.imageUrl,
    this.averageRating = 0.0,
    this.totalRatings = 0,
    this.socialMedia,
  });

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    Map<String, List<WorkingHourRange>> parseWorkingHours(dynamic data) {
      if (data == null) return {};
      final Map<String, List<WorkingHourRange>> parsed = {};
      (data as Map<String, dynamic>).forEach((day, ranges) {
        if (ranges is List) {
          parsed[day] = ranges.map((range) {
            if (range is String) {
              // صيغة قديمة نصية
              final parts = range
                  .replaceAll(RegExp(r'[صم]'), '')
                  .trim()
                  .split('-');
              if (parts.length == 2) {
                return WorkingHourRange(
                  startTime: WorkingHourRange._to24Format(parts[0].trim()),
                  endTime: WorkingHourRange._to24Format(parts[1].trim()),
                );
              }
            } else if (range is Map<String, dynamic>) {
              // صيغة جديدة
              return WorkingHourRange.fromMap(range);
            }
            // fallback
            return WorkingHourRange(startTime: '00:00', endTime: '00:00');
          }).toList();
        }
      });
      return parsed;
    }

    return DoctorModel(
      uid: map["uid"] ?? "",
      fullName: map["fullName"] ?? "",
      specialty: map["specialty"] ?? "",
      clinicName: map['clinicName'] ?? '',
      clinicAddress: map['clinicAddress'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      workingHours: parseWorkingHours(map['workingHours']),
      bio: map['bio'],
      imageUrl: map['imageUrl'],
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      totalRatings: map["totalRatings"] ?? 0,
      socialMedia: map["socialMedia"] != null
          ? Map<String, String>.from(map["socialMedia"])
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'fullName': fullName,
    'specialty': specialty,
    'clinicName': clinicName,
    'clinicAddress': clinicAddress,
    'latitude': latitude,
    'longitude': longitude,
    'workingHours': workingHours.map(
      (key, value) => MapEntry(key, value.map((e) => e.toMap()).toList()),
    ),
    'bio': bio,
    'imageUrl': imageUrl,
    'averageRating': averageRating,
    'totalRatings': totalRatings,
    'socialMedia': socialMedia,
  };

  DoctorModel copyWith({
    String? uid,
    String? fullName,
    String? specialty,
    String? clinicName,
    String? clinicAddress,
    double? latitude,
    double? longitude,
    Map<String, List<WorkingHourRange>>? workingHours,
    String? bio,
    String? imageUrl,
    double? averageRating,
    int? totalRatings,
    Map<String, String>? socialMedia,
  }) {
    return DoctorModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      specialty: specialty ?? this.specialty,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      workingHours: workingHours ?? this.workingHours,
      bio: bio ?? this.bio,
      imageUrl: imageUrl ?? this.imageUrl,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
      socialMedia: socialMedia ?? this.socialMedia,
    );
  }
}
