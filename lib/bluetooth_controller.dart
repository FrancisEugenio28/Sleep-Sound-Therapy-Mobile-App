import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothController {
  static final BluetoothController _instance = BluetoothController._internal();
  factory BluetoothController() => _instance;
  BluetoothController._internal();

  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? txCharacteristic; // Receive Data
  BluetoothCharacteristic? rxCharacteristic; // Send Commands

  // UPDATED: UUIDs now perfectly match the ESP32 code
  final String SERVICE_UUID = "0000FFE0-0000-1000-8000-00805F9B34FB";
  // The ESP32 uses a single characteristic for both sending and receiving
  final String TX_UUID = "0000FFE1-0000-1000-8000-00805F9B34FB"; 
  final String RX_UUID = "0000FFE1-0000-1000-8000-00805F9B34FB";

  final StreamController<String> _dataStream = StreamController<String>.broadcast();
  Stream<String> get dataStream => _dataStream.stream;

  bool get isConnected => connectedDevice != null;

  Future<void> initPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  // Scan and Connect
  Future<bool> connectToDataService() async {
    try {
      print("DEBUG: Starting BLE Scan...");
      // Start Scan
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 5),
      );
      
      bool found = false;
      
      // Listen to scan results
      var subscription = FlutterBluePlus.scanResults.listen((results) async {
        for (ScanResult r in results) {
          if (r.device.platformName.isNotEmpty) {
             print("SCANNED: '${r.device.platformName}' (${r.device.remoteId})");
          }

          // 2. CHECK FOR MATCH (Case Insensitive)
          String name = r.device.platformName.toUpperCase();
          String localName = r.advertisementData.localName.toUpperCase(); 

          // UPDATED: Now looks for SOUNDTHERAPY to match the ESP32
          if (name.contains("SOUNDTHERAPY") || localName.contains("SOUNDTHERAPY")) {
            print(">>> TARGET MATCHED! Connecting...");
            
            await FlutterBluePlus.stopScan();
            await _connectToDevice(r.device);
            found = true;
            return; 
          }
        }
      });

      await Future.delayed(const Duration(seconds: 6));
      await subscription.cancel();
      
      if (!found) {
        print("DEBUG: Scan finished. Device NOT found.");
      }
      
      return found;
    } catch (e) {
      print("Scan Error: $e");
      return false;
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    await device.connect();
    connectedDevice = device;

    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      if (service.uuid.toString().toUpperCase() == SERVICE_UUID) {
        for (var characteristic in service.characteristics) {
          // Setup RX (Sending commands to ESP32)
          if (characteristic.uuid.toString().toUpperCase() == RX_UUID) {
            rxCharacteristic = characteristic;
          }
          // Setup TX (Receiving data from ESP32)
          if (characteristic.uuid.toString().toUpperCase() == TX_UUID) {
            txCharacteristic = characteristic;
            await characteristic.setNotifyValue(true);
            characteristic.onValueReceived.listen((value) {
              String msg = utf8.decode(value);
              _dataStream.add(msg);
            });
          }
        }
      }
    }
  }

  void sendCommand(String command) async {
    if (rxCharacteristic != null) {
      await rxCharacteristic!.write(utf8.encode(command));
    }
  }

  void disconnect() {
    connectedDevice?.disconnect();
    connectedDevice = null;
  }
}