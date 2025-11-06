import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'storage_service.dart';
import 'api_service.dart';

// Background message handler (must be top-level function)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static Function(String)? onNotificationTap;

  // Initialize Firebase Messaging
  static Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print('FCM Token: $token');
      await StorageService.setFcmToken(token);

      // Send token to backend
      final userId = StorageService.getUserId();
      if (userId != null) {
        try {
          await ApiService.updateFcmToken(userId, token);
        } catch (e) {
          print('Error updating FCM token: $e');
        }
      }
    }

    // Handle token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      print('FCM Token refreshed: $newToken');
      await StorageService.setFcmToken(newToken);

      final userId = StorageService.getUserId();
      if (userId != null) {
        try {
          await ApiService.updateFcmToken(userId, newToken);
        } catch (e) {
          print('Error updating FCM token: $e');
        }
      }
    });

    // Configure background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message notification: ${message.notification!.title}');
        print('Message body: ${message.notification!.body}');

        // Show in-app notification (you can use a package like flutter_local_notifications)
        _showInAppNotification(message.notification!);
      }
    });

    // Handle notification tap (app opened from notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapped!');
      print('Message data: ${message.data}');

      _handleNotificationTap(message.data);
    });

    // Check if app was opened from a notification (terminated state)
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('App opened from notification (terminated)');
      _handleNotificationTap(initialMessage.data);
    }
  }

  // Show in-app notification
  static void _showInAppNotification(RemoteNotification notification) {
    // You can implement a custom in-app notification UI here
    // For now, we'll just print it
    print('In-app notification: ${notification.title} - ${notification.body}');
  }

  // Handle notification tap
  static void _handleNotificationTap(Map<String, dynamic> data) {
    final screen = data['screen'];
    print('Navigating to screen: $screen');

    if (onNotificationTap != null && screen != null) {
      onNotificationTap!(screen);
    }
  }

  // Get FCM token
  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }
}
