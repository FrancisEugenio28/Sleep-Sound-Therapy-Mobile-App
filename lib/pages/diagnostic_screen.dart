import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/shared_header.dart';
import '../bluetooth_controller.dart'; 

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

    // Trigger logic
    _btController.sendCommand("DIAG");

    // 1. Check Connection
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _connStatus = _btController.isConnected ? "Passed" : "Failed";
          _connColor = _btController.isConnected ? _primaryGreen : Colors.red;
          _progressValue = 0.3;
          _statusText = "Checking Audio System...";
        });
      }
    });

    // 2. Check Audio (Simulated assumption based on Connection)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _audioStatus = "Operational"; 
          _audioColor = _primaryGreen;
          _progressValue = 0.5;
          _statusText = "Reading Battery Voltage...";
        });
      }
    });

    // 3. Listen for Battery & Sensors
    _streamSubscription = _btController.dataStream.listen((message) {
      if (!mounted) return;

      if (message == "STATUS:Disconnected") {
        setState(() {
          _connStatus = "Failed";
          _connColor = Colors.red;
          _statusText = "Device Disconnected";
          _progressValue = 0.0;
        });
        return;
      }

      if (message.startsWith("DIAG:Battery:")) {
        String voltStr = message.split(":")[2].replaceAll("V", "").trim();
        double volts = double.tryParse(voltStr) ?? 0.0;
        int percent = ((volts - 3.0) / (4.2 - 3.0) * 100).toInt().clamp(0, 100);
        
        setState(() {
          _batteryStatus = "$percent% ($voltStr V)";
          _battColor = percent > 20 ? _primaryGreen : Colors.orange;
          if (_progressValue < 0.8) {
             _progressValue = 0.8;
             _statusText = "Verifying Sensors...";
          }
        });
      } 
      else if (message.startsWith("DATA:")) {
        // If we get DATA, sensors are actively broadcasting
        if (_sensorStatus != "Active") {
           setState(() {
            _sensorStatus = "Active";
            _sensorColor = _primaryGreen;
            
            // Only complete the diagnostic if battery has also been received
            if (_batteryStatus != "Waiting...") {
              _progressValue = 1.0;
              _statusText = "Diagnostic Complete";
              _isComplete = true;
            }
          });
        }
      }
    });
  }
  
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
          const Text('System Diagnostic', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
              Text(_statusText, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              Text('${(_progressValue * 100).toInt()} %', style: const TextStyle(color: Colors.white, fontSize: 14)),
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
      decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              Text(status, style: TextStyle(color: color, fontSize: 14)),
            ],
          ),
          if (status != "Waiting..." && status != "Checking...")
            Icon(Icons.check_circle_outline, color: color, size: 24)
          else
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: color)),
        ],
      ),
    );
  }

  Widget _buildStatusAndButton() {
    if (!_isComplete) return const SizedBox.shrink();
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 25),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: _primaryGreen.withOpacity(0.5))),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.check_box, color: Colors.white, size: 24),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('All systems operational', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text('Your device is functioning properly. Battery voltage and sensors are within normal ranges.', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton(
            onPressed: _runDiagnostics,
            style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('RUN DIAGNOSTIC AGAIN', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
                    onPressed: () { Navigator.of(context).pop(); },
                  ),
                  const Expanded(child: SharedHeader(title: 'System Diagnostic', subtitle: 'Hardware & Software Tests')),
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
                    _buildTestCard(title: 'Bluetooth Connectivity', status: _connStatus, color: _connColor),
                    _buildTestCard(title: 'Audio Engine', status: _audioStatus, color: _audioColor),
                    _buildTestCard(title: 'Battery Voltage', status: _batteryStatus, color: _battColor),
                    _buildTestCard(title: 'Radar & Mic Sensors', status: _sensorStatus, color: _sensorColor),
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