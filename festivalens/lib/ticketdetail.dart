import 'package:flutter/material.dart';

class TicketDetailPage extends StatelessWidget {
  final String eventName;
  final String eventDetails;

  const TicketDetailPage({
    Key? key,
    required this.eventName,
    required this.eventDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(eventName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eventName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              eventDetails,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Code to handle ticket purchase or additional actions
              },
              child: const Text('Purchase Ticket'),
            ),
          ],
        ),
      ),
    );
  }
}
