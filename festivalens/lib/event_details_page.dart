import 'package:flutter/material.dart';

class EventDetailsPage extends StatelessWidget {
  final dynamic event;

  EventDetailsPage({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        // Event name as screen title in AppBar
        title: Text(event['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // Title in main screen section
              event['name'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              // Displays date
              event['formattedStartDate'],
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 16),
            Text(
              // Any additional info about event
              event['info'] ?? 'No additional information available.',
              
              style: TextStyle(
                fontSize: 16,
              ),
            ),
             Text(
              // Links to more info and tickets
              event['url'] ?? 'No url available',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// End of Code