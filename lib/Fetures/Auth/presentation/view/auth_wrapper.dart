import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dawaey/Fetures/Auth/presentation/view/login_screen.dart';
import 'package:dawaey/Fetures/caregiver/home/presentation/view/home_caretaker_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in
          return home_caretaker_screen();
        }
        
        // User is NOT logged in
        return const LoginScreen();
      },
    );
  }
}
