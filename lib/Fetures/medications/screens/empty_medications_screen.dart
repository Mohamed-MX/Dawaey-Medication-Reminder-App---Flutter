import 'package:flutter/material.dart';

class EmptyMedicationsScreen extends StatelessWidget {
  const EmptyMedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأدوية'),
      ),
      body: const Center(
        // TODO: to be done and renamed and everything
        child: Text('Empty Medications Screen'),
      ),
    );
  }
}
