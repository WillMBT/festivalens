import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TicketsPage extends StatefulWidget {
  final String eventName;
  final String eventDetails;

  TicketsPage({required this.eventName, required this.eventDetails});

  @override
  _TicketsPageState createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  List<dynamic> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEventData();
  }

  Future<void> _fetchEventData() async {
    final apiKey = 'ytLHZaQDHtMK8EGePOX2GKjj6GiDYdu6'; // Replace with your Ticketmaster API key
    final url = Uri.parse('https://app.ticketmaster.com/discovery/v2/events.json?apikey=$apiKey&keyword=${widget.eventName}');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _events = data['_embedded']['events'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventName),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return ListTile(
                  title: Text(event['name']),
                  subtitle: Text(event['dates']['start']['localDate']),
                  onTap: () {
                    _showEventDetails(event);
                  },
                );
              },
            ),
    );
  }

  void _showEventDetails(dynamic event) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event['name']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Date: ${event['dates']['start']['localDate']}'),
              if (event['priceRanges'] != null)
                Text('Price: \$${event['priceRanges'][0]['min']} - \$${event['priceRanges'][0]['max']}'),
              Text('Venue: ${event['_embedded']['venues'][0]['name']}'),
              if (event['info'] != null) Text('Info: ${event['info']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
