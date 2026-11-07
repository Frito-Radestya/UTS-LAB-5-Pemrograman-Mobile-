import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:kage/l10n/app_localizations.dart';

import 'package:kage/data/repositories/auth_repository.dart';
import 'package:kage/data/repositories/history_repository.dart';
import 'package:kage/data/repositories/quiz_repository.dart';
import 'package:kage/models/models.dart';
import 'package:kage/features/history/badge_page.dart';
import 'package:kage/features/history/detail_riwayat_page.dart';
import 'package:kage/features/home/beranda_page.dart';
import 'package:kage/features/quiz/detail_kategori_page.dart';
import 'package:kage/features/quiz/hasil_page.dart';
import 'package:kage/features/quiz/kategori_page.dart';
import 'package:kage/features/quiz/kuis_page.dart';
import 'package:kage/features/auth/login_page.dart';
import 'package:kage/features/settings/bantuan_page.dart';
import 'package:kage/features/settings/pengaturan_page.dart';
import 'package:kage/features/quiz/penjelasan_page.dart';
import 'package:kage/features/profile/profil_page.dart';
import 'package:kage/features/auth/register_page.dart';
import 'package:kage/features/history/riwayat_page.dart';
import 'package:kage/features/splash/splash_page.dart';
import 'package:kage/app_services.dart';
import 'package:kage/features/auth/auth_controller.dart';
import 'package:kage/features/history/history_controller.dart';
import 'package:kage/features/profile/progress_controller.dart';
import 'package:kage/features/quiz/quiz_controller.dart';
import 'package:kage/features/settings/settings_controller.dart';
import 'package:kage/theme/app_colors.dart';
import 'package:kage/theme/app_theme.dart';

const double _tabletMaxContentWidth = 720;
const double _desktopMaxContentWidth = 880;

/// Transisi halus yang konsisten di seluruh aplikasi: konten memudar masuk
/// sambil bergeser sedikit ke atas.
Page<void> _page(Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.02),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

