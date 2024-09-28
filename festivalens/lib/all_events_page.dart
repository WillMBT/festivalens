import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart'; 
import 'event_details_page.dart';
import 'package:intl/intl.dart';
import 'home.dart';
import 'profile.dart';
import 'upload.dart';
import 'map.dart';


class AllEventsPage extends StatefulWidget {
  @override
  _AllEventsPageState createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  // Defines lists for all events and filtered events
  // Defines error message
  // Defines the selected page
  List<dynamic> _events = [];
  List<dynamic> _filteredEvents = []; 
  bool _isLoading = true;
  String _errorMessage = '';
  int _selectedIndex = 0;
  DateTimeRange? _selectedDateRange;
  // updates thes state
  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }
// Defines pages
  static List<Widget> get _pages => [
    FestivaLensHomePage(),
    AllEventsPage(),
    EventsMapPage(),
    UploaderPage(),
    ProfilePage(),
  ];
// Fetch all events function (combination of other 3 functions)
   void _fetchEvents() async {
  try {
    final ticketmasterEvents = await _fetchTicketmasterEvents();
    final moshtixEvents = await _fetchMoshtixEvents();
    final eventfindaEvents = await _fetchEventfindaEvents(); 

     setState(() {
        _events = [...ticketmasterEvents, ...moshtixEvents, ...eventfindaEvents];
        _filteredEvents = _events; 
        _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _errorMessage = 'Failed to load events: $e';
      _isLoading = false;
    });
  }
}
// Ticketmaster event fetching function
  Future<List<dynamic>> _fetchTicketmasterEvents() async {
  try {
    final response = await http.get(
      // API Call
      Uri.parse('https://app.ticketmaster.com/discovery/v2/events.json?classificationName=music&countryCode=NZ&apikey=ytLHZaQDHtMK8EGePOX2GKjj6GiDYdu6'),
    );
    // If successful response, decode
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['_embedded'] != null && jsonResponse['_embedded']['events'] != null) {
        return jsonResponse['_embedded']['events'].map((event) {
          // Gets start date
          DateTime startDate = DateTime.parse(event['dates']['start']['dateTime']);
          // Formats the start date
          String formattedDate = DateFormat('EEEE, MMMM d, y').format(startDate);
          String formattedTime = DateFormat('h:mm a').format(startDate);
          
          return { // Returns to list, with ticketmaster as source and formatted date
            ...event,
            'source': 'ticketmaster',
            'formattedStartDate': '$formattedDate at $formattedTime',
          };
        }).toList(); // Adds to list
      } else {
        return [];
      }
    } else { // Error message
      throw Exception('Failed to load Ticketmaster events');
    }
  } catch (e) { // Error Message
    print('Error fetching Ticketmaster events: $e');
    return [];
  }
}
// Function to fetch Moshtix Events 
  Future<List<dynamic>> _fetchMoshtixEvents() async {
    final dio = Dio();
    // API Key
    dio.options.headers['Authorization'] = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbnZpcm9ubWVudCI6InByb2R1Y3Rpb24iLCJ2aWV3ZXIiOnsiaWQiOjE3NjE1LCJ1c2VybmFtZSI6IjAzYWFhMmViLTFjNjItNDc1OS05MTczLWQwODk0MzJkOTQ0MCIsImZpcnN0TmFtZSI6IkV2ZW50RmluZGluZyIsImxhc3ROYW1lIjoiRXZlbnRGaW5kaW5nIiwicm9sZXMiOnsiaXRlbXMiOlt7Im5hbWUiOiJBZG1pbiIsImNsaWVudElkIjoyNDcwNCwiZGlzcGxheU5hbWUiOiJBZG1pbiJ9XSwidG90YWxDb3VudCI6MSwicGFnZUluZm8iOnsiaGFzUHJldmlvdXNQYWdlIjpmYWxzZSwiaGFzTmV4dFBhZ2UiOmZhbHNlLCJwYWdlSW5kZXgiOjAsInBhZ2VTaXplIjoxfX0sImZlYXR1cmVUb2dnbGVzIjp7Iml0ZW1zIjpbXSwidG90YWxDb3VudCI6MCwicGFnZUluZm8iOnsiaGFzUHJldmlvdXNQYWdlIjpmYWxzZSwiaGFzTmV4dFBhZ2UiOmZhbHNlLCJwYWdlSW5kZXgiOjAsInBhZ2VTaXplIjowfX0sImF1dGhlbnRpY2F0ZWRVc2luZ0FjY2Vzc1Rva2VuIjpmYWxzZSwiZW52aXJvbm1lbnQiOiJwcm9kdWN0aW9uIn0sInRva2VuSWQiOjI1OTI1NzcwLCJpYXQiOjE3MjU2MTM4NTAsImV4cCI6MjY3MTY5Mzg1MH0.q-P5v-L3dNpoDlWvzPWFqtWi72EbwEbQlwKzgmz19is';
    dio.options.headers['Content-Type'] = 'application/json';
try {
  // Prints in console to show status
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
// Prints response in console (debugging)
  print('Moshtix API Response Status: ${response.statusCode}');
  print('Moshtix API Response Headers: ${response.headers}');
  print('Moshtix API Response Body: ${response.data}');
  // If successful response, find events
  if (response.statusCode == 200) {
    final jsonResponse = response.data;
    if (jsonResponse['data'] != null &&
        jsonResponse['data']['viewer'] != null &&
        jsonResponse['data']['viewer']['getEvents'] != null &&
        jsonResponse['data']['viewer']['getEvents']['items'] != null) {
      return jsonResponse['data']['viewer']['getEvents']['items'].map((event) {
        // Get start date
        DateTime startDate = DateTime.parse(event['startDate']);
          
          // Format date
          String formattedDate = DateFormat('EEEE, MMMM d, y').format(startDate);
          String formattedTime = DateFormat('h:mm a').format(startDate);
          
          return { // Adds to list as moshtix source with formatted date
            ...event, 
            'source': 'moshtix', 
            'formattedStartDate': '$formattedDate at $formattedTime', 
          };
      }).toList(); // Adds to list
    } else {
      // Error Message to do with response
      print('Unexpected response structure from Moshtix API');
      print('Response data: ${jsonResponse}');
      return [];
    }
  } else { // Error Message to do with fetching
    throw Exception(
        'Failed to load Moshtix events: ${response.statusCode} - ${response.statusMessage}');
  }
} catch (e) { // Error Message to do with fetching
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
  
  // Username and Password
  final String credentials = 'festivalens:xg222ykmxwkj';
  
  // Uses Username and Password
  final String encodedCredentials = base64Encode(utf8.encode(credentials));
  
  dio.options.headers['Authorization'] = 'Basic $encodedCredentials';
  
  try {
    // Print for debugging
    print('Attempting to fetch Eventfinda events...');
    final response = await dio.get(
      // API Call
      'https://api.eventfinda.co.nz/v2/events.json',
      queryParameters: {
        'rows': 10, // how many events
      },
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    
    print('Eventfinda API Response Status: ${response.statusCode}');
    print('Eventfinda API Response Body: ${response.data}');
// If successful response, get event details
    if (response.statusCode == 200) {
      final jsonResponse = response.data;
      if (jsonResponse['events'] != null) {
        return jsonResponse['events'].map((event) {
          // Get date
          DateTime startDate = DateTime.parse(event['datetime_start']);
          // Format date
          String formattedDate = DateFormat('EEEE, MMMM d, y').format(startDate);
          String formattedTime = DateFormat('h:mm a').format(startDate);
          
          return { // Adds to list as eventfinda source with formatted date
            ...event,
            'source': 'eventfinda',
            'formattedStartDate': '$formattedDate at $formattedTime',
          };
        }).toList(); // Adds to list
      } else {
        return [];
      }
    } else {
      throw DioException( // Error message to do with response
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Failed to load Eventfinda events: ${response.statusCode}',
      );
    }
  } catch (e) { // Error Message
    print('Error fetching Eventfinda events: $e');
    if (e is DioException) {
      print('DioException type: ${e.type}');
      print('DioException message: ${e.message}');
      print('DioException response: ${e.response}');
    }
    return [];
  }
}
// Navigate to event details page when event clicked
  void _navigateToEventDetailsPage(BuildContext context, dynamic event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsPage(event: event),
      ),
    );
  }

