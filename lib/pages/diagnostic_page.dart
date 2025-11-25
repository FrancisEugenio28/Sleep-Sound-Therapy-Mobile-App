import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/shared_header.dart';
import '../pages/diagnostic_screen.dart';
import '../bluetooth_controller.dart'; // Import controller

class DiagnosticPageContent extends StatefulWidget {
  const DiagnosticPageContent({super.key});

  @override
  State<DiagnosticPageContent> createState() => _DiagnosticPageContentState();
}

class _DiagnosticPageContentState extends State<DiagnosticPageContent> {
  final BluetoothController _btController = BluetoothController();
  StreamSubscription? _streamSubscription;

  // Default States
  String _connStatus = "Disconnected";
  String _batteryStatus = "--%";
  String _sensorStatus = "Inactive";
  
  Color _connColor = Colors.redAccent;
  Color _battColor = Colors.white60;
  Color _sensorColor = Colors.white60;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _listenToData();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  void _checkConnection() {
    if (_btController.isConnected) {
      setState(() {
        _connStatus = "CONNECTED";
        _connColor = const Color(0xFF4CAF50); // Green
      });
    }
  }

  void _listenToData() {
    _streamSubscription = _btController.dataStream.listen((message) {
      if (!mounted) return;

      // 1. Handle Connection Status Updates
      if (message == "STATUS:Disconnected") {
        setState(() {
          _connStatus = "DISCONNECTED";
          _connColor = Colors.redAccent;
          _sensorStatus = "Inactive";
        });
      }

      // 2. Handle Live Data (Voltage & Sensors)
      // Format: DATA:12:00:00|YES|1800|3.85V|45000
      if (message.startsWith("DATA:")) {
        try {
          List<String> parts = message.substring(5).split('|');
          if (parts.length >= 4) {
            // Parse Voltage (e.g., "3.85V")
            String voltStr = parts[3].replaceAll("V", "").trim();
            double volts = double.tryParse(voltStr) ?? 0.0;
            
            // Convert to Percentage (3.0V = 0%, 4.2V = 100%)
            int percent = ((volts - 3.0) / (4.2 - 3.0) * 100).toInt();
            percent = percent.clamp(0, 100);

            setState(() {
              _connStatus = "CONNECTED";
              _connColor = const Color(0xFF4CAF50);
              
              _batteryStatus = "$percent% ($voltStr V)";
              _battColor = percent > 20 ? const Color(0xFF4CAF50) : Colors.orange;

              _sensorStatus = "ACTIVE";
              _sensorColor = const Color(0xFF4CAF50);
            });
          }
        } catch (e) {
          print("Diag Parse Error: $e");
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
              title: 'Smart Sleep',
              subtitle: 'Embedded Sound Therapy',
            ),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 16.0),

            // Device Status Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _connStatus == "CONNECTED" 
                        ? [const Color(0xFF4CAF50), const Color(0xFF45a049)]
                        : [const Color(0xFFEF5350), const Color(0xFFD32F2F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Device', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        Text('Status', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _connStatus == "CONNECTED" ? Icons.check : Icons.close,
                            color: Colors.white, 
                            size: 20
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _connStatus == "CONNECTED" ? 'System Online' : 'Device Offline',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Hardware Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  StatusCard(title: 'Connectivity', subtitle: 'Bluetooth Link', status: _connStatus, statusColor: _connColor),
                  const SizedBox(height: 12),
                  const StatusCard(title: 'Speaker', subtitle: 'Audio Output', status: 'READY', statusColor: Color(0xFF4CAF50)), // Speaker is assumed ready if connected
                  const SizedBox(height: 12),
                  StatusCard(title: 'Battery', subtitle: 'Power Level', status: _batteryStatus, statusColor: _battColor),
                  const SizedBox(height: 12),
                  StatusCard(title: 'Sensors', subtitle: 'Radar & Microphone', status: _sensorStatus, statusColor: _sensorColor),
                  const SizedBox(height: 20),
                  const SystemFunctionButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;

  const StatusCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF232b47),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white60)),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(status, style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class SystemFunctionButton extends StatelessWidget {
  const SystemFunctionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('System Function', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const DiagnosticScreenContent()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('RUN FULL DIAGNOSTIC', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}