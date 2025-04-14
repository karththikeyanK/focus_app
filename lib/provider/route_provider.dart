import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_app/page/app/app_lock.dart';
import 'package:focus_app/page/app/listapps.dart';
import 'package:focus_app/page/dashboard.dart';
import 'package:focus_app/page/login_screen.dart';
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


      GoRoute(path: NOT_FOUND_PAGE,builder: (context,state)=> const Error404Page()),

    ],
  );
});
