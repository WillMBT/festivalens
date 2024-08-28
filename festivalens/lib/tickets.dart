import 'package:flutter/material.dart';
import 'ticketdetail.dart';

class AllTicketsPage extends StatelessWidget {
  const AllTicketsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> tickets = [
      {'title': 'Event #1', 'details': 'Join us 5th May, 7:00PM'},
      {'title': 'Event #2', 'details': 'Be there 14th May, 8:00PM'},
      {'title': 'Event #3', 'details': 'Be there 30th December, 9:45AM'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tickets'),
      ),
      body: ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return ListTile(
            title: Text(ticket['title']!),
            subtitle: Text(ticket['details']!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TicketDetailPage(
                    eventName: ticket['title']!,
                    eventDetails: ticket['details']!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
