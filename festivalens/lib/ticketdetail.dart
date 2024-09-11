import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TicketDetailPage extends StatelessWidget {
  final String eventName;
  final String eventDetails;
  final String ticketmasterUrl;

  const TicketDetailPage({
    Key? key,
    required this.eventName,
    required this.eventDetails,
    required this.ticketmasterUrl,
  }) : super(key: key);

  Future<void> _launchUrl() async {
    if (!await launchUrl(Uri.parse(ticketmasterUrl))) {
      throw Exception('Could not launch $ticketmasterUrl');
    }
  }

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
              onPressed: _launchUrl,
              child: const Text('Purchase Ticket'),
            ),
          ],
        ),
      ),
    );
  }
}