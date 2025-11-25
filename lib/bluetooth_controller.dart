import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart'; // Added for debug prints
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothController {
  // Singleton
  static final BluetoothController _instance = BluetoothController._internal();
  factory BluetoothController() => _instance;
  BluetoothController._internal();

  BluetoothConnection? connection;
  
  // Stream for data
  final StreamController<String> _dataStream = StreamController<String>.broadcast();
  Stream<String> get dataStream => _dataStream.stream;

  // Getter for connection state
  bool get isConnected => connection != null && connection!.isConnected;

  Future<void> initPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  Future<bool> connect(BluetoothDevice device) async {
    print("DEBUG: Starting connection to ${device.address}");

    // 1. Clean up existing connections
    if (connection != null) {
      print("DEBUG: Closing existing connection...");
      await connection!.finish();
      connection = null;
    }

    try {
      // 2. Attempt Connection
      // We use a direct connection attempt without a manual timeout first
      // The library handles timeouts internally usually around 5-10s
      connection = await BluetoothConnection.toAddress(device.address);
      
      print("DEBUG: Socket Connected!");

      // 3. Setup Listener
      connection!.input!.listen(
        _onDataReceived,
        onDone: () {
          print("DEBUG: Connection Closed by remote device");
          _dataStream.add("STATUS:Disconnected");
          connection = null;
        },
        onError: (error) {
          print("DEBUG: Stream Error: $error");
          _dataStream.add("STATUS:Error");
        },
      );

      return true;
    } catch (e) {
      print("DEBUG: CRITICAL CONNECTION ERROR: $e");
      connection = null;
      return false;
    }
  }

  void _onDataReceived(Uint8List data) {
    try {
      String message = String.fromCharCodes(data).trim();
      if (message.isNotEmpty) {
        print("DEBUG: Received: $message"); // Visualize data in console
        _dataStream.add(message);
      }
    } catch (e) {
      print("DEBUG: Parse Error: $e");
    }
  }

  void sendCommand(String command) {
    if (isConnected) {
      print("DEBUG: Sending: $command");
      try {
        connection!.output.add(Uint8List.fromList("$command\n".codeUnits));
        connection!.output.allSent.then((_) {
          // Data sent successfully
        });
      } catch (e) {
        print("DEBUG: Send Error: $e");
      }
    } else {
      print("DEBUG: Cannot send, not connected.");
    }
  }

  void dispose() {
    connection?.dispose();
    _dataStream.close();
  }
}