import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart'; 
import 'event_details_page.dart';
import 'package:intl/intl.dart';
import 'homepg.dart';
import 'profile.dart';
import 'upload.dart';
import 'map.dart';


class AllEventsPage extends StatefulWidget {
  @override
  _AllEventsPageState createState() => _AllEventsPageState();
}

class _AllEventsPageState extends State<AllEventsPage> {
  List<dynamic> _events = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  static List<Widget> get _pages => [
    FestivaLensHomePage(),
    AllEventsPage(),
    EventsMapPage(),
    UploaderPage(),
    ProfilePage(),
  ];

   void _fetchEvents() async {
  try {
    final ticketmasterEvents = await _fetchTicketmasterEvents();
    final moshtixEvents = await _fetchMoshtixEvents();
    final eventfindaEvents = await _fetchEventfindaEvents(); // Fetch Eventfinda events

    setState(() {
      _events = [...ticketmasterEvents, ...moshtixEvents, ...eventfindaEvents]; // Combine all events
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

Future<List<dynamic>> _fetchEventfindaEvents() async {
  final dio = Dio();
  
  // Eventfinda API credentials (username:password)
  final String credentials = 'festivalens:xg222ykmxwkj';
  
  // Encode credentials to Base64 for Basic Auth
  final String encodedCredentials = base64Encode(utf8.encode(credentials));
  
  dio.options.headers['Authorization'] = 'Basic $encodedCredentials';
  
  try {
    print('Attempting to fetch Eventfinda events...');
    final response = await dio.get(
      'https://api.eventfinda.co.nz/v2/events.json',
      queryParameters: {
        'rows': 10, // Specify how many events you want to retrieve
      },
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    
    print('Eventfinda API Response Status: ${response.statusCode}');
    print('Eventfinda API Response Body: ${response.data}');

    if (response.statusCode == 200) {
      final jsonResponse = response.data;
      if (jsonResponse['events'] != null) {
        return jsonResponse['events'].map((event) {
          DateTime startDate = DateTime.parse(event['datetime_start']);
          String formattedDate = DateFormat('EEEE, MMMM d, y').format(startDate);
          String formattedTime = DateFormat('h:mm a').format(startDate);
          
          return {
            ...event,
            'source': 'eventfinda',
            'formattedStartDate': '$formattedDate at $formattedTime',
          };
        }).toList();
      } else {
        return [];
      }
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Failed to load Eventfinda events: ${response.statusCode}',
      );
    }
  } catch (e) {
    print('Error fetching Eventfinda events: $e');
    if (e is DioException) {
      print('DioException type: ${e.type}');
      print('DioException message: ${e.message}');
      print('DioException response: ${e.response}');
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        iconTheme: IconThemeData(
    color: Theme.of(context).colorScheme.onSurface, 
  ),
        
        title: Text('All Upcoming Events',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface 
        ),),
        centerTitle: true,
      ),
      body: _events.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              
              itemCount: _events.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_events[index]['name'], style: TextStyle(color: Theme.of(context).colorScheme.onSurface),),
                  subtitle: Text( style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  _events[index]['source'] == 'ticketmaster'
                  ? _events[index]['dates']['start']['localDate'] ?? 'No date'
                  : _events[index]['source'] == 'moshtix'
                  ? _events[index]['startDate'] ?? 'No date'
                  : 'No date',
) ,
                  onTap: () => _navigateToEventDetailsPage(context, _events[index]),
                  
                );
              },
            ),
    
    
    bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Theme.of(context).colorScheme.onSurface),
            label: 'Home',
            
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event, color: Theme.of(context).colorScheme.secondary),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map, color: Theme.of(context).colorScheme.onSurface),
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
