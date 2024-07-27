import 'package:flutter/material.dart';

class SecretPage extends StatelessWidget {
  final String eventName;
  final String eventDetails;

  SecretPage({required this.eventName, required this.eventDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(eventName),
      ),
      body: Center(
        child: Text(eventDetails),
      ),
    );
  }
}