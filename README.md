[![Pub Version](https://img.shields.io/pub/v/anti_mitm)](https://pub.dev/packages/anti_mitm)


This plugin is based on the `native_flutter_proxy` plugin, which is a Flutter plugin that provides a way to read the proxy settings of the device.

# anti_mitm

A flutter plugin to detect if the device is connected to a proxy. This is useful for detecting if the device is being used by 3rd party applications to intercept the traffic. 

This plugin is useful for detect if the device is using HTTP Toolkit, Burp Suite, Proxyman, Charles Proxy, Fiddler, mitmproxy, etc. to intercept the traffic.

It can't detect if attacker is using another tool to intercept the traffic, such as SSL Kill Switch, SSL Unpinning, etc.

**New Feature:** The plugin now includes network blocking capabilities to prevent all HTTP/HTTPS requests when suspicious proxy activity is detected.

Consider to use more advanced tools to detect if your app is being attacked.

## Features

- ✅ Detect proxy connections (HTTP Toolkit, Burp Suite, Proxyman, etc.)
- ✅ Identify local capture IPs used by debugging tools
- ✅ **Block all network connections** when threats are detected
- ✅ Automatic security checks with optional auto-blocking
- ✅ Cross-platform support (iOS, Android)

## Installing

You should add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  anti_mitm: latest
```


## Example

### Basic Usage

- Step 1: make your main()-method async
- Step 2: add WidgetsFlutterBinding.ensureInitialized(); to your async-main()-method
- Step 3: check if the device is connected to a proxy
- Step 4: if the device is connected to a proxy, use the built-in network blocking to protect your app

```dart
void main() async {
  // Ensure that the WidgetsBinding is initialized before calling the
  // [NativeProxyReader.proxySetting] method.
  WidgetsFlutterBinding.ensureInitialized();

  var isConnectedToSensitiveProxy = await AntiMitm.isConnectedToSensitiveProxy();
  if (isConnectedToSensitiveProxy) {
    print('Sensitive proxy detected! Blocking all network connections.');
    
    // Block all network connections automatically
    AntiMitm.blockAllConnections();
    
    // Show warning to user
    // Your security handling code here...
  }

  runApp(MyApp());
}
```

### Advanced Usage with Auto-blocking

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Perform comprehensive security check with auto-blocking
  bool isSafe = await AntiMitm.performSecurityCheck(autoBlock: true);
  
  if (!isSafe) {
    print('🚨 Security threat detected and blocked!');
    // Show security warning to user
    // Log security event
    // Handle according to your security policy
  }

  runApp(MyApp());
}
```

### Manual Network Control

```dart
import 'package:anti_mitm/src/anti_mitm.dart';

class SecurityManager {
  static Future<void> checkAndBlockThreats() async {
    if (await AntiMitm.isConnectedToSensitiveProxy()) {
      // Block all network access
      AntiMitm.blockAllConnections();
      
      // Check if blocking is active
      print('Network blocked: ${AntiMitm.isNetworkBlocked}');
    }
  }
  
  static void restoreNetworkAccess() {
    // Restore normal network access after threat is resolved
    AntiMitm.restoreConnections();
    print('Network access restored');
  }
}
```

### Using Direct HttpOverrides

```dart
import 'package:anti_mitm/src/disable_all_connection.dart';
import 'dart:io';

void blockAllConnections() {
  // Direct usage without helper methods
  HttpOverrides.global = NoNetworkHttpOverrides();
}

void restoreConnections() {
  HttpOverrides.global = null;
}
```

Additionally, please run this function whenever your app is resumed to check if the device is connected to a proxy.

```dart

class MyHomePage extends StatefulWidget {
  /// Creates a new instance of [MyHomePage].
  ///
  /// The [title] parameter is required and displayed in the app bar.
  const MyHomePage({required this.title, super.key});

  /// The title displayed in the app bar.
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  int counter = 0;

  void _incrementCounter() => setState(() => counter++);
  @override
  void initState() {
    super.initState();
    // Đăng ký observer
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Hủy đăng ký observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    print('AppLifecycleState: $state');
    switch (state) {
      case AppLifecycleState.resumed:
        var isConnectedToSensitiveProxy = await AntiMitm.isConnectedToSensitiveProxy();
        if (isConnectedToSensitiveProxy) {
          print('Sensitive proxy detected! Handle disconnect all app internet here.');
        } else {
          print('Seems the app is safe to use.');
        }
        break;
      case AppLifecycleState.inactive:
        // App is inactive
        break;
      case AppLifecycleState.paused:
        // App is in the background
        break;
      case AppLifecycleState.detached:
        // App is detached
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ...
    );
  }
}
```
