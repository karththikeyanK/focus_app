import 'package:flutter/material.dart';
import 'package:focus_app/page/app/app_lock.dart';
import 'package:focus_app/page/approver/add_aprover.dart';
import 'package:focus_app/page/approver/view_approve_request.dart';

import 'app/listapps.dart';
import 'dashboard/log.dart';
import 'dashboard/setting.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildFunctionButton(
              context,
              icon: Icons.send,
              label: 'Add Request',
              color: Colors.blue,
              onTap: () => _navigateTo(context, const AddApproverPage()),
            ),
            _buildFunctionButton(
              context,
              icon: Icons.control_camera,
              label: 'View Requests',
              color: Colors.green,
              onTap: () => _navigateTo(context, const ApproveRequestsPage()),
            ),
            _buildFunctionButton(
              context,
              icon: Icons.list_alt,
              label: 'Logs',
              color: Colors.orange,
              onTap: () => _navigateTo(context, const ListApps()),
            ),
            _buildFunctionButton(
              context,
              icon: Icons.settings,
              label: 'Settings',
              color: Colors.purple,
              onTap: () => _navigateTo(context, const AppLockScreen()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunctionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

