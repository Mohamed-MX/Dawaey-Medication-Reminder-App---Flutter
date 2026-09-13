import 'package:dawaey/my_app/medication_reminder_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/adapters/time_of_day_adapter.dart';
import 'Fetures/medications/data/model/medication_model.dart';
import 'Fetures/medications/data/model/doise_model.dart';
import 'Fetures/medications/presentation/cubit/medications_cubit.dart';
import 'Fetures/home/screens/home_caretaker_screen.dart';

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

  // Open Boxes
  final medicationsBox = await Hive.openBox<MedicationModel>('medications');
  final dosesBox = await Hive.openBox<MedicationDoseModel>('doses');

  runApp(
    BlocProvider(
      create: (context) => MedicationsCubit(medicationsBox, dosesBox)..loadMedications(),
      child: MedicationReminderApp(),
    ),
  );
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
