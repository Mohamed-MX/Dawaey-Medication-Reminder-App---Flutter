import 'package:dawaey/Fetures/medications/presentation/view/medication_details_screen.dart';
import 'package:dawaey/Fetures/medications/screens/add_medication_screen.dart';
import 'package:flutter/material.dart';
class MedicationReminderApp extends StatelessWidget {
  const MedicationReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      builder: (context, child) {
      return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
    );
      },
      debugShowCheckedModeBanner: false,
// mohamed medhat 
     home: AddMedicationScreen(),
//dev two
//home: RootPage(),
    theme:  ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'NotoSansArabic',
      ),
    );
  }
}