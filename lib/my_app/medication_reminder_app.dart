import '../Fetures/home/screens/home_caretaker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
class MedicationReminderApp extends StatelessWidget {
  const MedicationReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      builder: (context, child) {
      return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
              top: false,
            child: child!),
    );
      },
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'EG'),

      supportedLocales: const [
        Locale('ar', 'EG'),
        Locale('en', 'US'),
      ],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

// mohamed medhat 
     home: const home_caretaker_screen(),
//dev two
//home: RootPage(),
    theme:  ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'NotoSansArabic',
      ),
    );
  }
}