// ignore_for_file: unused_local_variable
import 'dart:convert';

import 'package:anti_mitm/native_flutter_proxy.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() async {
  // Ensure that the WidgetsBinding is initialized before calling the
  // [NativeProxyReader.proxySetting] method.
  WidgetsFlutterBinding.ensureInitialized();

  final isConnectedToSensitiveProxy = await AntiMitm.isConnectedToSensitiveProxy();
  if (isConnectedToSensitiveProxy) {
    debugPrint('App is connecting to a sensitive proxy, please disable all connection.');
    NetworkBlocker.enableNetworkBlocking();
  } else {
    debugPrint('Seems the app is safety for enable connection.');
    NetworkBlocker.disableNetworkBlocking();
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
  String _apiResponse = 'Chưa có request nào';
  bool _isLoading = false;
  bool _isNetworkBlocked = false;

  /// Increments the counter value.
  void _incrementCounter() => setState(() => counter++);

  /// Fetch demo API
  Future<void> _fetchDemoApi() async {
    setState(() {
      _isLoading = true;
      _apiResponse = 'Đang gửi request...';
    });

    try {
      // Demo API endpoint - JSONPlaceholder
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _apiResponse = '''✅ Request thành công!
Status: ${response.statusCode}
Title: ${data['title']}
Body: ${data['body'].toString().substring(0, 50)}...
Network blocked: $_isNetworkBlocked''';
        });
      } else {
        setState(() {
          _apiResponse = '''❌ Request thất bại!
Status: ${response.statusCode}
Network blocked: $_isNetworkBlocked''';
        });
      }
    } catch (e) {
      setState(() {
        _apiResponse = '''🚫 Request bị chặn hoặc lỗi!
Error: $e
Network blocked: $_isNetworkBlocked''';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Check network status
  void _updateNetworkStatus() {
    setState(() {
      _isNetworkBlocked = NetworkBlocker.isNetworkBlocked;
    });
  }

  @override
  void initState() {
    super.initState();
    // Đăng ký observer
    WidgetsBinding.instance.addObserver(this);
    // Update network status initially
    _updateNetworkStatus();
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
        final isConnectedToSensitiveProxy = await AntiMitm.isConnectedToSensitiveProxy();
        if (isConnectedToSensitiveProxy) {
          debugPrint('App is connecting to a sensitive proxy, please disable all connection.');
          NetworkBlocker.enableNetworkBlocking();
        } else {
          debugPrint('Seems the app is safety for enable connection.');
          NetworkBlocker.disableNetworkBlocking();
        }
        // Update network status after checking
        _updateNetworkStatus();
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
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: _isNetworkBlocked ? Colors.red : Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Network Status Indicator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isNetworkBlocked ? Colors.red.shade100 : Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isNetworkBlocked ? Colors.red : Colors.green,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isNetworkBlocked ? Icons.block : Icons.wifi,
                    color: _isNetworkBlocked ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isNetworkBlocked ? '🚫 Network Blocked' : '✅ Network Active',
                    style: TextStyle(
                      color: _isNetworkBlocked ? Colors.red.shade700 : Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // API Test Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _fetchDemoApi,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.api),
              label: Text(_isLoading ? 'Đang gửi request...' : 'Test API Request'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),

            // Response Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'API Response:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _apiResponse,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Counter section (existing)
            const Text(
              'Counter Demo:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'You have pushed the button this many times:',
              textAlign: TextAlign.center,
            ),
            Text(
              '$counter',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
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
