import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_app/utill/Appconstant.dart';
import 'package:focus_app/provider/approver_provider.dart';
import 'package:focus_app/model/approver_response.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey();

class ApproveRequestsPage extends ConsumerWidget {
  const ApproveRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approverRequestsAsync =
        ref.watch(approverRequestProvider(AppsConstant.userId));

    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Approval Requests'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  ref.refresh(approverRequestProvider(AppsConstant.userId)),
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: approverRequestsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Failed to load requests',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.refresh(approverRequestProvider(AppsConstant.userId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (requests) => _buildRequestList(context, ref, requests),
        ),
      ),
    );
  }

  Widget _buildRequestList(
      BuildContext context, WidgetRef ref, List<ApproverResponse> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 64, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(height: 16),
            Text(
              'No pending requests',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'All requests have been processed',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.refresh(approverRequestProvider(AppsConstant.userId));
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final request = requests[index];
          return _buildRequestCard(context, ref, request);
        },
      ),
    );
  }

  Widget _buildRequestCard(
      BuildContext context, WidgetRef ref, ApproverResponse request) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPending = request.status == 'PENDING';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showRequestDetails(context, request),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      request.userName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPending
                          ? colorScheme.primaryContainer
                          : colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      request.status,
                      style: TextStyle(
                        color: isPending
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSecondaryContainer,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Device: ${request.deviceName ?? 'Unknown'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              if (isPending) _buildActionButtons(context, ref, request),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, WidgetRef ref, ApproverResponse request) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.close, size: 18),
          label: const Text('Reject'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
          ),
          onPressed: () => _handleApproval(context, ref, request.id, false),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          icon: const Icon(Icons.check, size: 18),
          label: const Text('Approve'),
          onPressed: () => _handleApproval(context, ref, request.id, true),
        ),
      ],
    );
  }

  void _handleApproval(
      BuildContext context, WidgetRef ref, int requestId, bool isApproved) {
    final TextEditingController codeController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    AppsConstant.approveRequestId = requestId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isApproved ? Icons.check_circle : Icons.cancel,
              color: isApproved ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 12),
            Text(isApproved ? 'Confirm Approval' : 'Confirm Rejection'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isApproved
                    ? 'Are you sure you want to approve this request?'
                    : 'Are you sure you want to reject this request?',
              ),
              const SizedBox(height: 8),
              if (isApproved) ...[
                TextFormField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Enter approval code',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (isApproved && (value == null || value.isEmpty)) {
                      return 'Please enter an approval code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
              ],
              Text(
                isApproved
                    ? 'The user will gain access to the system.'
                    : 'This action cannot be undone.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: isApproved ? Colors.green : Colors.red,
            ),
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(context);

                if (isApproved) {
                  final approvalCode = codeController.text;
                  try {
                    final result = await ref
                        .read(confirmApproverProvider(approvalCode).future);

                    scaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content: Text(result
                            ? 'Request approved successfully'
                            : 'Approval failed. Invalid code.'),
                        backgroundColor: result ? Colors.green : Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );

                    if (result) {
                      ref.refresh(approverRequestProvider(AppsConstant.userId));
                    }
                  } catch (e) {
                    scaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  scaffoldMessengerKey.currentState?.showSnackBar(
                    SnackBar(
                      content: Text('Request rejected'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                  ref.refresh(approverRequestProvider(AppsConstant.userId));
                }
              }
            },
            child: Text(isApproved ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }

  void _showRequestDetails(BuildContext context, ApproverResponse request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Request Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            _buildDetailItem(
              context,
              icon: Icons.person,
              label: 'User',
              value: request.userName,
            ),
            _buildDetailItem(
              context,
              icon: Icons.phone_android,
              label: 'Device',
              value: request.deviceName ?? 'Unknown',
            ),
            _buildDetailItem(
              context,
              icon: Icons.info,
              label: 'Status',
              value: request.status,
              isStatus: true,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isStatus = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                ),
                const SizedBox(height: 4),
                if (isStatus)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: value == 'Pending'
                          ? colorScheme.primaryContainer
                          : colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        color: value == 'Pending'
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSecondaryContainer,
                      ),
                    ),
                  )
                else
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
