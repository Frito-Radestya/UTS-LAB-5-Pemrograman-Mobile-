import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:kage/app_services.dart';
import 'package:kage/features/auth/auth_controller.dart';
import 'package:kage/features/auth/login_page.dart';
import 'package:kage/features/auth/register_page.dart';
import 'package:kage/features/history/history_controller.dart';
import 'package:kage/features/profile/progress_controller.dart';
import 'package:kage/features/quiz/quiz_controller.dart';
import 'package:kage/features/splash/splash_page.dart';
import 'package:kage/theme/app_theme.dart';

class KageApp extends StatefulWidget {
  const KageApp({super.key, required this.services});

  final AppServices services;

  @override
  State<KageApp> createState() => _KageAppState();
}

class _KageAppState extends State<KageApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final auth = widget.services.auth;

    _router = GoRouter(
      initialLocation: '/',
      refreshListenable: widget.services.routerListenable,
      redirect: (context, state) {
        final loc = state.matchedLocation;
        final loggedIn = auth.loggedIn;

        final isAuthRoute = loc == '/login' || loc == '/register';
        final isSplash = loc == '/';

        if (!loggedIn) {
          if (isSplash || isAuthRoute) return null;
          return '/login';
        }

        if (isSplash || isAuthRoute) {
          return '/beranda';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/beranda',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Beranda')),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _router.dispose();
    widget.services.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(
          value: widget.services.auth,
        ),
        ChangeNotifierProvider<HistoryController>.value(
          value: widget.services.history,
        ),
        ChangeNotifierProvider<ProgressController>.value(
          value: widget.services.progress,
        ),
        ChangeNotifierProvider<QuizController>.value(
          value: widget.services.quiz,
        ),
      ],
      child: MaterialApp.router(
        title: 'KAGE',
        theme: AppTheme.dark(),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
