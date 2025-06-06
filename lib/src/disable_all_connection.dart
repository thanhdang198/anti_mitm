import 'dart:io';

/// Helper class to manage network blocking in Flutter applications
class NetworkBlocker {
  static bool _isBlocked = false;

  /// Enable network blocking for all HTTP requests
  /// This will block all network requests including HTTP, HTTPS
  static void enableNetworkBlocking() {
    HttpOverrides.global = NoNetworkHttpOverrides();
    _isBlocked = true;
  }

  /// Disable network blocking and restore normal network access
  static void disableNetworkBlocking() {
    HttpOverrides.global = null;
    _isBlocked = false;
  }

  /// Check if network blocking is currently enabled
  static bool get isNetworkBlocked => _isBlocked;
}

/// A custom HttpOverrides that blocks all network connections
/// Use this to prevent any HTTP/HTTPS requests from being made
///
/// Example usage:
/// ```dart
/// // Block all network requests
/// NetworkBlocker.enableNetworkBlocking();
///
/// // Or use directly:
/// HttpOverrides.global = NoNetworkHttpOverrides();
///
/// // Restore network access
/// NetworkBlocker.disableNetworkBlocking();
/// ```
class NoNetworkHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _NoNetworkHttpClient(super.createHttpClient(context));
  }
}

class _NoNetworkHttpClient implements HttpClient {
  _NoNetworkHttpClient(this._inner)
      : autoUncompress = false,
        idleTimeout = const Duration(seconds: 15);
  final HttpClient _inner;

  @override
  Future<HttpClientRequest> getUrl(Uri url) {
    throw const SocketException('Network access blocked');
  }

  // Override all methods that create request
  @override
  Future<HttpClientRequest> open(String method, String host, int port, String path) {
    throw const SocketException('Network access blocked');
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    throw const SocketException('Network access blocked');
  }

  // Other HttpClient methods can be overridden similarly or delegated as needed
  // Implement rest of interface with either delegation or throwing

  // Example: allow closing
  @override
  void close({bool force = false}) => _inner.close(force: force);

  @override
  bool autoUncompress;

  @override
  Duration? connectionTimeout;

  @override
  Duration idleTimeout;

  @override
  int? maxConnectionsPerHost;

  @override
  String? userAgent;

  @override
  void addCredentials(Uri url, String realm, HttpClientCredentials credentials) {
    // No-op: Don't store credentials in blocked mode
  }

  @override
  void addProxyCredentials(String host, int port, String realm, HttpClientCredentials credentials) {
    // No-op: Don't store proxy credentials in blocked mode
  }

  @override
  set authenticate(Future<bool> Function(Uri url, String scheme, String? realm)? f) {
    // No-op: Don't set authentication in blocked mode
  }

  @override
  set authenticateProxy(
      Future<bool> Function(String host, int port, String scheme, String? realm)? f,) {
    // No-op: Don't set proxy authentication in blocked mode
  }

  @override
  set badCertificateCallback(bool Function(X509Certificate cert, String host, int port)? callback) {
    // No-op: Don't handle certificates in blocked mode
  }

  @override
  set connectionFactory(
      Future<ConnectionTask<Socket>> Function(Uri url, String? proxyHost, int? proxyPort)? f,) {
    // No-op: Don't set connection factory in blocked mode
  }

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) {
    throw const SocketException('Network access blocked');
  }

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) {
    throw const SocketException('Network access blocked');
  }

  @override
  set findProxy(String Function(Uri url)? f) {
    // No-op: Don't set proxy finder in blocked mode
  }

  @override
  Future<HttpClientRequest> get(String host, int port, String path) {
    throw const SocketException('Network access blocked');
  }

  @override
  Future<HttpClientRequest> head(String host, int port, String path) {
    throw const SocketException('Network access blocked');
  }

  @override
  Future<HttpClientRequest> headUrl(Uri url) {
    throw const SocketException('Network access blocked');
  }

  @override
  set keyLog(void Function(String line)? callback) {
    // No-op: Don't log anything in blocked mode
  }

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) {
    throw const SocketException('Network access blocked');
  }

  @override
  Future<HttpClientRequest> patchUrl(Uri url) {
    throw const SocketException('Network access blocked');
  }

  @override
  Future<HttpClientRequest> post(String host, int port, String path) {
    throw const SocketException('Network access blocked');
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) {
    throw const SocketException('Network access blocked');
  }

  @override
  Future<HttpClientRequest> put(String host, int port, String path) {
    throw const SocketException('Network access blocked');
  }

  @override
  Future<HttpClientRequest> putUrl(Uri url) {
    throw const SocketException('Network access blocked');
  }
  // ... implement other members as needed (e.g. add dummy implementations)
}
