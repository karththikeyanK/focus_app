import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/app_and_detail_response.dart';
import '../services/app_service.dart';

final appprovider = Provider((ref) => AppService());

final allAppsProvider = FutureProvider.autoDispose<List<AppAndDetailResponse>>((ref) async {
  return ref.read(appprovider).getAllApps();
});