GoRouter createRouter(
  AppServices services, {
  String initialLocation = '/',
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  final auth = services.auth;
  final quiz = services.quiz;
  return GoRouter(
    navigatorKey: navigatorKey ?? GlobalKey<NavigatorState>(),
    initialLocation: initialLocation,
    refreshListenable: services.routerListenable,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAuthRoute =
          location == '/' || location == '/login' || location == '/register';

      if (!auth.loggedIn) {
        return isAuthRoute ? null : '/login';
      }
      if (location == '/login' || location == '/register') {
        return '/beranda';
      }

      // Detail riwayat butuh data percobaan yang dititipkan saat navigasi.
      if (location == '/riwayat/detail' && state.extra is! QuizResult) {
        return '/riwayat';
      }

      // Halaman kuis hanya boleh dibuka jika ada sesi kuis yang berjalan.
      if (location == '/kuis' ||
          location == '/penjelasan' ||
          location == '/hasil') {
        if (quiz.activeCategory == null) return '/beranda';
        if (location == '/penjelasan' && quiz.currentQuestion == null) {
          return '/beranda';
        }
        if (location == '/hasil' && quiz.lastResult == null) {
          return '/beranda';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _page(const SplashPage()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _page(const LoginPage()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _page(const RegisterPage()),
      ),
      GoRoute(
        path: '/beranda',
        pageBuilder: (context, state) => _page(const BerandaPage()),
      ),
      GoRoute(
        path: '/kategori',
        pageBuilder: (context, state) => _page(const KategoriPage()),
      ),
      GoRoute(
        path: '/kategori/:id',
        pageBuilder: (context, state) {
          final id = CategoryId.values.byName(state.pathParameters['id']!);
          return _page(DetailKategoriPage(id: id));
        },
      ),
      GoRoute(
        path: '/kuis',
        pageBuilder: (context, state) => _page(const KuisPage()),
      ),
      GoRoute(
        path: '/penjelasan',
        pageBuilder: (context, state) => _page(const PenjelasanPage()),
      ),
      GoRoute(
        path: '/hasil',
        pageBuilder: (context, state) => _page(const HasilPage()),
      ),
      GoRoute(
        path: '/riwayat',
        pageBuilder: (context, state) => _page(const RiwayatPage()),
        routes: [
          GoRoute(
            path: 'detail',
            pageBuilder: (context, state) =>
                _page(DetailRiwayatPage(result: state.extra! as QuizResult)),
          ),
        ],
      ),
      GoRoute(
        path: '/profil',
        pageBuilder: (context, state) => _page(const ProfilPage()),
      ),
      GoRoute(
        path: '/badge',
        pageBuilder: (context, state) => _page(const BadgePage()),
      ),
      GoRoute(
        path: '/pengaturan',
        pageBuilder: (context, state) => _page(const PengaturanPage()),
      ),
      GoRoute(
        path: '/bantuan',
        pageBuilder: (context, state) => _page(const BantuanPage()),
      ),
    ],
  );
}

class KageApp extends StatefulWidget {
  const KageApp({super.key, required this.services});

  /// Layanan yang sudah memuat data dari penyimpanan lokal sebelum aplikasi
  /// dijalankan.
  final AppServices services;

  @override
  State<KageApp> createState() => _KageAppState();
}

class _KageAppState extends State<KageApp> with WidgetsBindingObserver {
  late final AppServices _services;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _services = widget.services;
    _router = createRouter(_services);
  }

  @override
  void didChangePlatformBrightness() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _router.dispose();
    _services.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: _services.auth),
        ChangeNotifierProvider<QuizController>.value(value: _services.quiz),
        ChangeNotifierProvider<HistoryController>.value(
          value: _services.history,
        ),
        ChangeNotifierProvider<ProgressController>.value(
          value: _services.progress,
        ),
        ChangeNotifierProvider<SettingsController>.value(
          value: _services.settings,
        ),
        Provider<AuthRepository>.value(value: _services.authRepository),
        Provider<QuizRepository>.value(value: _services.quizRepository),
        Provider<HistoryRepository>.value(value: _services.historyRepository),
      ],
      child: Consumer<SettingsController>(
        builder: (context, settings, _) {
          final platformBrightness =
              WidgetsBinding.instance.platformDispatcher.platformBrightness;
          final isLight = settings.theme == KageTheme.terang ||
              (settings.theme == KageTheme.sistem &&
                  platformBrightness == Brightness.light);
          AppColors.isLight = isLight;
          _applySystemBars(settings.theme);
          return MaterialApp.router(
            title: 'KAGE — The Quiz Sanctuary',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeAnimationDuration: Duration.zero,
            themeMode: switch (settings.theme) {
              KageTheme.gelap => ThemeMode.dark,
              KageTheme.terang => ThemeMode.light,
              KageTheme.sistem => ThemeMode.system,
            },
            locale: Locale(settings.localeCode),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _router,
            builder: _responsiveFrame,
          );
        },
      ),
    );
  }

  /// Menyamakan warna bilah sistem dengan pilihan tema.
  void _applySystemBars(KageTheme theme) {
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final brightness = switch (theme) {
      KageTheme.gelap => Brightness.dark,
      KageTheme.terang => Brightness.light,
      KageTheme.sistem => platformBrightness,
    };
    SystemChrome.setSystemUIOverlayStyle(
      brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
  }

  /// Tata letak adaptif untuk Android (mobile), tablet, dan laptop/web:
  /// latar belakang, TopWash, dan navigasi bawah membentang penuh (full-bleed),
  /// sedangkan isi halaman diatur proporsional di tengah layar lebar.
  Widget _responsiveFrame(BuildContext context, Widget? child) {
    if (child == null) return const SizedBox.shrink();
    final media = MediaQuery.maybeOf(context);
    if (media == null) return child;

    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final themeSetting = _services.settings.theme;
    AppColors.isLight = themeSetting == KageTheme.terang ||
        (themeSetting == KageTheme.sistem &&
            platformBrightness == Brightness.light);

    final w = media.size.width;
    final double targetMax;
    if (w >= 1024) {
      targetMax = _desktopMaxContentWidth;
    } else if (w >= 600) {
      targetMax = _tabletMaxContentWidth;
    } else {
      targetMax = w;
    }

    final extraHorizontal = w > targetMax ? (w - targetMax) / 2 : 0.0;
    final paddedMedia = media.copyWith(
      padding: media.padding.copyWith(
        left: media.padding.left + extraHorizontal,
        right: media.padding.right + extraHorizontal,
      ),
      viewPadding: media.viewPadding.copyWith(
        left: media.viewPadding.left + extraHorizontal,
        right: media.viewPadding.right + extraHorizontal,
      ),
    );

    return ColoredBox(
      color: AppColors.background,
      child: MediaQuery(
        data: paddedMedia,
        child: child,
      ),
    );
  }
}
