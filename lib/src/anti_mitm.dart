import 'package:anti_mitm/native_flutter_proxy.dart';

/// Check if the device is connected to a proxy.
class AntiMitm {
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

    if (host?.contains('192.') == true || host?.contains('127.') == true) {
      return true;
    }
    return false;
  }
}
