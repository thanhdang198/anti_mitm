import 'dart:io';

import 'package:anti_mitm/src/disable_all_connection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkBlocker', () {
    tearDown(NetworkBlocker.disableNetworkBlocking);

    test('should enable network blocking', () {
      expect(NetworkBlocker.isNetworkBlocked, false);

      NetworkBlocker.enableNetworkBlocking();

      expect(NetworkBlocker.isNetworkBlocked, true);
      // expect(HttpOverrides.global, isA<NoNetworkHttpOverrides>());
    });

    test('should disable network blocking', () {
      NetworkBlocker.enableNetworkBlocking();
      expect(NetworkBlocker.isNetworkBlocked, true);

      NetworkBlocker.disableNetworkBlocking();

      expect(NetworkBlocker.isNetworkBlocked, false);
      // expect(HttpOverrides.global, isNull);
    });

    test('should track blocking state correctly', () {
      expect(NetworkBlocker.isNetworkBlocked, false);

      NetworkBlocker.enableNetworkBlocking();
      expect(NetworkBlocker.isNetworkBlocked, true);

      NetworkBlocker.disableNetworkBlocking();
      expect(NetworkBlocker.isNetworkBlocked, false);
    });
  });

  group('NoNetworkHttpOverrides', () {
    test('should create NoNetworkHttpClient', () {
      final overrides = NoNetworkHttpOverrides();
      final client = overrides.createHttpClient(null);

      expect(client, isA<HttpClient>());
    });
  });

  group('_NoNetworkHttpClient', () {
    late HttpClient blockedClient;

    setUp(() {
      final overrides = NoNetworkHttpOverrides();
      blockedClient = overrides.createHttpClient(null);
    });

    test('should block GET requests', () async {
      expect(
        () => blockedClient.getUrl(Uri.parse('https://example.com')),
        throwsA(isA<SocketException>()),
      );
    });

    test('should block POST requests', () async {
      expect(
        () => blockedClient.postUrl(Uri.parse('https://example.com')),
        throwsA(isA<SocketException>()),
      );
    });

    test('should block PUT requests', () async {
      expect(
        () => blockedClient.putUrl(Uri.parse('https://example.com')),
        throwsA(isA<SocketException>()),
      );
    });

    test('should block DELETE requests', () async {
      expect(
        () => blockedClient.deleteUrl(Uri.parse('https://example.com')),
        throwsA(isA<SocketException>()),
      );
    });

    test('should block PATCH requests', () async {
      expect(
        () => blockedClient.patchUrl(Uri.parse('https://example.com')),
        throwsA(isA<SocketException>()),
      );
    });

    test('should block HEAD requests', () async {
      expect(
        () => blockedClient.headUrl(Uri.parse('https://example.com')),
        throwsA(isA<SocketException>()),
      );
    });

    test('should block open method', () async {
      expect(
        () => blockedClient.open('GET', 'example.com', 443, '/'),
        throwsA(isA<SocketException>()),
      );
    });

    test('should block openUrl method', () async {
      expect(
        () => blockedClient.openUrl('GET', Uri.parse('https://example.com')),
        throwsA(isA<SocketException>()),
      );
    });

    test('should allow closing', () {
      // Should not throw
      expect(() => blockedClient.close(), returnsNormally);
      expect(() => blockedClient.close(force: true), returnsNormally);
    });

    test('should have correct properties', () {
      expect(blockedClient.autoUncompress, false);
      expect(blockedClient.idleTimeout, const Duration(seconds: 15));
    });

    test('should handle property setters without error', () {
      expect(() {
        blockedClient.autoUncompress = true;
        blockedClient.connectionTimeout = const Duration(seconds: 30);
        blockedClient.maxConnectionsPerHost = 10;
        blockedClient.userAgent = 'TestAgent';
      }, returnsNormally,);
    });
  });
}
