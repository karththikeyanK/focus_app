import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../provider/route_provider.dart';

void main() {
  runApp(const MaterialApp(home: PermissionGuideScreen()));
}

class PermissionGuideScreen extends StatefulWidget {
  const PermissionGuideScreen({super.key});

  @override
  State<PermissionGuideScreen> createState() => _PermissionGuideScreenState();
}

class _PermissionGuideScreenState extends State<PermissionGuideScreen> {
  static const platform = MethodChannel('com.gingerx.focus_app/service');
  bool _isPermissionGranted = false;
  bool _isCheckingPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    setState(() => _isCheckingPermission = true);
    try {
      final bool isEnabled = await platform.invokeMethod('isAccessibilityEnabled');
      setState(() {
        _isPermissionGranted = isEnabled;
        _isCheckingPermission = false;
      });
    } on PlatformException catch (e) {
      print("Error checking permission: ${e.message}");
      setState(() => _isCheckingPermission = false);
    } on MissingPluginException {
      setState(() => _isCheckingPermission = false);
    }
  }

  Future<void> _openAccessibilitySettings() async {
    try {
      await platform.invokeMethod('openAccessibilitySettings');
      // Re-check permission after returning from settings
      await _checkPermission();
    } on PlatformException catch (e) {
      print("Error opening settings: ${e.message}");
      // Fallback to general app settings
      await platform.invokeMethod('openAppSettings');
      await _checkPermission();
    } on MissingPluginException {
      // If platform code isn't implemented, fallback to app settings
      await platform.invokeMethod('openAppSettings');
      await _checkPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Permission Required"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).go(DASHBOARD),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "App Lock requires Accessibility Service permission to work properly",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            const Text(
              "Please follow these steps:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            _buildStep("1. Tap the 'Open Settings' button below"),
            _buildStep("2. Find 'Focus App' in the services list"),
            _buildStep("3. Toggle the switch to enable the service"),
            _buildStep("4. Return to this app"),
            const SizedBox(height: 30),
            const Text(
              "This permission allows the app to detect when other apps are opened and block them according to your settings.",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _openAccessibilitySettings,
                child: const Text("Open Settings"),
              ),
            ),
            const SizedBox(height: 20),
            if (_isCheckingPermission)
              const CircularProgressIndicator()
            else if (_isPermissionGranted)
              ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).go(ADD_APPROVER);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text("Continue to App", style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}