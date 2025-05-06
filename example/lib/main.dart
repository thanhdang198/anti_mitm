// ignore_for_file: unused_local_variable
import 'package:anti_mitm/native_flutter_proxy.dart';
import 'package:flutter/material.dart';

void main() async {
  // Ensure that the WidgetsBinding is initialized before calling the
  // [NativeProxyReader.proxySetting] method.
  WidgetsFlutterBinding.ensureInitialized();

  final isConnectedToProxy = await AntiMitm.isConnectedToProxy();
  if (isConnectedToProxy) {
    debugPrint('Please disconnect from the proxy.');
  } else {
    debugPrint('Not connected to a proxy.');
  }
  runApp(const MyApp());
}

/// The main application widget.
///
/// This widget is the root of the application.
class MyApp extends StatelessWidget {
  /// Creates a new instance of [MyApp].
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

/// A widget that displays the home page of the application.
///
/// This widget is stateful and keeps track of a counter value.
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

  /// Increments the counter value.
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
    debugPrint('AppLifecycleState: $state');
    switch (state) {
      case AppLifecycleState.resumed:
        final isConnectedToProxy = await AntiMitm.isConnectedToProxy();
        if (isConnectedToProxy) {
          debugPrint('Please disconnect from the proxy.');
        } else {
          debugPrint('Not connected to a proxy.');
        }
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
        throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
