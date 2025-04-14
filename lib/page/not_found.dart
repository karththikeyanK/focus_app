import 'package:flutter/material.dart';
import 'package:focus_app/provider/route_provider.dart';
import 'package:go_router/go_router.dart';

import '../utill/Appconstant.dart';

class Error404Page extends StatelessWidget {
  const Error404Page({super.key});

  @override
  Widget build(BuildContext context) {
    final isAdmin = AppsConstant.userName == 'Admin'; // Example admin check
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFf5f7fa),
              Color(0xFFe4e8f0),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth > 800 ? 100 : 40,
            vertical: 60,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset(
                'assets/images/404-error.png',
                width: screenWidth > 800 ? 400 : 250,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),
              Text(
                'Page Not Found',
                style: TextStyle(
                  fontSize: screenWidth > 800 ? 42 : 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "The page you're looking for doesn't exist or has been moved.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth > 800 ? 18 : 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 40),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => context.go(LOGIN),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Go to Home'),
                  ),
                  if (isAdmin)
                    ElevatedButton(
                      onPressed: () => GoRouter.of(context).go(LOGIN),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Admin Settings'),
                    ),
                ],
              ),
              const Spacer(),
              TextButton(
                onPressed: () => ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Sorry Bro! Tata..'))),
                child: Text(
                  'Need help? Contact Support',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add this to your appconstant.dart file:
/*
class AppsConstant {
  static const String userName = 'Admin';
  static const String ADMIN_SETTINGS = '/admin-settings';
  // ... other constants
}
*/