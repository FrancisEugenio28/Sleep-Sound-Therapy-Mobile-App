import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/sleep_session.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class BluetoothController {
  static final BluetoothController _instance = BluetoothController._internal();
  factory BluetoothController() => _instance;
  BluetoothController._internal();

  BluetoothConnection? connection;
  final StreamController<String> _dataStream = StreamController<String>.broadcast();
  Stream<String> get dataStream => _dataStream.stream;

  bool get isConnected => connection != null && connection!.isConnected;

  // --- LIVE SESSION TRACKING VARIABLES ---
  DateTime? _sessionStartTime;
  DateTime? _firstSleepOnsetTime; // NEW: Tracks the exact moment of sleep
  List<int> _noiseReadings = [];
  int _awakeSeconds = 0;

  Future<void> initPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
      Permission.notification,
    ].request();
  }

  Future<bool> connectToDataService() async {
    try {
      print("DEBUG: Getting paired devices...");
      
      List<BluetoothDevice> pairedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
      
      BluetoothDevice? targetDevice;
      for (BluetoothDevice device in pairedDevices) {
        if (device.name != null && device.name!.toUpperCase().contains("SMARTSLEEP")) {
          targetDevice = device;
          break;
        }
      }

      if (targetDevice == null) {
        print("DEBUG: SmartSleep device not found.");
        return false;
      }

      print(">>> TARGET MATCHED! Connecting to SPP Data Port...");
      
      connection = await BluetoothConnection.toAddress(targetDevice.address);
      print('Connected to the device data port!');

      // --- 1. START THE SLEEP SESSION ---
      _sessionStartTime = DateTime.now();
      _firstSleepOnsetTime = null; // Reset the sleep onset timestamp
      _noiseReadings.clear();
      _awakeSeconds = 0;

      FlutterBackgroundService().startService();

      String buffer = "";
      connection!.input!.listen((Uint8List data) {
        buffer += String.fromCharCodes(data);
        
        while (buffer.contains('\n')) {
          int index = buffer.indexOf('\n');
          String message = buffer.substring(0, index).trim();
          buffer = buffer.substring(index + 1);
          
          if (message.isNotEmpty) {
            _dataStream.add(message); // Broadcast to UI

            // --- NEW: DYNAMIC SLEEP LATENCY TRACKING ---
            // If the ESP32 announces sleep, and we haven't recorded it yet tonight
            if (message.contains("State -> ASLEEP") && _firstSleepOnsetTime == null) {
              _firstSleepOnsetTime = DateTime.now();
              print("DEBUG: True Sleep Onset recorded at $_firstSleepOnsetTime");
            }

            // --- 2. AGGREGATE SENSOR DATA BEHIND THE SCENES ---
            if (message.startsWith("DATA:")) {
              try {
                String cleanData = message.substring(5).trim();
                List<String> parts = cleanData.split('|');
                
                if (parts.length >= 4) {
                  String motion = parts[1].trim();
                  int mic = int.tryParse(parts[3].trim()) ?? 0;
                  
                  _noiseReadings.add(mic); // Store noise for average calculation
                  if (motion == "YES") {
                    _awakeSeconds++; // Track tossing and turning
                  }
                }
              } catch (e) {
                print("Live tracking parse error: $e");
              }
            }
          }
        }
      }).onDone(() {
        print('Disconnected by remote request');
        disconnect(); // This triggers the save logic
      });
      
      sendCommand("DIAG");
      _dataStream.add("STATUS:Connected");

      return true;
    } catch (e) {
      print("Connection Error: $e");
      return false;
    }
  }

  void sendCommand(String command) async {
    if (isConnected) {
      connection!.output.add(ascii.encode(command + "\n"));
      await connection!.output.allSent;
    }
  }

  void disconnect() async {
    // --- 3. END SESSION & SAVE TO DATABASE ---
    if (_sessionStartTime != null) {
      DateTime endTime = DateTime.now();
      int totalMinutesInBed = endTime.difference(_sessionStartTime!).inMinutes;

      if (totalMinutesInBed >= 1) {
        // A. Calculate Average Noise
        int avgNoise = 0;
        if (_noiseReadings.isNotEmpty) {
          double sum = 0;
          for (int noise in _noiseReadings) sum += noise;
          avgNoise = (sum / _noiseReadings.length).round();
        }

        // B. Calculate Awake Time
        int awakeMinutes = _awakeSeconds ~/ 60;

        // C. Calculate Latency (DYNAMIC MATH)
        int latency = 15; // Fallback baseline if they never fall asleep
        if (_firstSleepOnsetTime != null) {
          // Math: The exact minutes between connecting Bluetooth and falling asleep
          latency = _firstSleepOnsetTime!.difference(_sessionStartTime!).inMinutes;
        } else if (totalMinutesInBed < latency) {
          latency = totalMinutesInBed ~/ 2;
        }

        // D. Calculate Duration & Efficiency
        int duration = totalMinutesInBed - latency - awakeMinutes;
        if (duration < 0) duration = 0;

        int efficiency = totalMinutesInBed > 0 ? ((duration / totalMinutesInBed) * 100).round() : 0;

        // E. Calculate Final Quality Score
        int quality = (efficiency * 0.8 + (100 - (avgNoise / 100)) * 0.2).round().clamp(0, 100);

        // F. Build and Insert the Object
        SleepSession liveSession = SleepSession(
          startTime: _sessionStartTime!,
          endTime: endTime,
          durationMinutes: duration,
          sleepLatency: latency,
          sleepEfficiency: efficiency,
          avgNoiseLevel: avgNoise,
          qualityScore: quality,
        );

        await DatabaseHelper.instance.createSession(liveSession);
        print("✅ REAL SLEEP SESSION SAVED TO SQLITE! Latency: $latency mins");
      }
    }

    _sessionStartTime = null;
    _firstSleepOnsetTime = null;
    connection?.dispose();
    connection = null;
    _dataStream.add("STATUS:Disconnected");

    FlutterBackgroundService().invoke('stopService'); // Tell the background service to shut down
  }
}