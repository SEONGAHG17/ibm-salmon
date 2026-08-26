import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../constants/constants.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint("📩 [FCM 백그라운드 수신]: ${message.notification?.title}");
  } catch (e) {
    debugPrint("FCM 백그라운드 초기화를 건너뜀: $e");
  }
}

class FcmService {
  static bool isEnabled = false;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize(BuildContext context) async {
    if (!isEnabled) {
      return;
    }

    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await _messaging.getToken();
        if (token != null) {
          debugPrint("🔑 [FCM Token 발급]: $token");
          await _registerTokenToBackend(token);
        }

        _messaging.onTokenRefresh.listen((newToken) async {
          debugPrint("🔄 [FCM Token 갱신]: $newToken");
          await _registerTokenToBackend(newToken);
        });

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (message.notification != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '[알림] ${message.notification!.title ?? ""}\n${message.notification!.body ?? ""}',
                ),
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        });
      }
    } catch (e) {
      debugPrint("❌ [FCM 초기화 오류]: $e");
    }
  }

  static Future<void> _registerTokenToBackend(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/devices/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': 'default_user',
          'fcm_token': token,
        }),
      );
      if (response.statusCode == 200) {
        debugPrint("✅ [디바이스 토큰 백엔드 저장 성공]");
      }
    } catch (e) {
      debugPrint("❌ [디바이스 토큰 백엔드 저장 실패]: $e");
    }
  }
}
