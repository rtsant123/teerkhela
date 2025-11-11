import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class DeviceInfo {
  static const String _deviceIdKey = 'device_id';

  // Get or create device ID
  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);

    if (deviceId == null) {
      // Generate a unique device ID
      deviceId = _generateDeviceId();
      await prefs.setString(_deviceIdKey, deviceId);
    }

    return deviceId;
  }

  // Generate a unique device ID
  static String _generateDeviceId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return 'device_${List.generate(16, (_) => chars[random.nextInt(chars.length)]).join()}';
  }
}
