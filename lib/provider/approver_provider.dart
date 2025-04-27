import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/approver_response.dart';
import '../services/approver_service.dart';

final approverServiceProvider = Provider((ref) => ApproverService());


final confirmApproverProvider = FutureProvider.autoDispose.family<bool, String>((ref, vcode) async {
  return ref.read(approverServiceProvider).confirmApproval(vcode);
});

final approverRequestProvider = FutureProvider.autoDispose.family<List<ApproverResponse>, int>((ref, userId) {
  return ref.read(approverServiceProvider).getApproverRequestBYApprover(userId);
});

