import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothController {
  // Singleton - One instance for the whole app
  static final BluetoothController _instance = BluetoothController._internal();
  factory BluetoothController() => _instance;
  BluetoothController._internal();

  BluetoothConnection? connection;
  bool get isConnected => connection != null && connection!.isConnected;

  // Stream to broadcast data to all pages
  final StreamController<String> _dataStream = StreamController<String>.broadcast();
  Stream<String> get dataStream => _dataStream.stream;

  Future<void> initPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location
    ].request();
  }

  // Connect to specific device
  Future<bool> connect(BluetoothDevice device) async {
    try {
      await connection?.finish(); // Close previous if exists
      
      // FIX: Added timeout logic here to prevent indefinite hanging
      connection = await BluetoothConnection.toAddress(device.address)
          .timeout(const Duration(seconds: 10));
      
      print('Connected to the device'); // Debug print

      // Listen to incoming data
      connection!.input!.listen(_onDataReceived).onDone(() {
        _dataStream.add("STATUS:Disconnected");
      });
      return true;
    } catch (e) {
      print("Connection Error: $e");
      return false;
    }
  }

  void _onDataReceived(Uint8List data) {
    // Convert bytes to string
    String message = String.fromCharCodes(data).trim();
    if (message.isNotEmpty) {
      _dataStream.add(message); // Send to UI
    }
  }

  void sendCommand(String command) {
    if (isConnected) {
      // Send with newline \n because ESP32 uses readStringUntil('\n')
      connection!.output.add(Uint8List.fromList("$command\n".codeUnits));
      connection!.output.allSent;
    }
  }

  void dispose() {
    connection?.dispose();
    _dataStream.close();
  }
}