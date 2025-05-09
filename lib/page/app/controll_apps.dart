// screens/controlled_apps_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_app/model/app_and_detail_response.dart';
import 'package:focus_app/provider/app_provicer.dart';
import 'package:focus_app/services/api_service.dart';
import 'package:go_router/go_router.dart';

import '../../provider/route_provider.dart';

class ControlledAppsPage extends ConsumerWidget {
  const ControlledAppsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(allAppsProvider);

    return Scaffold(
     appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).go(DASHBOARD);
          },
        ),
        title: const Text('Controlled Apps'),
        centerTitle: true,
      ),
      body: appsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (apps) {
          if (apps.isEmpty) {
            return const Center(child: Text('No apps found'));
          }
          return ListView.builder(
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return _RestrictedAppTile(app: app);
            },
          );
        },
      ),
    );
  }
}

class _RestrictedAppTile extends ConsumerWidget {
  final AppAndDetailResponse app;

  const _RestrictedAppTile({required this.app});

@override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the status directly from the appResponse object
    final isRestricted = app.appRequest.status == 'RESTRICTED';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: app.appDetailRequest.appImageUrl.isNotEmpty
            ? Image.network(
                '$image_url${app.appDetailRequest.appImageUrl}',
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.android, size: 40),
              )
            : const Icon(Icons.android, size: 40),
        title: Text(
          app.appDetailRequest.appName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(app.appDetailRequest.appId),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isRestricted ? Colors.red : Colors.green,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            // Toggle the status locally without fetching from the server
            final newStatus = isRestricted ? 'ALLOWED' : 'RESTRICTED';

          },
          child: Text(isRestricted ? 'Allow' : 'Restrict'),
        ),
      ),
    );
  }
}