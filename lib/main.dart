import 'dart:async';

import 'package:agent/ui/layouts/global_return_widgets/future_state_func.dart';
import 'package:agent/ui/layouts/global_state_widgets/_other_custom_widgets/custom_error_page/error_page.dart';
import 'package:agent/ui/layouts/styleconfig/themedata.dart';
import 'package:agent/ui/page_auth/login_screen.dart';
import 'package:agent/ui/page_auth/onboarding_screen.dart';
import 'package:agent/ui/page_auth/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/constant_values/_constant_text_values.dart';
import 'core/constant_values/_setting_value/log_app_values.dart';
import 'core/state_management/providers/_global_widget/fcm_notification_provider.dart';
import 'core/state_management/providers/_global_widget/location_provider.dart';
import 'core/state_management/providers/_global_widget/main_navbar_provider.dart';
import 'core/state_management/providers/_global_widget/navigator_provider.dart';
import 'core/state_management/providers/_global_widget/realtime_provider.dart';
import 'core/state_management/providers/_settings/appearance_provider.dart';
import 'core/state_management/providers/_settings/dev_mode_provider.dart';
import 'core/state_management/providers/_settings/log_app_provider.dart';
import 'core/state_management/providers/_settings/permission_provider.dart';
import 'core/state_management/providers/_settings/preference_provider.dart';
import 'core/state_management/providers/auth/user_provider.dart';
import 'core/utilities/functions/logger_func.dart';
import 'core/utilities/functions/page_routes_func.dart';
import 'core/utilities/functions/system_func.dart';
import 'core/utilities/local_storage/sqflite/_initialize/init_sqflite.dart';
import 'core/utilities/local_storage/sqflite/services/_setting_services/log_app_services.dart';

Future<void> main() async {
  PlatformDispatcher.instance.onError = (e, s) {
    clog('Terjadi masalah di logika aplikasi. Ditangkap oleh PlatformDispatcher: $e\n$s');
    addLogApp(level: ListLogAppLevel.critical.level, title: '[LogicRootError], ${e.toString()}', logs: s.toString().length > 3000 ? s.toString().substring(0, 3000) : s.toString());
    // FirebaseCrashlytics.instance.recordError(e, s, fatal: true);
    return true;
  };

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      // await Firebase.initializeApp(name: appNameText, options: DefaultFirebaseOptions.currentPlatform).then((value) => FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode));
      // await FirebaseAppCheck.instance.activate(webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'), androidProvider: AndroidProvider.debug, appleProvider: AppleProvider.appAttest);
      ErrorWidget.builder = (details) => ErrorPage(details: details);
      // FlutterError.onError = (details) {
      //   clog('Terjadi masalah di UI aplikasi. Ditangkap oleh FlutterError: ${details.exception}\n${details.stack}');
      //   addLogApp(level: ListLogAppLevel.critical.level, title: '[FlutterError], ${details.exception.toString()}',
      //       logs: details.stack.toString().length > 3000 ? details.stack.toString().substring(0, 3000) : details.stack.toString());
      //   // FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      // };
      await getInitialAppearancesData();
      // await setTimezone();
      await getUserDeviceInfo();
      await SqfliteDatabaseHelper.initializeSqflite();
    } catch (e, s) {
      clog('Terjadi masalah ketika initMain: $e\n$s');
      // FirebaseCrashlytics.instance.recordError(e, s, fatal: true);
    } finally {
      await initializeDateFormatting().then((_) async {
        await getPlatformOrientiation();
        runApp(const MyApp());
      });
    }
  }, (e, s) {
    clog('Terjadi masalah di logika aplikasi. Ditangkap oleh runZonedGuarded: $e\n$s');
    addLogApp(level: ListLogAppLevel.critical.level, title: '[LogicZoneError], ${e.toString()}', logs: s.toString().length > 3000 ? s.toString().substring(0, 3000) : s.toString());
    // FirebaseCrashlytics.instance.recordError(e, s, fatal: true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        /// Provider bawaan. Jangan dihapus atau dipindah!
        ChangeNotifierProvider(create: (_) => AppearanceSettingProvider()),
        ChangeNotifierProvider(create: (_) => PreferenceSettingProvider()),
        ChangeNotifierProvider(create: (_) => PermissionSettingProvider()),
        ChangeNotifierProvider(create: (_) => LogAppSettingProvider()),
        ChangeNotifierProvider(create: (_) => DevModeProvider()),
        Provider(create: (_) => NavigatorProvider()),
        ChangeNotifierProvider(create: (_) => RealtimeProvider(context), lazy: false),
        /// Tambahin provider Anda dibawah ini
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => FcmNotificationProvider()),
        ChangeNotifierProvider(create: (_) => MainNavbarProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      /// Jika ingin menambahkan MultiBlocProvider atau ScreenUtil, tambahkan diatas Builder
      child: Builder(
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await Provider.of<RealtimeProvider>(context, listen: false).initialize(context);
          });
          return Consumer<AppearanceSettingProvider>(
            builder: (context, provider, child) {
              return MaterialApp(
                navigatorKey: NavigatorProvider.navigatorKey,
                title: appNameText,
                debugShowCheckedModeBanner: false,
                // showPerformanceOverlay: true,
                theme: globalThemeData(context, provider),
                darkTheme: ThemeData(
                  brightness: provider.brightnessDarkTheme,
                  colorScheme: provider.trueBlack ? const ColorScheme.dark().copyWith(surface: Colors.black) : null,
                ),
                themeMode: ThemeMode.system,
                home: InitialScreen(),
              );
            }
          );
        }
      ),
    );
  }
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AppearanceSettingProvider.read(context).initData(context),
      builder: (context, snapshot) {
        if (snapshot.hasError) return onFailedState(context: context, description: 'MyApp Error: ${snapshot.error}', onTap: () => startScreenSwipe(context, LoginScreen()));
        if (snapshot.connectionState == ConnectionState.done) {
          clog('Apakah user terverifikasi? ${snapshot.data}');
          if (snapshot.data == false) return const OnboardingScreen();
          if (snapshot.data != false) return const LoginScreen();
        }
        return const SplashScreen();
      },
    );
  }
}
