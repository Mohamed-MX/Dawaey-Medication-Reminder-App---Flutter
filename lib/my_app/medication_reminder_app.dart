import 'package:dawaey/Fetures/Auth/data/models/user_model.dart';
import 'package:dawaey/Fetures/history/presentation/view/history_screen.dart';
import 'package:dawaey/Fetures/medications/data/model/medication_model.dart';
import 'package:dawaey/Fetures/medications/presentation/view/add_medication_screen.dart';
import 'package:dawaey/Fetures/medications/presentation/view/medication_details_screen.dart';
import 'package:month_year_picker/month_year_picker.dart';

import '../Fetures/caregiver/home/presentation/view/home_caretaker_screen.dart';
import '../Fetures/Auth/presentation/view/auth_wrapper.dart';
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
      routes: {
        '/add_medications' :(context) => AddMedicationScreen(),
        '/history' :(context) => HistoryScreen(currentUser:  UserModel(
  uid: 'OyMWoY97UBTR0tUUMNbTrpSseM2',
  email: 'heiarayashiki@gmail.com',
  name: 'Mohamed MX',
  phone: '',
  profileImage: null,
  role: UserRole.patient,
)
        ),
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
        MonthYearPickerLocalizations.delegate,
      ],

// AI mesh omar 
//omarsa
     /** home:  HistoryScreen(currentUser: UserModel(
  uid: '0yMWoY97UBTRT0tUUMNbTrpSseM2',
  email: 'heiarayashiki@gmail.com',
  name: 'Mohamed MX',
  phone: '',
  profileImage: null,
  role: UserRole.patient,
)), */
home: home_caretaker_screen(),
// mohamed medhat 
//      home:home_caretaker_screen(),
//dev two
//home: RootPage(),
//omarsa
//home: HistoryScreen()
    theme:  ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'NotoSansArabic',
      ),
    );
  }
}