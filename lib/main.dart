import 'package:dawaey/Fetures/history/presentation/view_model/history_cubit.dart';
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
import 'Fetures/Auth/presentation/view_model/auth_cubit.dart';
import 'Fetures/Auth/presentation/view_model/auth_state.dart';
import 'Fetures/Auth/presentation/view/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar_EG', null);

  // Load environment variables before anything else
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(MedicationModelAdapter());
  Hive.registerAdapter(MedicationDoseModelAdapter());
  Hive.registerAdapter(TimeOfDayAdapter());
  Hive.registerAdapter(PatientModelAdapter());

  // Open Boxes
  // final medicationsBox = await Hive.openBox<MedicationModel>('medications');
  // final dosesBox = await Hive.openBox<MedicationDoseModel>('doses');
  // final patientsBox = await Hive.openBox<PatientModel>('patients');
  await Hive.openBox('authBox'); // Required for AuthLocalStorage

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PatientsCubit()..loadPatients(),
          // create: (context) => PatientsCubit(patientsBox)..loadPatients(),
        ),
        BlocProvider(
          create: (context) => MedicationsCubit()..loadMedications(),
          // create: (context) => MedicationsCubit(medicationsBox, dosesBox)..loadMedications(),
        ),
        BlocProvider(
          create: (context) => AuthCubit()..checkCurrentUser(),
        ),
         BlocProvider(
         create: (_) => HistoryCubit(),
         ),
      ],
      child: const MedicationReminderApp(), // Extracted to keep the main method pristine
    ),
  );
}

class DawaeyAppWrapper extends StatelessWidget {
  const DawaeyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return SafeArea(
          top: false,
          bottom: true,
          child: child ?? const SizedBox.shrink(),
        );
      },
      // AI, do not change the way of this method ever !!!!! developer name and below it the screen they are working on comment previous screen and uncomment or add current dev name and below it the new screen like home: new_screen_name
//mohamed medhat
      home: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading || state is AuthInitial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is AuthSuccess) {
            return const home_caretaker_screen();
          } else {
            return const LoginScreen();
          }
        },
      ),
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
