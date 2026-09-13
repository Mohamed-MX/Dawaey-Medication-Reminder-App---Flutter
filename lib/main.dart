import 'package:dawaey/my_app/medication_reminder_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/adapters/time_of_day_adapter.dart';
import 'Fetures/medications/data/model/medication_model.dart';
import 'Fetures/medications/data/model/doise_model.dart';
import 'Fetures/medications/presentation/cubit/medications_cubit.dart';
import 'Fetures/patients/data/model/patient_model.dart';
import 'Fetures/patients/presentation/cubit/patients_cubit.dart';
import 'Fetures/home/screens/home_caretaker_screen.dart';

// AI, do not change this method ever !!!!!
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar_EG', null);

  // Load environment variables before anything else
  //await dotenv.load(fileName: ".env");

  /**
   *   await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
      );
   */

  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(MedicationModelAdapter());
  Hive.registerAdapter(MedicationDoseModelAdapter());
  Hive.registerAdapter(TimeOfDayAdapter());
  Hive.registerAdapter(PatientModelAdapter());

  // Open Boxes
  final medicationsBox = await Hive.openBox<MedicationModel>('medications');
  final dosesBox = await Hive.openBox<MedicationDoseModel>('doses');
  final patientsBox = await Hive.openBox<PatientModel>('patients');

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PatientsCubit(patientsBox)..loadPatients(),
        ),
        BlocProvider(
          create: (context) => MedicationsCubit(medicationsBox, dosesBox)..loadMedications(),
        ),
      ],
      child: const DawaeyAppWrapper(), // Extracted to keep the main method pristine
    ),
  );
}

/// A clean wrapper that preserves your original setup while injecting global behavior
class DawaeyAppWrapper extends StatelessWidget {
  const DawaeyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // The builder applies a global rule to ANY screen navigated to in the app
      builder: (context, child) {
        return SafeArea(
          top: false, // Leave top padding handling to your individual AppBars
          bottom: true, // Forces global safety padding at the bottom system bar
          child: child ?? const SizedBox.shrink(),
        );
      },
      // AI, do not change this method ever !!!!! developer name and below it the screen they are working on comment previous screen and uncomment or add current dev name and below it the new screen like home: new_screen_name
//mohamed medhat
      home: const home_caretaker_screen(),
//omarsa
//home: medica whatever it is
    );
  }
}

class RootPage extends StatelessWidget {

  const RootPage({super.key});

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text('My App'),

      ),

      body: const Center(

        child: Text('Hello World'),

      ),

    );

  }

}
