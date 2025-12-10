import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

/// Mengelola inisialisasi dan alur notifikasi (foreground, background, terminated).
class NotificationController extends GetxController {
  final RxString fcmToken = ''.obs;

  final _messaging = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Dipakai untuk notifikasi penting (heads-up).',
    importance: Importance.max,
  );

  @override
  void onInit() {
    super.onInit();
    _initNotificationFlow();
  }

  Future<void> _initNotificationFlow() async {
    await _requestPermission();
    await _setupLocalNotifications();
    await _setupFcmListeners();

    fcmToken.value = await _messaging.getToken() ?? '';
    if (fcmToken.isNotEmpty) {
      debugPrint('FCM token: ${fcmToken.value}');
    }
    _messaging.onTokenRefresh.listen((token) {
      fcmToken.value = token;
      debugPrint('FCM token (refreshed): $token');
    });
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: androidInit,
    );

    await _local.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        final route = response.payload;
        if (route != null && route.isNotEmpty) {
          Get.toNamed(route);
        }
      },
    );

    final androidPlugin =
        _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);
  }

  Future<void> _setupFcmListeners() async {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _navigateFromMessage(message);
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _navigateFromMessage(initialMessage);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final android = notification?.android;

    _local.show(
      message.hashCode,
      notification?.title ?? 'Notifikasi',
      notification?.body ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: android?.smallIcon ?? '@mipmap/ic_launcher',
        ),
      ),
      payload: _routeFromData(message.data),
    );
  }

  void _navigateFromMessage(RemoteMessage message) {
    final route = _routeFromData(message.data);
    if (route != null && route.isNotEmpty) {
      Get.toNamed(route, arguments: message.data);
    }
  }

  String? _routeFromData(Map<String, dynamic> data) {
    final routeValue = data['route'] ?? data['screen'];
    if (routeValue is String && routeValue.trim().isNotEmpty) {
      return routeValue;
    }
    return null;
  }
}
