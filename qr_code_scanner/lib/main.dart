import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp()); // Add const here

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key); // Add const constructor

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform = MethodChannel('com.example/native');

  final TextEditingController _controller = TextEditingController();
  String _nativeResponse = 'Waiting for native...';

  @override
  void initState() {
    super.initState();
    // Initialize the MethodChannel listener once
    _receiveFromNative();
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  Future<void> _sendToNative() async {
    String response;
    try {
      final String result = await platform.invokeMethod('flutterToNative', {
        "flutterMessage": _controller.text,
      });
      response = result;
    } on PlatformException catch (e) {
      response = "Failed to send: '${e.message}'.";
    } catch (e) {
      response = "An unexpected error occurred: $e";
    }

    // Update state to trigger a rebuild
    setState(() {
      _nativeResponse = response;
    });
  }

  // This will handle calls coming *from* the native side to Flutter
  void _receiveFromNative() {
    platform.setMethodCallHandler((call) async {
      if (call.method == "nativeToFlutter") {
        // Update state to trigger a rebuild with the new message
        setState(() {
          _nativeResponse = call.arguments.toString(); // Ensure it's a String
        });
        return "Message received by Flutter!"; // Optional: send a response back
      }
      // If you have other methods, handle them here
      return PlatformException(code: '404', message: 'Method not implemented');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter <-> Native')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Message to send to Native',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendToNative,
                child: const Text('Send to Native'),
              ),
              const SizedBox(height: 40), // More space
              const Text(
                'Native Response:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                _nativeResponse,
                style: const TextStyle(fontSize: 18, color: Colors.blueAccent),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}