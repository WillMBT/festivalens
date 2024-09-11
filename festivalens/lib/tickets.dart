import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ticketdetail.dart';

class AllTicketsPage extends StatefulWidget {
  const AllTicketsPage({Key? key}) : super(key: key);

  @override
  _AllTicketsPageState createState() => _AllTicketsPageState();
}

class _AllTicketsPageState extends State<AllTicketsPage> {
  List<Map<String, String>> tickets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    final apiKey = 'ytLHZaQDHtMK8EGePOX2GKjj6GiDYdu6'; // Replace with your actual Ticketmaster API key
    final url = 'https://app.ticketmaster.com/discovery/v2/events.json?apikey=$apiKey&countryCode=NZ';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final events = data['_embedded']['events'];

        setState(() {
          tickets = events.map<Map<String, String>>((event) {
            final date = event['dates']['start']['localDate'];
            final time = event['dates']['start']['localTime'];
            return {
              'title': event['name'],
              'details': 'Join us $date, $time',
              'url': event['url'],
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load tickets');
      }
    } catch (e) {
      print('Error fetching tickets: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Tickets'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
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
                          ticketmasterUrl: ticket['url']!,
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