import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Messaging
import 'package:untitled/firebase_options.dart';

import 'app/routes/app_pages.dart';
import 'app/bindings/initial_binding.dart';
import 'app/data/services/notification_service.dart'; // Import NotificationService

// Top-level function to handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message: ${message.messageId}');
  // You can perform background tasks here, e.g., show a local notification
  NotificationService.showNotification(
    title: message.notification?.title ?? 'New Notification',
    body: message.notification?.body ?? 'You have a new message.',
    payload: message.data['payload'],
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ملاحظة: لا داعي لاستدعاء InitialBinding().dependencies() هون
  // لأنه سيتم تمريره لـ GetMaterialApp عبر initialBinding أدناه.

  // Check if initial setup is needed
  final bool setupNeeded = await _checkFirebaseSetup();

  runApp(
    MyApp(
      initialRoute: setupNeeded ? AppRoutes.FIREBASE_SETUP : AppRoutes.SPLASH,
    ),
  );
}

Future<bool> _checkFirebaseSetup() async {
  try {
    final doctorsCollection = FirebaseFirestore.instance.collection("doctors");
    final patientsCollection = FirebaseFirestore.instance.collection(
      "patients",
    );

    final doctorDocs = await doctorsCollection.limit(1).get();
    final patientDocs = await patientsCollection.limit(1).get();

    if (doctorDocs.docs.isEmpty || patientDocs.docs.isEmpty) {
      return true;
    }
    return false;
  } catch (e) {
    print('Error checking Firebase setup: $e');
    return true;
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  MyApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme =
        GoogleFonts.cairoTextTheme(ThemeData.light().textTheme).apply(
          bodyColor: const Color(0xFF333333),
          displayColor: const Color(0xFF333333),
        );

    return GetMaterialApp(
      title: 'Medical App',
      debugShowCheckedModeBanner: false,

      // إذا بدك تلغي تغييرات M3:
      // theme: ThemeData(useMaterial3: false, ...)
      theme: ThemeData(
        primaryColor: const Color(0xFF667eea), // Unified primary color
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF667eea),
          secondary: Color(0xFF764ba2), // Complementary gradient color
          surface: Colors.white,
          background: Color(0xFFF8FAFC),
          error: Color(0xFFE57373),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF2D3748),
          onBackground: Color(0xFF2D3748),
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF667eea),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),

        // ✅ Flutter الجديد يتوقع CardThemeData هنا
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.zero,
          color: Colors.white,
        ),

        textTheme: baseTextTheme.copyWith(
          headlineSmall: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF2D3748),
          ),
          titleLarge: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF2D3748),
          ),
          bodyLarge: const TextStyle(
            fontSize: 16,
            color: Color(0xFF2D3748),
          ),
          bodyMedium: const TextStyle(
            fontSize: 14,
            color: Color(0xFF4A5568),
          ),
          labelLarge: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF2D3748),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667eea),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            elevation: 2,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF667eea),
            side: const BorderSide(
              color: Color(0xFF667eea),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF667eea),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // ✅ كذلك هنا أصبح InputDecorationThemeData
        inputDecorationTheme: InputDecorationThemeData(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF667eea),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        ),

        // Add FloatingActionButton theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF667eea),
          foregroundColor: Colors.white,
          elevation: 4,
        ),

        // Add SnackBar theme
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF2D3748),
          contentTextStyle: TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      ),

      initialRoute: initialRoute,
      getPages: AppPages.routes,

      // ممرّر الـ bindings هنا (كافي ومو لازم نكرره قبل runApp)
      initialBinding: InitialBinding(),

      locale: const Locale('ar', 'SA'),
      fallbackLocale: const Locale('en', 'US'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
    );
  }
}
