

import 'package:flutter/services.dart';

import '../model/app_and_detail.dart';
import 'apps_utill.dart';

const platform = MethodChannel('com.gingerx.focus_app/service');


Future<void> handleAppLock() async {
  try {
    // 1. Ensure accessibility service is enabled
    final bool isEnabled = await platform.invokeMethod('isAccessibilityEnabled');
    if (!isEnabled) {
      await platform.invokeMethod('enableAppLock', []);
      return;
    }

    // 2. Get all installed apps
    final List<AppAndDetail> apps = await getInstalledAppsSimple();
    final lockedApps = apps
        .where((app) => app.appDetailRequest.appId != "com.gingerx.focus_app")
        .map((app) => app.appDetailRequest.appId)
        .toList();

    // 3. Update locked apps
    if (lockedApps.isNotEmpty) {
      await platform.invokeMethod('updateLockedApps', lockedApps);

      // 4. Start persistent service
      await platform.invokeMethod('startPersistentService');
    }
  } catch (e) {
    print("Error in handleAppLock: $e");
  }
}