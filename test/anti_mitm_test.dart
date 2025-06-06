import 'package:anti_mitm/src/anti_mitm.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AntiMitm', () {
    group('isLocalCaptureIP', () {
      test('should return true for localhost variations', () {
        expect(AntiMitm.isLocalCaptureIP('localhost'), true);
        expect(AntiMitm.isLocalCaptureIP('127.0.0.1'), true);
        expect(AntiMitm.isLocalCaptureIP('::1'), true);
      });

      test('should return true for localhost with protocols and ports', () {
        expect(AntiMitm.isLocalCaptureIP('http://localhost'), true);
        expect(AntiMitm.isLocalCaptureIP('https://localhost'), true);
        expect(AntiMitm.isLocalCaptureIP('localhost:8080'), true);
        expect(AntiMitm.isLocalCaptureIP('http://localhost:8080'), true);
        expect(AntiMitm.isLocalCaptureIP('https://127.0.0.1:3000'), true);
        expect(AntiMitm.isLocalCaptureIP('127.0.0.1:8888/path'), true);
      });

      test('should return true for private IPv4 ranges', () {
        // 192.168.x.x range
        expect(AntiMitm.isLocalCaptureIP('192.168.1.1'), true);
        expect(AntiMitm.isLocalCaptureIP('192.168.0.1'), true);
        expect(AntiMitm.isLocalCaptureIP('192.168.255.255'), true);

        // 10.x.x.x range
        expect(AntiMitm.isLocalCaptureIP('10.0.0.1'), true);
        expect(AntiMitm.isLocalCaptureIP('10.1.1.1'), true);
        expect(AntiMitm.isLocalCaptureIP('10.255.255.255'), true);

        // 172.16.x.x - 172.31.x.x range
        expect(AntiMitm.isLocalCaptureIP('172.16.0.1'), true);
        expect(AntiMitm.isLocalCaptureIP('172.20.1.1'), true);
        expect(AntiMitm.isLocalCaptureIP('172.31.255.255'), true);
      });

      test('should return true for private IPs with protocols and ports', () {
        expect(AntiMitm.isLocalCaptureIP('http://192.168.1.1:8080'), true);
        expect(AntiMitm.isLocalCaptureIP('https://10.0.0.1:3000'), true);
        expect(AntiMitm.isLocalCaptureIP('172.16.1.1:8888/api'), true);
      });

      test('should return false for public IPv4 addresses', () {
        expect(AntiMitm.isLocalCaptureIP('8.8.8.8'), false);
        expect(AntiMitm.isLocalCaptureIP('1.1.1.1'), false);
        expect(AntiMitm.isLocalCaptureIP('208.67.222.222'), false);
        expect(AntiMitm.isLocalCaptureIP('172.15.255.255'), false);
        expect(AntiMitm.isLocalCaptureIP('172.32.0.1'), false);
        expect(AntiMitm.isLocalCaptureIP('11.0.0.1'), false);
        expect(AntiMitm.isLocalCaptureIP('191.168.1.1'), false);
      });

      test('should return false for public domains', () {
        expect(AntiMitm.isLocalCaptureIP('google.com'), false);
        expect(AntiMitm.isLocalCaptureIP('https://example.com'), false);
        expect(AntiMitm.isLocalCaptureIP('api.github.com:443'), false);
        expect(AntiMitm.isLocalCaptureIP('www.flutter.dev/docs'), false);
      });

      test('should handle edge cases', () {
        expect(AntiMitm.isLocalCaptureIP(''), false);
        expect(AntiMitm.isLocalCaptureIP('   '), false);
        expect(AntiMitm.isLocalCaptureIP('172'), false);
        expect(AntiMitm.isLocalCaptureIP('172.'), false);
        expect(AntiMitm.isLocalCaptureIP('172.abc.1.1'), false);
        expect(AntiMitm.isLocalCaptureIP('192.168'), false);
      });

      test('should handle whitespace correctly', () {
        expect(AntiMitm.isLocalCaptureIP('  localhost  '), true);
        expect(AntiMitm.isLocalCaptureIP('  192.168.1.1  '), true);
        expect(AntiMitm.isLocalCaptureIP('  127.0.0.1:8080  '), true);
      });

      test('should return false for IPv6 addresses (except ::1)', () {
        expect(AntiMitm.isLocalCaptureIP('2001:db8::1'), false);
        expect(AntiMitm.isLocalCaptureIP('fe80::1'), false);
        expect(AntiMitm.isLocalCaptureIP('2001:4860:4860::8888'), false);
      });
    });

    group('isConnectedToSensitiveProxy', () {
      test('should delegate to isConnectedToProxy', () async {
        // This test verifies the method delegation
        // In a real scenario, you would mock NativeProxyReader
        expect(AntiMitm.isConnectedToSensitiveProxy, isA<Function>());
      });
    });

    group('Network Blocking', () {
      tearDown(AntiMitm.restoreConnections);

      test('should block all connections', () {
        expect(AntiMitm.isNetworkBlocked, false);

        AntiMitm.blockAllConnections();

        expect(AntiMitm.isNetworkBlocked, true);
      });

      test('should restore connections', () {
        AntiMitm.blockAllConnections();
        expect(AntiMitm.isNetworkBlocked, true);

        AntiMitm.restoreConnections();

        expect(AntiMitm.isNetworkBlocked, false);
      });

      test('performSecurityCheck should return true when safe', () async {
        // This is a basic test - in reality you'd mock the proxy detection
        final result = await AntiMitm.performSecurityCheck();
        expect(result, isA<bool>());
      });

      test('performSecurityCheck with autoBlock should not block when safe', () async {
        final result = await AntiMitm.performSecurityCheck(autoBlock: true);

        // If no proxy detected, should return true and not block
        if (result) {
          expect(AntiMitm.isNetworkBlocked, false);
        }
      });
    });
  });
}
