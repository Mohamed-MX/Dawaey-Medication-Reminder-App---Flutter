import 'package:flutter/material.dart';

class EmptyNotificationsScreen extends StatelessWidget {
  const EmptyNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التنبيهات'),
      ),
      body: const Center(
        // TODO: to be done and renamed and everything
        child: Text('Empty Notifications Screen'),
      ),
    );
  }
}
