import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  static const platform = MethodChannel('com.gingerx.focus_app/service');
  List<String> _lockedApps = ["com.facebook.katana", "com.instagram.android"];
  final List<String> _allApps = ["com.facebook.katana", "com.instagram.android", "com.whatsapp"]; // Add more if needed
  bool _isServiceEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkAccessibilityStatus();
  }

  Future<void> _checkAccessibilityStatus() async {
    try {
      final bool isEnabled = await platform.invokeMethod('isAccessibilityEnabled');
      setState(() => _isServiceEnabled = isEnabled);
    } on PlatformException catch (e) {
      print("Error: ${e.message}");
    }
  }

  Future<void> _enableAppLock() async {
    try {
      await platform.invokeMethod('enableAppLock', _lockedApps);
      setState(() => _isServiceEnabled = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Go to Settings → Enable Accessibility Service")),
      );
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: ${e.message}")),
      );
    }
  }

  void _toggleAppLock(String packageName) async {
    setState(() {
      if (_lockedApps.contains(packageName)) {
        _lockedApps.remove(packageName);
      } else {
        _lockedApps.add(packageName);
      }
    });

    try {
      await platform.invokeMethod('updateLockedApps', _lockedApps);
    } on PlatformException catch (e) {
      print("Failed to update locked apps: ${e.message}");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("App Lock")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text("Enable App Lock"),
              value: _isServiceEnabled,
              onChanged: (value) {
                if (!_isServiceEnabled) {
                  _enableAppLock();
                }
              },
            ),
            const SizedBox(height: 20),
            const Text("Locked Apps:", style: TextStyle(fontWeight: FontWeight.bold)),
            Column(
              children: _allApps.map((app) {
                final isLocked = _lockedApps.contains(app);
                return ListTile(
                  title: Text(app),
                  trailing: IconButton(
                    icon: Icon(
                      isLocked ? Icons.lock : Icons.lock_open,
                      color: isLocked ? Colors.red : Colors.grey,
                    ),
                    onPressed: _isServiceEnabled
                        ? () => _toggleAppLock(app)
                        : null, // Disable when service is off
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
