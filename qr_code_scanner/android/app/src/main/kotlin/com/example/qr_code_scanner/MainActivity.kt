package com.example.flutter_native_integration

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "flutterToNative") {
                val flutterMessage = call.argument<String>("flutterMessage")
                println("Received from Flutter: $flutterMessage")

                // Send back response
                result.success("Native received: $flutterMessage")

                // Example: Sending back to Flutter after 3 seconds
                Handler(Looper.getMainLooper()).postDelayed({
                    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                        .invokeMethod("nativeToFlutter", "Message from Native after delay")
                }, 3000)
            }
        }
    }
}
