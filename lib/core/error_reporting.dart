import 'package:flutter/foundation.dart';

/// Pelaporan error aplikasi (R-04).
///
/// Saat ini memakai hook bawaan Flutter tanpa mengirim data pribadi.
/// Dapat diganti dengan Firebase Crashlytics atau Sentry bila dikonfigurasi.
class ErrorReporter {
  const ErrorReporter._();

  static void initialize() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (kDebugMode) {
        debugPrint(details.exceptionAsString());
        debugPrintStack(stackTrace: details.stack);
      }
      // TODO: kirim ke Crashlytics/Sentry tanpa data pribadi bila dikonfigurasi.
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      if (kDebugMode) {
        debugPrint('Uncaught platform error: $error');
        debugPrintStack(stackTrace: stack);
      }
      // TODO: kirim ke Crashlytics/Sentry tanpa data pribadi bila dikonfigurasi.
      return true;
    };
  }
}
