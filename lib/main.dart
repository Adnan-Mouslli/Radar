import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radar/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/services.dart';
import 'core/theme/app_theme.dart';
import 'bindings/intialbindings.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialServices();
  Intl.defaultLocale = 'ar';
  await initializeDateFormatting('ar', null);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.black, // لون شريط الحالة
    statusBarIconBrightness: Brightness.light, // لون الأيقونات (فاتح/غامق)
    systemNavigationBarColor: Colors.black, // لون شريط التنقل السفلي
    systemNavigationBarIconBrightness:
        Brightness.light, // لون أيقونات شريط التنقل
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Radar',
      locale: const Locale('ar'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // أو ThemeMode.light أو ThemeMode.dark
      initialBinding: InitialBindings(),
      getPages: routes,
    );
  }
}
