import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/recording_provider.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  // WAJIB: Memastikan mesin Flutter siap sebelum Isar menyala
  WidgetsFlutterBinding.ensureInitialized();
  // WAJIB: Membuka brankas .env sebelum aplikasi berjalan
  await dotenv.load(fileName: ".env");

  runApp(
    // Membungkus aplikasi dengan Provider agar memori Isar bisa dibaca semua layar
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecordingProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ErgoVoice',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const DashboardScreen(), 
    );
  }
}