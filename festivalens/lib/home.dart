import 'package:festvialens/profile.dart';
import 'package:festvialens/upload.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:dio/dio.dart'; 
import 'event_details_page.dart';
import 'all_events_page.dart';
import 'map.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Creates widget for whole page
class FestivaLensHomePage extends StatefulWidget {
  @override
  _FestivaLensHomePageState createState() => _FestivaLensHomePageState();
}

class _FestivaLensHomePageState extends State<FestivaLensHomePage> {
  int _selectedIndex = 0;

// Defines list of pages
  static List<Widget> get _pages => [
    FestivaLensHomePage(),
    AllEventsPage(),
    EventsMapPage(),
    UploaderPage(),
    ProfilePage(),
  ];
// Function to navigate to Map page
    void _navigateToMapPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventsMapPage()),
    );
  }
// Gives definition for whenever an item is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _pages[index]),
    );
  }


// Building of the app
// This section builds the layout of the app
// As well as adding the Navbar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('FestivaLens', 
        
        textAlign: TextAlign.center),

        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: () {
              ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
              if (themeNotifier.themeMode == ThemeMode.light) {
                themeNotifier.setTheme(ThemeMode.dark);
              } else {
                themeNotifier.setTheme(ThemeMode.light);
              }
            },
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.surface,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UpcomingEventsSection(),
            const SizedBox(height: 16),
            MapSection( onTap: () {
          // Navigate to the map page when tapped
          _navigateToMapPage(context);
        },),
            const SizedBox(height: 16),
            YourEventSection(),
          ],
        ),
      ),
      
      
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Theme.of(context).colorScheme.secondary),
            label: 'Home',
            
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event, color: Theme.of(context).colorScheme.onSurface),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on, color: Theme.of(context).colorScheme.onSurface),
            label: 'Map',
          ),
          
          BottomNavigationBarItem(
            icon: Icon(Icons.file_upload_outlined, color: Theme.of(context).colorScheme.onSurface),
            label: 'Upload',
          ),
          
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Theme.of(context).colorScheme.onSurface),
            label: 'Profile',
          ),
          
        ],
      ),
    );
  }
}


// Class for Upcoming Events section
class UpcomingEventsSection extends StatefulWidget {
  @override
  _UpcomingEventsSectionState createState() => _UpcomingEventsSectionState();
}

class _UpcomingEventsSectionState extends State<UpcomingEventsSection> {
 // Defines list of events, the loading state & error message
  List<dynamic> _events = [];
  bool _isLoading = true;
  String _errorMessage = '';

// Updates the state of the app
// and runs the event fetching function
  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }
// Event fetching function
 void _fetchEvents() async {
  try {
    // Fetch Ticketmaster events
    final ticketmasterEvents = await _fetchTicketmasterEvents();
    // Fetch Moshtix Events
    final moshtixEvents = await _fetchMoshtixEvents(); 
    // Fetch Eventfinda events
    final eventfindaEvents = await _fetchEventfindaEvents(); 

    setState(() {
      _events = [...ticketmasterEvents, ...moshtixEvents, ...eventfindaEvents]; // Combine all events
      _isLoading = false;
    });
  } catch (e) { // Error catching
    setState(() {
      _errorMessage = 'Failed to load events: $e'; // Error code
      _isLoading = false; // Updates loading state
    });
  }
}
 // Function to navigate to Event Details page
  void _navigateToEventDetailsPage(BuildContext context, dynamic event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsPage(event: event),
      ),
    );
  }
