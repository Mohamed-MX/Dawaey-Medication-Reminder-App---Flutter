import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'Fetures/home/screens/home_caretaker_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables before anything else
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Container(
          color: Colors.white,
          child: SafeArea(
            child: child!,
          ),
        );
      },
// mohamed medhat 
      home: const home_caretaker_screen(),

//dev two

//home: RootPage(),

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