import 'package:dawaey/Fetures/Auth/data/local/auth_local_storage.dart';
import 'package:dawaey/Fetures/Auth/presentation/view_model/auth_cubit.dart';

import 'package:dawaey/Fetures/medications/data/model/doise_model.dart';
import 'package:dawaey/Fetures/medications/data/model/medication_model.dart';
import 'package:dawaey/Fetures/medications/presentation/cubit/medications_cubit.dart';

import 'package:dawaey/Fetures/patients/data/model/patient_model.dart';
import 'package:dawaey/Fetures/patients/presentation/cubit/patients_cubit.dart';

import 'package:dawaey/core/adapters/time_of_day_adapter.dart';
import 'package:dawaey/my_app/medication_reminder_app.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting(
    'ar_EG',
    null,
  );

  await Firebase.initializeApp();

  await Hive.initFlutter();

  await AuthLocalStorage.init();

  Hive.registerAdapter(
    MedicationModelAdapter(),
  );

  Hive.registerAdapter(
    MedicationDoseModelAdapter(),
  );

  Hive.registerAdapter(
    TimeOfDayAdapter(),
  );

  Hive.registerAdapter(
    PatientModelAdapter(),
  );

  await Hive.openBox<MedicationModel>(
    'medications',
  );

  await Hive.openBox<MedicationDoseModel>(
    'doses',
  );

  await Hive.openBox<PatientModel>(
    'patients',
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            return PatientsCubit();
          },
        ),

        BlocProvider(
          create: (context) {
            return MedicationsCubit();
          },
        ),

        BlocProvider(
          create: (context) {
            return AuthCubit();
          },
        ),
      ],

      child: const MedicationReminderApp(),
    ),
  );
}