// Function to navigate to All Events Page
  void _navigateToAllEventsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllEventsPage(),
      ),
    );
  }
 // Function to fetch Ticketmaster events
  Future<List<dynamic>> _fetchTicketmasterEvents() async {
    try {
      // http API call
      final response = await http.get(
        Uri.parse('https://app.ticketmaster.com/discovery/v2/events.json?classificationName=music&countryCode=NZ&apikey=ytLHZaQDHtMK8EGePOX2GKjj6GiDYdu6'),
      );
      // If rsponse received, decode into events
      if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['_embedded'] != null && jsonResponse['_embedded']['events'] != null) {
        return jsonResponse['_embedded']['events'].map((event) {
          // Fetchs Start Dates
          DateTime startDate = DateTime.parse(event['dates']['start']['dateTime']);
          // Formats start date to match others
          String formattedDate = DateFormat('EEEE, MMMM d, y').format(startDate);
          String formattedTime = DateFormat('h:mm a').format(startDate);
          
          return { // adds to list as ticketmaster source, with formatted date
            ...event,
            'source': 'ticketmaster', 
            'formattedStartDate': '$formattedDate at $formattedTime',
          };
        }).toList(); // add to list
      } else {
        return [];
      }
    } else {
      // Error Code
      throw Exception('Failed to load Ticketmaster events');
    }
  } catch (e) {
    // Error code cont.
    print('Error fetching Ticketmaster events: $e');
    return [];
  }
}
// Function to fetch Moshtix events
  Future<List<dynamic>> _fetchMoshtixEvents() async {
    final dio = Dio();
    // API Key
    dio.options.headers['Authorization'] = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbnZpcm9ubWVudCI6InByb2R1Y3Rpb24iLCJ2aWV3ZXIiOnsiaWQiOjE3NjE1LCJ1c2VybmFtZSI6IjAzYWFhMmViLTFjNjItNDc1OS05MTczLWQwODk0MzJkOTQ0MCIsImZpcnN0TmFtZSI6IkV2ZW50RmluZGluZyIsImxhc3ROYW1lIjoiRXZlbnRGaW5kaW5nIiwicm9sZXMiOnsiaXRlbXMiOlt7Im5hbWUiOiJBZG1pbiIsImNsaWVudElkIjoyNDcwNCwiZGlzcGxheU5hbWUiOiJBZG1pbiJ9XSwidG90YWxDb3VudCI6MSwicGFnZUluZm8iOnsiaGFzUHJldmlvdXNQYWdlIjpmYWxzZSwiaGFzTmV4dFBhZ2UiOmZhbHNlLCJwYWdlSW5kZXgiOjAsInBhZ2VTaXplIjoxfX0sImZlYXR1cmVUb2dnbGVzIjp7Iml0ZW1zIjpbXSwidG90YWxDb3VudCI6MCwicGFnZUluZm8iOnsiaGFzUHJldmlvdXNQYWdlIjpmYWxzZSwiaGFzTmV4dFBhZ2UiOmZhbHNlLCJwYWdlSW5kZXgiOjAsInBhZ2VTaXplIjowfX0sImF1dGhlbnRpY2F0ZWRVc2luZ0FjY2Vzc1Rva2VuIjpmYWxzZSwiZW52aXJvbm1lbnQiOiJwcm9kdWN0aW9uIn0sInRva2VuSWQiOjI1OTI1NzcwLCJpYXQiOjE3MjU2MTM4NTAsImV4cCI6MjY3MTY5Mzg1MH0.q-P5v-L3dNpoDlWvzPWFqtWi72EbwEbQlwKzgmz19is';
    // Defines content typ
    dio.options.headers['Content-Type'] = 'application/json';
try {
  // Prints message in console to help with error checking
  print('Attempting to fetch Moshtix events...');
  // API call
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
 // Prints response in debug console to help debug 
 // (Very helpful during development)
  print('Moshtix API Response Status: ${response.statusCode}');
  print('Moshtix API Response Headers: ${response.headers}');
  print('Moshtix API Response Body: ${response.data}');

  if (response.statusCode == 200) {
    // If response received, decode the events
    final jsonResponse = response.data;
    if (jsonResponse['data'] != null &&
        jsonResponse['data']['viewer'] != null &&
        jsonResponse['data']['viewer']['getEvents'] != null &&
        jsonResponse['data']['viewer']['getEvents']['items'] != null) {
      return jsonResponse['data']['viewer']['getEvents']['items'].map((event) {
        // Fetchs start date
        DateTime startDate = DateTime.parse(event['startDate']);
          
          // Formats start date to match others
          String formattedDate = DateFormat('EEEE, MMMM d, y').format(startDate);
          String formattedTime = DateFormat('h:mm a').format(startDate);
          
          return { // Adds to list with moshtix as source and formatted date
            ...event, 
            'source': 'moshtix', 
            'formattedStartDate': '$formattedDate at $formattedTime', 
          };
      }).toList(); // adds to list
    } else {
      // Error message (different info gathered)
      // (common problem during development)
      print('Unexpected response structure from Moshtix API');
      print('Response data: ${jsonResponse}');
      return [];
    }
  } else {
    throw Exception(
      // Error code 
        'Failed to load Moshtix events: ${response.statusCode} - ${response.statusMessage}');
  }
} catch (e) {
  // Error code cont. 
  print('Error fetching Moshtix events: $e');
  if (e is DioError) {
    print('DioError type: ${e.type}');
    print('DioError message: ${e.message}');
    print('DioError response: ${e.response}');
  }
  return [];
}
  }