// Navigate for navbar
void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _pages[index]),
    );
  }
// Filters events by date picked
    void _eventFilter() {
    if (_selectedDateRange != null) {
      setState(() {
        _filteredEvents = _events.where((event) {
          DateTime eventDate;
          if (event['source'] == 'ticketmaster') {
            eventDate = DateTime.parse(event['dates']['start']['localDate']);
          } else if (event['source'] == 'moshtix') {
            eventDate = DateTime.parse(event['startDate']);
          } else {
            eventDate = DateTime.parse(event['datetime_start']);
          }
         return eventDate.isAtSameMomentAs(_selectedDateRange!.start) ||
               eventDate.isAtSameMomentAs(_selectedDateRange!.end) ||
               (eventDate.isAfter(_selectedDateRange!.start) &&
                eventDate.isBefore(_selectedDateRange!.end.add(Duration(days: 1))));
        }).toList();
      });
    }
  }
// Picks dates for event filtering
  Future<void> _pickDates() async {
    DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2027),
    );

    if (pickedRange != null) {
      setState(() {
        _selectedDateRange = pickedRange;
      });
      _eventFilter();
    }
  }


// Builds the page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        iconTheme: IconThemeData(
    color: Theme.of(context).colorScheme.onSurface, 
  ),
        
        title: Text('All Upcoming Events',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface 
        ),),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Theme.of(context).colorScheme.onSurface),
            onPressed: _pickDates, // Calls function
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _filteredEvents.isEmpty
          // Error message or no events in selected dates
              ? Center(child: Text('No events found for selected dates')) 
              : ListView.builder(
                  itemCount: _filteredEvents.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        _filteredEvents[index]['name'], // shows name of events
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      ),
                      subtitle: Text(
                        // shows dates of events
                        _filteredEvents[index]['source'] == 'ticketmaster'
                            ? _filteredEvents[index]['formattedStartDate'] ?? 'No date'
                            : _filteredEvents[index]['source'] == 'moshtix'
                                ? _filteredEvents[index]['formattedStartDate'] ?? 'No date'
                                : _filteredEvents[index]['source'] == 'eventfinda'
                                    ? _filteredEvents[index]['formattedStartDate'] ?? 'No date'
                                    : 'No Date'
),
                  // Calls function to navigate to eventdetails
                  onTap: () => _navigateToEventDetailsPage(context, _events[index]),
                  
                );
              },
            ),
    
    // Navbar
    bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem( // Home
            icon: Icon(Icons.home, color: Theme.of(context).colorScheme.onSurface),
            label: 'Home',
            
          ),
          BottomNavigationBarItem( // All Events (selected)
            icon: Icon(Icons.event, color: Theme.of(context).colorScheme.secondary),
            label: 'Events',
          ),
          BottomNavigationBarItem( // Map
            icon: Icon(Icons.map, color: Theme.of(context).colorScheme.onSurface),
            label: 'Map',
          ),
          
          BottomNavigationBarItem( // Upload Page
            icon: Icon(Icons.file_upload_outlined, color: Theme.of(context).colorScheme.onSurface),
            label: 'Upload',
          ),
          
          BottomNavigationBarItem( // Profile Page
            icon: Icon(Icons.person, color: Theme.of(context).colorScheme.onSurface),  
            label: 'Profile',
          ),
          
        ],
      ),
   
   
   
    );
  }
}
// End of code