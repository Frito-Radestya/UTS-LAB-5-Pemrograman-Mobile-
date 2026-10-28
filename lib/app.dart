import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kage/app_services.dart';
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
    _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Login')),
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
    return MaterialApp.router(
      title: 'KAGE',
      theme: AppTheme.dark(),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
