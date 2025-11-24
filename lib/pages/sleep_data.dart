import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/shared_header.dart';
import '../bluetooth_controller.dart'; // Import the controller

class SleepDataPageContent extends StatefulWidget {
  const SleepDataPageContent({super.key});

  @override
  State<SleepDataPageContent> createState() => _SleepDataPageContentState();
}

class _SleepDataPageContentState extends State<SleepDataPageContent> {
  // Controller
  final BluetoothController _btController = BluetoothController();
  StreamSubscription? _streamSubscription;

  // Real-Time State Variables
  String _systemTime = "--:--:--";
  String _motionStatus = "Waiting...";
  String _sleepTimer = "-- min";
  String _micLevel = "0";
  
  // Colors for dynamic status
  Color _motionColor = Colors.white70;

  @override
  void initState() {
    super.initState();
    _listenToBluetooth();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  void _listenToBluetooth() {
    _streamSubscription = _btController.dataStream.listen((message) {
      if (!mounted) return;

      // Expected Format from ESP32: 
      // DATA:12:00:00|YES|1800|45000|50
      // Time | Motion | SleepSeconds | MicLevel | Volume

      if (message.startsWith("DATA:")) {
        try {
          String cleanData = message.substring(5).trim(); // Remove "DATA:" & whitespace
          List<String> parts = cleanData.split('|');

          // Safety Check: Ensure we have enough parts
          if (parts.length >= 4) {
            String rawTime = parts[0].trim();
            String rawMotion = parts[1].trim();
            int secondsLeft = int.tryParse(parts[2].trim()) ?? 0;
            String rawMic = parts[3].trim();

            setState(() {
              _systemTime = rawTime;
              
              // Motion Logic
              if (rawMotion == "YES") {
                _motionStatus = "DETECTED";
                _motionColor = Colors.redAccent;
              } else {
                _motionStatus = "None";
                _motionColor = const Color(0xFF4CAF50); // Green
              }

              // Timer Logic (Convert seconds to Mins:Secs)
              int mins = secondsLeft ~/ 60;
              int secs = secondsLeft % 60;
              // PadLeft ensures "5:04" instead of "5:4"
              _sleepTimer = "${mins}m ${secs.toString().padLeft(2, '0')}s";

              _micLevel = rawMic;
            });
          }
        } catch (e) {
          print("Parse Error: $e");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: Column(
          children: [
            const SharedHeader(
              title: 'Sleep Data',
              subtitle: 'Real-Time Monitoring',
            ),
            const Divider(color: Colors.white24, height: 1),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Real-Time Monitor Card
                    _buildRealTimeMonitor(),
                    
                    const SizedBox(height: 24),
                    
                    // 2. Static Stats
                    _buildStatsCard(),
                    
                    const SizedBox(height: 24),
                    
                    // 3. Weekly Overview
                    _buildWeeklyOverview(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildRealTimeMonitor() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF232b47),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LIVE SENSOR FEED',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(Icons.sensors, color: Color(0xFF6a1b9a), size: 20),
            ],
          ),
          const SizedBox(height: 20),
          
          // Row 1: Time & Timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLiveItem("Device Clock", _systemTime, Icons.access_time),
              _buildLiveItem("Sleep Timer", _sleepTimer, Icons.timer),
            ],
          ),
          
          const Divider(color: Colors.white10, height: 30),
          
          // Row 2: Motion & Mic
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Motion Sensor", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    _motionStatus,
                    style: TextStyle(
                      color: _motionColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              _buildLiveItem("Mic Noise Level", _micLevel, Icons.graphic_eq),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white54, size: 14),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4a148c), Color(0xFF6a1b9a)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                '85%',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7FFF00),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Avg. Sleep Quality',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                '6.5 h',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7FFF00),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Avg. Duration',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyOverview() {
    final weekData = [
      {'date': 'Today', 'emoji': '😴', 'hours': 'Tracking...', 'trend': true},
      {'date': 'Yesterday', 'emoji': '😴', 'hours': '6.5 hrs', 'trend': false},
      {'date': 'Mon', 'emoji': '😴', 'hours': '6.8 hrs', 'trend': true},
      {'date': 'Sun', 'emoji': '😴', 'hours': '7.3 hrs', 'trend': true},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...weekData.map((data) => _buildWeekItem(
              data['date'] as String,
              data['emoji'] as String,
              data['hours'] as String,
              data['trend'] as bool,
            )),
      ],
    );
  }

  Widget _buildWeekItem(String date, String emoji, String hours, bool trendUp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a3e),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  date,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                hours,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
          Icon(
            trendUp ? Icons.trending_up : Icons.trending_down,
            color: trendUp ? const Color(0xFF7FFF00) : Colors.redAccent,
            size: 24,
          ),
        ],
      ),
    );
  }
}