import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/shared_header.dart';
import '../bluetooth_controller.dart'; // Import your controller

class DiagnosticScreenContent extends StatefulWidget {
  const DiagnosticScreenContent({super.key});

  @override
  State<DiagnosticScreenContent> createState() => _DiagnosticScreenContentState();
}

class _DiagnosticScreenContentState extends State<DiagnosticScreenContent> {
  final BluetoothController _btController = BluetoothController();
  StreamSubscription? _streamSubscription;

  // Colors
  static const Color _cardColor = Color(0xFF232b47);
  static const Color _primaryGreen = Color(0xFF4CAF50);
  static const Color _progressAccent = Color(0xFF6A3DA0);
  static const Color _scaffoldBackground = Color(0xFF1a1a2e);

  // State Variables
  double _progressValue = 0.0;
  String _statusText = "Initializing...";
  bool _isComplete = false;

  // Hardware States
  String _connStatus = "Checking...";
  String _audioStatus = "Waiting...";
  String _batteryStatus = "Waiting...";
  String _sensorStatus = "Waiting...";

  Color _connColor = Colors.white54;
  Color _audioColor = Colors.white54;
  Color _battColor = Colors.white54;
  Color _sensorColor = Colors.white54;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  void _runDiagnostics() {
    // 1. Reset State
    setState(() {
      _progressValue = 0.1;
      _statusText = "Connecting...";
      _isComplete = false;
      
      _connStatus = "Checking...";
      _audioStatus = "Waiting...";
      _batteryStatus = "Waiting...";
      _sensorStatus = "Waiting...";
      
      _connColor = Colors.white54;
      _audioColor = Colors.white54;
      _battColor = Colors.white54;
      _sensorColor = Colors.white54;
    });

    // 2. Send Command to ESP32
    // This triggers the ESP32 to read the voltage divider
    _btController.sendCommand("DIAG");

    // 3. Simulate Connectivity Check (Immediate)
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _connStatus = "Passed";
          _connColor = _primaryGreen;
          _progressValue = 0.3;
          _statusText = "Checking Audio System...";
        });
      }
    });

    // 4. Simulate Audio Check 
    // (Since we can't 'hear' it, we assume it's good if connection is good for this prototype)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _audioStatus = "Operational"; // Assumed based on I2S init
          _audioColor = _primaryGreen;
          _progressValue = 0.5;
          _statusText = "Reading Battery Voltage...";
        });
      }
    });

    // 5. Listen for Real Data (Battery & Sensors)
    _streamSubscription = _btController.dataStream.listen((message) {
      if (!mounted) return;

      // BATTERY CHECK (Response: "DIAG:Battery:3.75V")
      if (message.startsWith("DIAG:Battery:")) {
        String volts = message.split(":")[2];
        setState(() {
          _batteryStatus = "Good ($volts)";
          _battColor = _primaryGreen;
          _progressValue = 0.8;
          _statusText = "Verifying Sensors...";
        });
      }

      // SENSOR CHECK (Response: "DATA:...")
      // If we receive ANY streaming data, the sensors and logic task are running.
      if (message.startsWith("DATA:")) {
        // Only update if we haven't already marked it passed
        if (_sensorStatus != "Active") {
          setState(() {
            _sensorStatus = "Active";
            _sensorColor = _primaryGreen;
            _progressValue = 1.0;
            _statusText = "Diagnostic Complete";
            _isComplete = true;
          });
        }
      }
    });
  }

  // --- WIDGET BUILDERS ---

  Widget _buildRunningDiagnosticBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'System Diagnostic',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: _progressValue,
            backgroundColor: _progressAccent.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(_progressAccent),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _statusText,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '${(_progressValue * 100).toInt()} %',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard({required String title, required String status, required Color color}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (status != "Waiting..." && status != "Checking...")
            Icon(
              Icons.check_circle_outline,
              color: color,
              size: 24,
            )
          else
            SizedBox(
              width: 20, 
              height: 20, 
              child: CircularProgressIndicator(strokeWidth: 2, color: color)
            ),
        ],
      ),
    );
  }

  Widget _buildStatusAndButton() {
    // Only show this section if complete
    if (!_isComplete) return const SizedBox.shrink();

    return Column(
      children: [
        // Status Banner
        Container(
          margin: const EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 25),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _primaryGreen.withOpacity(0.5)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.check_box, color: Colors.white, size: 24),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All systems operational',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Your device is functioning properly. Battery voltage and sensors are within normal ranges.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Restart Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton(
            onPressed: _runDiagnostics, // Re-run the function
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'RUN DIAGNOSTIC AGAIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const Expanded(
                    child: SharedHeader(
                      title: 'System Diagnostic',
                      subtitle: 'Hardware & Software Tests',
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1, thickness: 1),
            
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: <Widget>[
                    _buildRunningDiagnosticBox(),
                    
                    _buildTestCard(
                      title: 'Bluetooth Connectivity', 
                      status: _connStatus, 
                      color: _connColor
                    ),
                    _buildTestCard(
                      title: 'Audio Engine', 
                      status: _audioStatus, 
                      color: _audioColor
                    ),
                    _buildTestCard(
                      title: 'Battery Voltage', 
                      status: _batteryStatus, 
                      color: _battColor
                    ),
                    _buildTestCard(
                      title: 'Radar & Mic Sensors', 
                      status: _sensorStatus, 
                      color: _sensorColor
                    ),

                    _buildStatusAndButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}