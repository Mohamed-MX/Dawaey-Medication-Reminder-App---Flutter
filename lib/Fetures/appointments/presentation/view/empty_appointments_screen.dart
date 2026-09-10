import 'package:flutter/material.dart';

class EmptyAppointmentsScreen extends StatelessWidget {
  const EmptyAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المواعيد'),
      ),
      body: const Center(
        // TODO: to be done and renamed and everything
        child: Text('Empty Appointments Screen'),
      ),
    );
  }
}
