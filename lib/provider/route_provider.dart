import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_app/page/app/app_lock.dart';
import 'package:focus_app/page/app/controll_apps.dart';
import 'package:focus_app/page/app/listapps.dart';
import 'package:focus_app/page/approver/add_aprover.dart';
import 'package:focus_app/page/dashboard.dart';
import 'package:focus_app/page/login_screen.dart';
import 'package:focus_app/page/permision/permision_guid.dart';
import 'package:focus_app/page/user/signup.dart';
import 'package:focus_app/page/user/verify_otp.dart';
import 'package:go_router/go_router.dart';

import '../page/not_found.dart';
import '../page/splash.dart';

// ignore_for_file: non_constant_identifier_names
final NOT_FOUND_PAGE = '/not-found';
final LOGIN = '/login';
final LIST_APP = '/list_app';
final LOCK_APP = 'lock-app';
final SIGNUP ='/signup';
final VERIFY_OTP = '/verify-otp';
final DASHBOARD = '/dashboard';
final ADD_APPROVER = '/add-approver';
final CONTROL_APPS = '/control-apps';
final ADD_PERMISON = '/add-permison';


final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashHome(),
      ),

      GoRoute(
        path: LOGIN,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: LIST_APP,
        builder: (context, state) => const ListApps(),
      ),

      GoRoute(
        path: LOCK_APP,
        builder: (context, state) => const AppLockScreen(),
      ),
      GoRoute(
        path: SIGNUP,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashHome(),
      ),
      GoRoute(
        path: VERIFY_OTP,
        builder: (context, state) => const OtpVerificationPage(),
      ),
      GoRoute(
        path: DASHBOARD,
        builder: (context, state) => const HomeDashboard(),
      ),

      GoRoute(
        path: ADD_APPROVER,
        builder: (context, state) => const AddApproverPage(),
      ),

      GoRoute(
        path: CONTROL_APPS,
        builder: (context, state) => const ControlledAppsPage(),
      ),

      GoRoute(
        path: ADD_PERMISON,
        builder: (context, state) => const PermissionGuideScreen(),
      ),

      GoRoute(path: NOT_FOUND_PAGE,builder: (context,state)=> const Error404Page()),

    ],
  );
});
