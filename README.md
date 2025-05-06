[![Pub Version](https://img.shields.io/pub/v/anti_mitm)](https://pub.dev/packages/anti_mitm)


This plugin is based on the `native_flutter_proxy` plugin, which is a Flutter plugin that provides a way to read the proxy settings of the device.

# anti_mitm

A flutter plugin to detect if the device is connected to a proxy. This is useful for detecting if the device is being used by 3rd party applications to intercept the traffic. 

This plugin is useful for detect if the device is using HTTP Toolkit, Burp Suite, Proxyman, Charles Proxy, Fiddler, mitmproxy, etc. to intercept the traffic.

It can't detect if attacker is using another tool to intercept the traffic, such as SSL Kill Switch, SSL Unpinning, etc.

Consider to use more advanced tools to detect if your app is being attacked.
## Installing

You should add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  anti_mitm: latest
```


## Example

- Step 1: make your main()-method async
- Step 2: add WidgetsFlutterBinding.ensureInitialized(); to your async-main()-method
- Step 3: check if the device is connected to a proxy
- Step 4: if the device is connected to a proxy, please disable all connection from your application, cause the plugin is detected user is using a mitm proxy to intercept the traffic

```dart
void main() async {
  // Ensure that the WidgetsBinding is initialized before calling the
  // [NativeProxyReader.proxySetting] method.
  WidgetsFlutterBinding.ensureInitialized();

  var isConnectedToProxy = await AntiMitm.isConnectedToProxy();
  if (isConnectedToProxy) {
    print('Please disconnect from the proxy.');
  } else {
    print('Not connected to a proxy.');
  }
  runApp(const MyApp());
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
        var isConnectedToProxy = await AntiMitm.isConnectedToProxy();
        if (isConnectedToProxy) {
          print('Please disconnect from the proxy.');
        } else {
          print('Not connected to a proxy.');
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
