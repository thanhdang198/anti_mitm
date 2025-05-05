import 'package:native_flutter_proxy/native_flutter_proxy.dart';

/// Check if the device is connected to a proxy.
class AntiMitm {
  /// This class is used to check if the device is connected to a proxy.
  static Future<bool> isConnectedToProxy() async {
    String? host;
    var enabled = false;

    try {
      final settings = await NativeProxyReader.proxySetting;
      enabled = settings.enabled;
      host = settings.host;
    } catch (e) {
      return false;
    }

    if (enabled || host?.startsWith('192.') == true || host?.startsWith('127.') == true) {
      return true;
    }
    return false;
  }
}
