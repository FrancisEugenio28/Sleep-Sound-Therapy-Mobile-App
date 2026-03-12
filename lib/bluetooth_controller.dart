import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothController {
  static final BluetoothController _instance = BluetoothController._internal();
  factory BluetoothController() => _instance;
  BluetoothController._internal();

  BluetoothConnection? connection;
  final StreamController<String> _dataStream = StreamController<String>.broadcast();
  Stream<String> get dataStream => _dataStream.stream;

  bool get isConnected => connection != null && connection!.isConnected;

  Future<void> initPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  // Classic Bluetooth Connect
  Future<bool> connectToDataService() async {
    try {
      print("DEBUG: Getting paired devices...");
      
      // 1. Get devices already paired in Android Settings
      List<BluetoothDevice> pairedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
      
      BluetoothDevice? targetDevice;
      for (BluetoothDevice device in pairedDevices) {
        // Look for the name we set in the ESP32 code
        if (device.name != null && device.name!.toUpperCase().contains("SMARTSLEEP")) {
          targetDevice = device;
          break;
        }
      }

      if (targetDevice == null) {
        print("DEBUG: SmartSleep device not found in paired list. Did you pair it in Android settings first?");
        return false;
      }

      print(">>> TARGET MATCHED! Connecting to SPP Data Port...");
      
      // 2. Connect to the Serial Port Profile (SPP)
      connection = await BluetoothConnection.toAddress(targetDevice.address);
      print('Connected to the device data port!');

      // 3. Listen for incoming ESP32 data (e.g., Sensor readings)
      String buffer = "";
      connection!.input!.listen((Uint8List data) {
        buffer += String.fromCharCodes(data);
        
        // Parse complete lines (ESP32 sends data ending with \n)
        while (buffer.contains('\n')) {
          int index = buffer.indexOf('\n');
          String message = buffer.substring(0, index).trim();
          buffer = buffer.substring(index + 1);
          
          if (message.isNotEmpty) {
            _dataStream.add(message);
          }
        }
      }).onDone(() {
        print('Disconnected by remote request');
        disconnect();
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
      // Send command with a newline character so ESP32 knows it's complete
      connection!.output.add(ascii.encode(command + "\n"));
      await connection!.output.allSent;
    }
  }

  void disconnect() {
    connection?.dispose();
    connection = null;
    _dataStream.add("STATUS:Disconnected"); // Notify UI to update colors
  }
}