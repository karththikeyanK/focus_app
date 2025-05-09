import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class ListApps extends StatefulWidget {
  const ListApps({super.key});

  @override
  State<ListApps> createState() => _ListAppsState();
}

class _ListAppsState extends State<ListApps> {
  List<AppInfo> apps = [];
  List<AppInfo> filteredApps = [];
  bool isLoading = true;
  bool includeSystemApps = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadApps();
  }

  Future<void> loadApps() async {
    try {
      setState(() => isLoading = true);

      final installedApps = await InstalledApps.getInstalledApps(
        !includeSystemApps, // exclude system apps based on toggle
        true, // include app icons
        '', // no package name prefix filter
      );

      setState(() {
        apps = installedApps;
        _applyFilters();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Error loading apps: $e');
    }
  }

  void _applyFilters() {
    filteredApps = apps.where((app) {
      final matchesSearch = app.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          app.packageName.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    // Sort alphabetically
    filteredApps.sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> _launchApp(String packageName) async {
    try {
      await InstalledApps.startApp(packageName);
    } catch (e) {
      _showError('Could not launch app: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Installed Apps'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => setState(() {
              includeSystemApps = !includeSystemApps;
              loadApps();
            }),
            tooltip: includeSystemApps ? 'Hide system apps' : 'Show system apps',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search apps...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _applyFilters();
                });
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: loadApps,
              child: filteredApps.isEmpty
                  ? Center(
                child: Text(
                  searchQuery.isEmpty
                      ? 'No apps found'
                      : 'No apps matching "$searchQuery"',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              )
                  : ListView.builder(
                itemCount: filteredApps.length,
                itemBuilder: (context, index) {
                  final app = filteredApps[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: app.icon != null
                          ? Image.memory(
                        app.icon!,
                        width: 40,
                        height: 40,
                      )
                          : const Icon(Icons.android, size: 40),
                      title: Text(
                        app.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(app.packageName),
                          Text(
                            'Version: ${app.versionName} (${app.versionCode})',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () => _showAppDetails(app),
                      ),
                      onTap: () => _launchApp(app.packageName),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAppDetails(AppInfo app) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(app.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (app.icon != null)
                Center(
                  child: Image.memory(
                    app.icon!,
                    width: 64,
                    height: 64,
                  ),
                ),
              const SizedBox(height: 16),
              Text('Package: ${app.packageName}'),
              Text('Version: ${app.versionName} (${app.versionCode})'),
              Text('Installed: ${_formatDate(app.installedTimestamp)}'),
              const SizedBox(height: 16),
              // Text('Built with: ${_getBuiltWith(app.builtWith)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              InstalledApps.openSettings(app.packageName);
              Navigator.pop(context);
            },
            child: const Text('App Settings'),
          ),
        ],
      ),
    );
  }

  String _formatDate(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp)
        .toString()
        .split(' ')[0];
  }
}