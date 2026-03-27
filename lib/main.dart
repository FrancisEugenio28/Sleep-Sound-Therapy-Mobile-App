import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'pages/landing_page.dart';
import 'pages/sleep_data.dart';
import 'pages/diagnostic_page.dart';
import 'pages/diagnostic_screen.dart';

// Import the new background service file we just created
// (Ensure this path matches wherever you saved it in your lib folder!)
import 'background_service.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize our new Background Service Engine (The Hardware Shield)
  await initializeBackgroundService();

  // 2. Initialize your existing Background Audio Engine
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.flutter_application_1.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Sleep',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1a1a2e),
        scaffoldBackgroundColor: const Color(0xFF1a1a2e),
        fontFamily: 'Sans-serif',
      ),
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0; // Start with Music page

  // Create instances of your pages (without their own Scaffold/BottomNav)
  final List<Widget> _pages = [
    const MusicPageContent(),
    const SleepDataPageContent(),
    const DiagnosticPageContent(),
    const DiagnosticScreenContent(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white24, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF1a1a2e),
          selectedItemColor: const Color(0xFF6a1b9a),
          unselectedItemColor: Colors.white54,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.music_note),
              label: 'Music',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Sleep Data',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology),
              label: 'Diagnostics',
            ),
          ],
        ),
      ),
    );
  }
}