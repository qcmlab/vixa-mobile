import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class LockscreenService {
  static const MethodChannel _channel = MethodChannel('dz.hafedh.hafedh_mobile/lockscreen');

  static Future<bool> startLockScreenService() async {
    if (kIsWeb) return false;
    try {
      final res = await _channel.invokeMethod<bool>('startLockScreenService');
      return res ?? false;
    } catch (e) {
      debugPrint('Error starting lockscreen service: $e');
      return false;
    }
  }

  static Future<bool> stopLockScreenService() async {
    if (kIsWeb) return false;
    try {
      final res = await _channel.invokeMethod<bool>('stopLockScreenService');
      return res ?? false;
    } catch (e) {
      debugPrint('Error stopping lockscreen service: $e');
      return false;
    }
  }

  static Future<bool> isLockScreenEnabled() async {
    if (kIsWeb) return false;
    try {
      final res = await _channel.invokeMethod<bool>('isLockScreenEnabled');
      return res ?? true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> testLockScreen() async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod('testLockScreen');
    } catch (e) {
      debugPrint('Error testing lockscreen: $e');
    }
  }
}
