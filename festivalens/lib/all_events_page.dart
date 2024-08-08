import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'event_details_page.dart';

class AllEventsPage extends StatefulWidget {
  @override
  _AllEventsPageState createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  List<dynamic> _events = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  void _fetchEvents() async {
    final response = await http.get(
      Uri.parse('https://app.ticketmaster.com/discovery/v2/events.json?classificationName=music&countryCode=NZ&apikey=ytLHZaQDHtMK8EGePOX2GKjj6GiDYdu6'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _events = json.decode(response.body)['_embedded']['events'];
      });
    } else {
      throw Exception('Failed to load events');
    }
  }

  void _navigateToEventDetailsPage(BuildContext context, dynamic event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsPage(event: event),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Upcoming Events'),
      ),
      body: _events.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_events[index]['name']),
                  subtitle: Text(_events[index]['dates']['start']['localDate']),
                  onTap: () => _navigateToEventDetailsPage(context, _events[index]),
                );
              },
            ),
    );
  }
}
