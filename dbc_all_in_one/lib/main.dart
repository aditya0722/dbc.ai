import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'presentation/splash_screen/splash_screen.dart';
import 'presentation/business_dashboard/business_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ REQUIRED: Supabase MUST be initialized
  await Supabase.initialize(
    url: 'https://dummy.supabase.co', // ← TEMP PLACEHOLDER
    anonKey: 'dummy-key',             // ← TEMP PLACEHOLDER
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
       return MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'dbc_all_in_one',
  home: const SplashScreen(),
);
      },
    );
  }
}
