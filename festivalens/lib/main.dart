import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'event_details_page.dart';
import 'all_events_page.dart';
import 'secret.dart';
import 'tickets.dart';
import 'ticketdetail.dart';
import 'map.dart';

void main() {
  runApp(FestivaLensApp());
}

class FestivaLensApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FestivaLensHomePage(),
    );
  }
}

class FestivaLensHomePage extends StatefulWidget {
  @override
  _FestivaLensHomePageState createState() => _FestivaLensHomePageState();
}

class _FestivaLensHomePageState extends State<FestivaLensHomePage> {
  int _selectedIndex = 0;

  static List<Widget> get _pages => [
    FestivaLensHomePage(),
    AllEventsPage(),
    EventsMapPage(),
    AllTicketsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _pages[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FestivaLens'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UpcomingEventsSection(),
            const SizedBox(height: 16),
            YourTicketsSection(),
            const SizedBox(height: 16),
            YourEventSection(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Tickets',
          ),
        ],
      ),
    );
  }
}

class UpcomingEventsSection extends StatefulWidget {
  @override
  _UpcomingEventsSectionState createState() => _UpcomingEventsSectionState();
}

class _UpcomingEventsSectionState extends State<UpcomingEventsSection> {
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

  void _navigateToAllEventsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllEventsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () => _navigateToAllEventsPage(context),
              child: Text('See All'),
            ),
          ],
        ),
        SizedBox(height: 8),
        _events.isEmpty
            ? CircularProgressIndicator()
            : CarouselSlider(
                items: _events.map((event) {
                  return GestureDetector(
                    onTap: () => _navigateToEventDetailsPage(context, event),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          event['name'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 150,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
              ),
      ],
    );
  }
}

class YourTicketsSection extends StatelessWidget {
  void _navigateToTicketDetail(BuildContext context, String eventName, String eventDetails) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketDetailPage(
          eventName: eventName,
          eventDetails: eventDetails,
        ),
      ),
    );
  }

  void _navigateToAllTicketsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AllTicketsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Tickets',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToAllTicketsPage(context),
              child: const Text('See More'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _navigateToTicketDetail(context, 'Event #2', 'Be there 14th May, 8:00PM'),
          child: Container(
            height: 50,
            color: Colors.red,
            child: const Center(
              child: Text(
                'Event #2\nBe there 14th May, 8:00PM',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _navigateToTicketDetail(context, 'Event #3', 'Be there 30th December, 9:45AM'),
          child: Container(
            height: 50,
            color: Colors.orange,
            child: const Center(
              child: Text(
                'Event #3\nBe there 30th December, 9:45AM',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class YourEventSection extends StatelessWidget {
  void _navigateToSecret(BuildContext context, String eventName, String eventDetails) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecretPage(eventName: eventName, eventDetails: eventDetails),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Event',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () => _navigateToSecret(context, 'Event #1', 'Here is the information and upload photos here'),
          child: Container(
            height: 200,
            color: Colors.red,
            child: Center(
              child: Text(
                'Event #2 \nMore secretive info is held here...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
