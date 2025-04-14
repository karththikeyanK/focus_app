import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_app/config/push_notification_config.dart';
import 'package:focus_app/provider/route_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add error handling for Firebase initialization
  try {
    await Firebase.initializeApp();
    await PushNotificationConfig().initialise();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Lock device orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Focus',
      debugShowCheckedModeBanner: false, // Consider adding this
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
      backButtonDispatcher: router.backButtonDispatcher,
    );
  }
}