import 'package:flutter/material.dart';
import 'package:prm393_pe/views/home/home_screen.dart';
import 'package:prm393_pe/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Migrate data from SharedPreferences to Database
  await StorageService.migrateToDatabase();
  
  runApp(const LuckyDrawApp());
}

class LuckyDrawApp extends StatelessWidget {
  const LuckyDrawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lucky Draw - Quay Số May Mắn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFD32F2F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD32F2F),
          primary: const Color(0xFFD32F2F),
          secondary: const Color(0xFFFFD700),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8E1),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
