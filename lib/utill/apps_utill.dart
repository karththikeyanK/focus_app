import 'dart:convert';

import 'package:focus_app/model/app_and_detail.dart';
import 'package:focus_app/model/app_detail_request.dart';
import 'package:focus_app/utill/Appconstant.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';

import '../model/app_request.dart';

Future<List<AppAndDetail>> getInstalledAppsSimple({bool includeSystemApps = false}) async {
  try {
    final List<AppInfo> apps = await InstalledApps.getInstalledApps(
      !includeSystemApps, // exclude system apps if false
      true, // no need to load icons
      '', // no package name prefix filter
    );


    List<AppAndDetail> appDetails = [];
    for (var app in apps) {
      AppAndDetail appDetail = AppAndDetail(
        appRequest: AppRequest(
          id: null,
          appDetailId: 0,
          status: '',
          userId: AppsConstant.userId,
        ),
        appDetailRequest: AppDetailRequest(
          id: null,
          appId: app.packageName,
          appName: app.name,
          appImageUrl: "",
          appImage: base64Encode(app.icon!).toString(),
        ),
      );
      appDetails.add(appDetail);
    }
    return appDetails;
  } catch (e) {
    print('Error fetching apps: $e');
    return [];
  }
}