// Function to find eventfinda events
Future<List<dynamic>> _fetchEventfindaEvents() async {
  final dio = Dio();
  
// Username and password
  const String credentials = 'festivalens:xg222ykmxwkj';
  
// Inputs username and password into input
  final String encodedCredentials = base64Encode(utf8.encode(credentials));
// Uses input as credentials
  dio.options.headers['Authorization'] = 'Basic $encodedCredentials';

  try {
    print('Attempting to fetch Eventfinda events...');
    // http call for eventfinda
    final response = await dio.get(
      'https://api.eventfinda.co.nz/v2/events.json',
      queryParameters: { // how many events
        'rows': 10, 
      },
      options: Options( 
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    // Prints response for debugging
    print('Eventfinda API Response Status: ${response.statusCode}');
    print('Eventfinda API Response Body: ${response.data}');
    // If response is successful, get events
    if (response.statusCode == 200) {
      final jsonResponse = response.data;
      if (jsonResponse['events'] != null) {
        return jsonResponse['events'].map((event) {
          // Get Start date
          DateTime startDate = DateTime.parse(event['datetime_start']);
          // Format start date to match rest of sources
          String formattedDate = DateFormat('EEEE, MMMM d, y').format(startDate);
          String formattedTime = DateFormat('h:mm a').format(startDate);
          
          return { // Add to list as eventfinda sources, with Formatted date
            ...event,
            'source': 'eventfinda',
            'formattedStartDate': '$formattedDate at $formattedTime',
          };
        }).toList(); // adds to list
      } else {
        return [];
      }
    } else {
      // Error handling
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        // Erorr message
        error: 'Failed to load Eventfinda events: ${response.statusCode}', 
      );
    }
  } catch (e) {
    // Error message cont. 
    print('Error fetching Eventfinda events: $e');
    if (e is DioException) {
      print('DioException type: ${e.type}');
      print('DioException message: ${e.message}');
      print('DioException response: ${e.response}');
    }
    return [];
  }
}

// Building the 'Upcoming Events Section'
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
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextButton( // Button shows all events page
              onPressed: () => _navigateToAllEventsPage(context),
              child: Text('See All',
              style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,)),
            ),
          ],
        ),
        SizedBox(height: 8),
        if (_isLoading)
          CircularProgressIndicator() // Loading circle
        else if (_errorMessage.isNotEmpty)
          Text(_errorMessage, style: TextStyle(color: Colors.red))
        else if (_events.isEmpty)
          Text('No events found') // Error Message
        else
          CarouselSlider(
            items: _events.map((event) {
    return GestureDetector(
      onTap: () => _navigateToEventDetailsPage(context, event),
      child: Container(
        width: MediaQuery.of(context).size.width, // Responsive
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          // Sets color based off event source
          color: event['source'] == 'eventfinda' ?  
          Theme.of(context).colorScheme.tertiary: 
          (event['source'] == 'moshtix' ? 
          Theme.of(context).colorScheme.secondary: 
          Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                // Takes name from API call
                event['name'] ?? 'Unnamed Event', 
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.surface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                // Takes date from API call
                event['formattedStartDate'] ?? 'Date TBA', 
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.surface,
                ),
                textAlign: TextAlign.center,
                          ),
                      ],
                    ),
          ),
                  ),
                ),
              );
            }).toList(),
            options: CarouselOptions(
              height: 150,
              autoPlay: true,
              // Enlarges middle container
              enlargeCenterPage: true,
            ),
          ),
      ],
    );
  }
}



// Building of the map section
class MapSection extends StatelessWidget {
  final VoidCallback onTap;

  const MapSection({Key? key, required this.onTap}) : super(key: key);
// Function to navigate to map page
  void _navigateToMapPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventsMapPage()),
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
              'Map',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () => _navigateToMapPage(context), // Function called
              child: Text('See More', // Opens map page
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,)),
            ),
          ],
        ),
      GestureDetector( // Opens map page
        onTap: () => _navigateToMapPage(context),
        child: Container(
          height: 150,
          width: double.infinity,
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow( // Drop shadow
                color: Colors.grey.withOpacity(0.5), 
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(-41.2865, 174.7762), // Wellington, NZ
                    initialZoom: 5.0,
                  ),
                  children: [
                    TileLayer(
                      // Imports map
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                     // Builds map markers
                      markers: [
                        Marker(
                          width: 40.0,
                          height: 40.0,
                          point: LatLng(-41.2865, 174.7762),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

}

// Building of Upload Page blurb

class YourEventSection extends StatelessWidget {
  // Function to navigate to upload page
  void _navigateToSecret(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploaderPage(),
      ),
    );
  }
  // Building
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
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        GestureDetector(
          onTap: () => _navigateToSecret(context), // Function called
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), 
              color: Theme.of(context).colorScheme.primary,),
            height: 200,
            
            child: Center(
              // Blurb
              child: Text(
                'Share your memories here! We offer photo uploads, so you can share your time at your favourite events, as well as seeing how everyone else enjoyed it too. Click here to upload now. Note: Only available for Ticketmaster events',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// End of Code