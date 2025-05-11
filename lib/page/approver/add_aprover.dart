import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_app/page/approver/verification_page.dart';
import 'package:focus_app/provider/route_provider.dart';
import 'package:focus_app/services/approver_service.dart';
import 'package:go_router/go_router.dart';

import '../../exception/general_exception.dart';
import '../../provider/approver_provider.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

final approverProvider = StateNotifierProvider<ApproverNotifier, AsyncValue<void>>(
      (ref) => ApproverNotifier(ref.read(approverServiceProvider)),
);

class ApproverNotifier extends StateNotifier<AsyncValue<void>> {
  final ApproverService _approverService;

  ApproverNotifier(this._approverService) : super(const AsyncValue.data(null));

  Future<String> addApprover(String email) async {
    state = const AsyncValue.loading();
    try {
      final deviceName = await getDeviceName();
      final verificationCode = await _approverService.approveRequest(email,deviceName);
      state = const AsyncValue.data(null);
      return verificationCode;
    } on GeneralException catch (e) {
      final userMessage = _mapExceptionToUserMessage(e);
      state = AsyncValue.error(userMessage, StackTrace.current);
      log("ApproverNotifier::addApprover()::General error: ${e.toString()}");
      throw Exception(userMessage);
    }  catch (e, st) {
      state = AsyncValue.error(
        "An unexpected error occurred. Please try again later.",
        st,
      );
      log("ApproverNotifier::addApprover()::Unexpected error: $e");
      throw Exception("An unexpected error occurred.");
    }
  }

  String _mapExceptionToUserMessage(GeneralException exception) {
    final message = exception.toString();

    if (message.contains("User cannot be approver")) {
      return "This user cannot be set as an approver. Please choose another user.";
    } else if (message.contains("Approver already exists")) {
      return "This user is already your approver.";
    } else if (message.contains("API Error")) {
      return "Server error occurred. Please try again later.";
    }

    return "Approver add failed. Please try again later.";
  }

  Future<String> getDeviceName() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return '${androidInfo.manufacturer} ${androidInfo.model}'; // e.g., Xiaomi Redmi Note 10
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return '${iosInfo.name} ${iosInfo.model}'; // e.g., iPhone 14
    } else {
      return 'Unknown Device';
    }
  }
}



class AddApproverPage extends ConsumerWidget {
  const AddApproverPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final state = ref.watch(approverProvider);
    if (state.hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Approver'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).go(DASHBOARD),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PrivacyNote(),
              const SizedBox(height: 24),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Approver Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () => _submitForm(context, ref, formKey, emailController.text),
                  child: state.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Add Approver'),
                ),
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Error: ${state.error}',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm(
      BuildContext context,
      WidgetRef ref,
      GlobalKey<FormState> formKey,
      String email,
      ) async {
    if (!formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Approver'),
        content: const Text('Are you sure you want to add this person as your approver? '
            'They will receive a verification code that you must share with them.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final vCode = await ref.read(approverProvider.notifier).addApprover(email);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Approver added successfully')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationCodePage(
            verificationCode: vCode,
          ),
        ),
      );
    }
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Important Note',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'This user will be alerted when you add them as an approver. '
                'You will receive a verification code that you must share with them directly. '
                'This confirms you are granting them access to help manage your app usage '
                'without compromising your personal data or privacy. '
                'The approver can only restrict app access, and you will need their permission '
                'to use restricted apps on your device.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}