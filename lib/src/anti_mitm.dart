import 'package:anti_mitm/native_flutter_proxy.dart';

/// Check if the device is connected to a proxy.
class AntiMitm {
  /// This class is used to check if the device is connected to a sensitive proxy, which using to capture request from your app.
  static Future<bool> isConnectedToSensitiveProxy() {
    return isConnectedToProxy();
  }

  /// This class is used to check if the device is connected to a proxy.
  static Future<bool> isConnectedToProxy() async {
    String? host;

    try {
      final settings = await NativeProxyReader.proxySetting;
      host = settings.host;
    } catch (e) {
      // Make sure to handle the error appropriately in production code.
      return false;
    }
    return host != null && isLocalCaptureIP(host);
  }

  /// Block all network connections to prevent MITM attacks
  /// This is a security measure that can be used when suspicious proxy activity is detected
  static void blockAllConnections() {
    NetworkBlocker.enableNetworkBlocking();
  }

  /// Restore normal network connections
  /// Call this after the security threat has been resolved
  static void restoreConnections() {
    NetworkBlocker.disableNetworkBlocking();
  }

  /// Check if network connections are currently blocked
  static bool get isNetworkBlocked => NetworkBlocker.isNetworkBlocked;

  /// Comprehensive security check and automatic protection
  /// Returns true if the device is safe, false if protection was activated
  static Future<bool> performSecurityCheck({bool autoBlock = false}) async {
    final isProxyConnected = await isConnectedToSensitiveProxy();

    if (isProxyConnected && autoBlock) {
      blockAllConnections();
      return false; // Security threat detected and blocked
    }

    return !isProxyConnected; // True if safe, false if threat detected
  }

  /// Check if the given IP address or hostname is a local capture IP.
  static bool isLocalCaptureIP(String input) {
    // Loại bỏ tiền tố http:// hoặc https:// nếu có
    var sanitized = input
        .replaceFirst(RegExp(r'^https?:\/\/'), '')
        .split('/')[0] // Bỏ path nếu có
        .trim();

    // Xử lý port cho IPv4 (không áp dụng cho IPv6)
    if (!sanitized.contains('::')) {
      sanitized = sanitized.split(':')[0];
    }

    // Danh sách các IP hoặc hostname local
    const localHosts = ['localhost', '127.0.0.1', '::1'];

    // Kiểm tra trực tiếp
    if (localHosts.contains(sanitized)) return true;

    // Kiểm tra prefix IP
    if (sanitized.startsWith('192.168.')) return true;
    if (sanitized.startsWith('10.')) return true;

    // Kiểm tra các dải 172.16.0.0 – 172.31.255.255
    if (sanitized.startsWith('172.')) {
      final parts = sanitized.split('.');
      if (parts.length >= 2) {
        final secondOctet = int.tryParse(parts[1]);
        if (secondOctet != null && secondOctet >= 16 && secondOctet <= 31) {
          return true;
        }
      }
      return false;
    }
    return false;
  }
}
