import 'package:anti_mitm/native_flutter_proxy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomProxyHttpOverride', () {
    test('creates instance with proxy settings', () {
      final override = CustomProxyHttpOverride.withProxy(
        'localhost:8888',
        allowBadCertificates: true,
      );

      expect(override.proxyString, equals('localhost:8888'));
      expect(override.allowBadCertificates, isTrue);
    });
  });
}
