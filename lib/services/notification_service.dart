import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Handler untuk notifikasi yang datang saat app di-background / terminated.
/// Harus berupa top-level function (bukan method class).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase sudah diinit di main(), tidak perlu init ulang di sini
  debugPrint('[FCM Background] Pesan diterima: ${message.messageId}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'product_upload_channel';
  static const String _channelName = 'Upload Produk';
  static const String _channelDesc =
      'Notifikasi ketika produk baru berhasil diupload';

  /// Inisialisasi semua notifikasi — panggil sekali di main()
  Future<void> initialize() async {
    // Hanya untuk platform mobile (Android/iOS), bukan web
    if (kIsWeb) return;

    // 1. Setup background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Minta permission notifikasi
    await _requestPermission();

    // 3. Setup flutter_local_notifications (untuk foreground)
    await _initLocalNotifications();

    // 4. Handle notifikasi saat app TERBUKA (foreground)
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 5. Handle ketika user tap notifikasi (app di background)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // 6. Daftarkan FCM token ke backend
    await _registerTokenToBackend();

    // 7. Refresh token bila berubah
    _fcm.onTokenRefresh.listen((newToken) {
      _saveAndRegisterToken(newToken);
    });
  }

  // ─── Permission ────────────────────────────────────────────────────────────

  Future<void> _requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint(
        '[FCM] Permission status: ${settings.authorizationStatus}');
  }

  // ─── Local Notifications Init ───────────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    // Android: buat notification channel dengan suara
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Inisialisasi plugin
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotif.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('[LocalNotif] Tapped: ${details.payload}');
      },
    );

    // iOS: tampilkan notifikasi saat foreground
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ─── Handle Foreground Message ──────────────────────────────────────────────

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('[FCM Foreground] Pesan: ${message.notification?.title}');

    final notification = message.notification;
    if (notification == null) return;

    // Tampilkan notifikasi lokal dengan suara
    await _localNotif.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF03AC0E), // Tokopedia green
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['type'],
    );
  }

  // ─── Handle Notification Tap ────────────────────────────────────────────────

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('[FCM] User tap notifikasi: ${message.data}');
    // TODO: tambahkan navigasi ke halaman produk jika diperlukan
  }

  // ─── Token Management ───────────────────────────────────────────────────────

  Future<void> _registerTokenToBackend() async {
    try {
      final token = await _fcm.getToken();
      if (token == null) return;
      await _saveAndRegisterToken(token);
    } catch (e) {
      debugPrint('[FCM] Gagal mendapatkan token: $e');
    }
  }

  Future<void> _saveAndRegisterToken(String token) async {
    try {
      // Simpan token di local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);

      // Kirim ke backend
      final accessToken = prefs.getString('access_token');
      if (accessToken == null) {
        debugPrint('[FCM] Belum login, token disimpan lokal untuk didaftarkan setelah login');
        return;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications/register-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'fcm_token': token}),
      );

      if (response.statusCode == 200) {
        debugPrint('[FCM] Token berhasil didaftarkan ke backend');
      } else {
        debugPrint('[FCM] Gagal daftarkan token: ${response.body}');
      }
    } catch (e) {
      debugPrint('[FCM] Error mendaftarkan token: $e');
    }
  }

  /// Panggil ini setelah user berhasil login
  Future<void> registerTokenAfterLogin(String accessToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('fcm_token') ?? await _fcm.getToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications/register-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'fcm_token': token}),
      );

      if (response.statusCode == 200) {
        debugPrint('[FCM] Token didaftarkan setelah login');
      }
    } catch (e) {
      debugPrint('[FCM] Error register token after login: $e');
    }
  }

  /// Panggil ini saat user logout
  Future<void> removeTokenOnLogout(String accessToken) async {
    if (kIsWeb) return;
    try {
      await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/notifications/remove-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );
      debugPrint('[FCM] Token dihapus dari backend');
    } catch (e) {
      debugPrint('[FCM] Error remove token: $e');
    }
  }
}
