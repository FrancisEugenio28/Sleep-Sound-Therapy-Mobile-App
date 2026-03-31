import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  // 1. Define the Android Notification Channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'smart_sleep_channel', // Internal ID
    'Smart Sleep Tracking', // Title shown in system settings
    description: 'This channel is used to keep the sleep tracker alive.',
    importance: Importance.low, // 'Low' prevents it from vibrating or dinging every second
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Register the channel with the Android OS
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // 2. Configure the Background Service Engine
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false, // We only want it to start when the user taps 'Connect'
      isForegroundMode: true,
      notificationChannelId: 'smart_sleep_channel',
      initialNotificationTitle: 'SmartSleep Active',
      initialNotificationContent: 'Monitoring user sleep...',
      foregroundServiceNotificationId: 888,
      foregroundServiceTypes: [AndroidForegroundType.connectedDevice]
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
    ),
  );
}

// 3. The Isolated Background Thread
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Ensure the Dart plugin registry is ready in the background
  DartPluginRegistrant.ensureInitialized();

  // Listen for the command from your Bluetooth Controller to shut down in the morning
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // --- NEW: THE NOTIFICATION HEARTBEAT ---
  // This timer ticks every 60 seconds. By updating the notification text, 
  // it mathematically proves to the Android OS that the app is not frozen, 
  // preventing the 30-minute idle execution kill script.
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: 'SmartSleep Active',
          content: 'Smart Sleep active... (Uptime: ${timer.tick} min)',
        );
      }
    }
  });
}