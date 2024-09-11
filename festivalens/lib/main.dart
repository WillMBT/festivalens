import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:dio/dio.dart'; 
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
            icon: Icon(Icons.home, color: Colors.black),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event, color: Colors.black),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map, color: Colors.black),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number, color: Colors.black),
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
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  void _fetchEvents() async {
    try {
      final ticketmasterEvents = await _fetchTicketmasterEvents();
      final moshtixEvents = await _fetchMoshtixEvents();
      
      setState(() {
        _events = [...ticketmasterEvents, ...moshtixEvents];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load events: $e';
        _isLoading = false;
      });
    }
  }

  Future<List<dynamic>> _fetchTicketmasterEvents() async {
    try {
      final response = await http.get(
        Uri.parse('https://app.ticketmaster.com/discovery/v2/events.json?classificationName=music&countryCode=NZ&apikey=ytLHZaQDHtMK8EGePOX2GKjj6GiDYdu6'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['_embedded'] != null && jsonResponse['_embedded']['events'] != null) {
          return jsonResponse['_embedded']['events'].map((event) => {
            ...event,
            'source': 'ticketmaster',
          }).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load Ticketmaster events');
      }
    } catch (e) {
      print('Error fetching Ticketmaster events: $e');
      return [];
    }
  }

  Future<List<dynamic>> _fetchMoshtixEvents() async {
    final dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbnZpcm9ubWVudCI6InByb2R1Y3Rpb24iLCJ2aWV3ZXIiOnsiaWQiOjE3NjE1LCJ1c2VybmFtZSI6IjAzYWFhMmViLTFjNjItNDc1OS05MTczLWQwODk0MzJkOTQ0MCIsImZpcnN0TmFtZSI6IkV2ZW50RmluZGluZyIsImxhc3ROYW1lIjoiRXZlbnRGaW5kaW5nIiwicm9sZXMiOnsiaXRlbXMiOlt7Im5hbWUiOiJBZG1pbiIsImNsaWVudElkIjoyNDcwNCwiZGlzcGxheU5hbWUiOiJBZG1pbiJ9XSwidG90YWxDb3VudCI6MSwicGFnZUluZm8iOnsiaGFzUHJldmlvdXNQYWdlIjpmYWxzZSwiaGFzTmV4dFBhZ2UiOmZhbHNlLCJwYWdlSW5kZXgiOjAsInBhZ2VTaXplIjoxfX0sImZlYXR1cmVUb2dnbGVzIjp7Iml0ZW1zIjpbXSwidG90YWxDb3VudCI6MCwicGFnZUluZm8iOnsiaGFzUHJldmlvdXNQYWdlIjpmYWxzZSwiaGFzTmV4dFBhZ2UiOmZhbHNlLCJwYWdlSW5kZXgiOjAsInBhZ2VTaXplIjowfX0sImF1dGhlbnRpY2F0ZWRVc2luZ0FjY2Vzc1Rva2VuIjpmYWxzZSwiZW52aXJvbm1lbnQiOiJwcm9kdWN0aW9uIn0sInRva2VuSWQiOjI1OTI1NzcwLCJpYXQiOjE3MjU2MTM4NTAsImV4cCI6MjY3MTY5Mzg1MH0.q-P5v-L3dNpoDlWvzPWFqtWi72EbwEbQlwKzgmz19is';
    dio.options.headers['Content-Type'] = 'application/json';
try {
  print('Attempting to fetch Moshtix events...');
  final response = await dio.post(
    'https://api.moshtix.com/v1/graphql',
    data: {
      'query': '''
       query {
        viewer {
          getEvents {
            items {
              name
              startDate
              
            }
          }
        }
      }
      ''',
    },
  );

  print('Moshtix API Response Status: ${response.statusCode}');
  print('Moshtix API Response Headers: ${response.headers}');
  print('Moshtix API Response Body: ${response.data}');

  if (response.statusCode == 200) {
    final jsonResponse = response.data;
    if (jsonResponse['data'] != null &&
        jsonResponse['data']['viewer'] != null &&
        jsonResponse['data']['viewer']['getEvents'] != null &&
        jsonResponse['data']['viewer']['getEvents']['items'] != null) {
      return jsonResponse['data']['viewer']['getEvents']['items'].map((event) {
        DateTime startDate = DateTime.parse(event['startDate']);
          
          
          String formattedDate = DateFormat('EEEE, MMMM d, y').format(startDate);
          String formattedTime = DateFormat('h:mm a').format(startDate);
          
          return {
            ...event, 
            'source': 'moshtix', 
            'formattedStartDate': '$formattedDate at $formattedTime', 
          };
      }).toList();
    } else {
      
      print('Unexpected response structure from Moshtix API');
      print('Response data: ${jsonResponse}');
      return [];
    }
  } else {
    throw Exception(
        'Failed to load Moshtix events: ${response.statusCode} - ${response.statusMessage}');
  }
} catch (e) {
  print('Error fetching Moshtix events: $e');
  if (e is DioError) {
    print('DioError type: ${e.type}');
    print('DioError message: ${e.message}');
    print('DioError response: ${e.response}');
  }
  return [];
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
        if (_isLoading)
          CircularProgressIndicator()
        else if (_errorMessage.isNotEmpty)
          Text(_errorMessage, style: TextStyle(color: Colors.red))
        else if (_events.isEmpty)
          Text('No events found')
        else
          CarouselSlider(
            items: _events.map((event) {
              return GestureDetector(
                onTap: () => _navigateToEventDetailsPage(context, event),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: event['source'] == 'moshtix' ? Colors.blueAccent : Colors.redAccent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          event['name'] ?? 'Unnamed Event',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                        event['source'] == 'ticketmaster'
                        ? (event['dates']?['start']?['localDate'] ?? 'Date TBA')
                        : event['source'] == 'moshtix'
                        ? (event['formattedStartDate'] ?? event['startDate'] ?? 'Date TBA')
                        : 'Date TBA',
                        style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                          ),
                      ],
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

class YourTicketsSection extends StatefulWidget {
  @override
  _YourTicketsSectionState createState() => _YourTicketsSectionState();
}

class _YourTicketsSectionState extends State<YourTicketsSection> {
  List<dynamic> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  void _fetchEvents() async {
    final response = await http.get(
      Uri.parse('https://app.ticketmaster.com/discovery/v2/events.json?classificationName=music&countryCode=NZ&size=2&apikey=ytLHZaQDHtMK8EGePOX2GKjj6GiDYdu6'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _events = json.decode(response.body)['_embedded']['events'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load events');
    }
  }

  void _navigateToTicketDetail(BuildContext context, dynamic event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketDetailPage(
          eventName: event['name'],
          eventDetails: '${event['dates']['start']['localDate']} at ${event['dates']['start']['localTime']}',
          ticketmasterUrl: event['url'],
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
        _isLoading
            ? CircularProgressIndicator()
            : Column(
                children: _events.map((event) {
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () => _navigateToTicketDetail(context, event),
                        child: Container(
                          height: 50,
                          color: Colors.red,
                          child: Center(
                            child: Text(
                              '${event['name']}\n${event['dates']['start']['localDate']} at ${event['dates']['start']['localTime']}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                }).toList(),
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
