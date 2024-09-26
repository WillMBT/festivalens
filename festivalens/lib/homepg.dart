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
import 'tickets.dart';
import 'ticketdetail.dart';
import 'map.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


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
    UploaderPage(),
    ProfilePage(),
  ];

    void _navigateToMapPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventsMapPage()),
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


 void _navigateToMapPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventsMapPage()),
    );
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
  

  final String credentials = 'festivalens:xg222ykmxwkj';
  

  final String encodedCredentials = base64Encode(utf8.encode(credentials));
  
  dio.options.headers['Authorization'] = 'Basic $encodedCredentials';
  
  try {
    print('Attempting to fetch Eventfinda events...');
    final response = await dio.get(
      'https://api.eventfinda.co.nz/v2/events.json',
      queryParameters: {
        'rows': 10, 
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
            TextButton(
              onPressed: () => _navigateToAllEventsPage(context),
              child: Text('See All',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,)),
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
          color: event['source'] == 'eventfinda' ?  Theme.of(context).colorScheme.tertiary: (event['source'] == 'moshtix' ? Theme.of(context).colorScheme.secondary: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
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
              enlargeCenterPage: true,
            ),
          ),
      ],
    );
  }
}




class MapSection extends StatelessWidget {
  final VoidCallback onTap;

  const MapSection({Key? key, required this.onTap}) : super(key: key);

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
              onPressed: () => _navigateToMapPage(context),
              child: Text('See More',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,)),
            ),
          ],
        ),
      GestureDetector(
        onTap: () => _navigateToMapPage(context),
        child: Container(
          height: 150,
          width: double.infinity,
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
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
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
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



class YourEventSection extends StatelessWidget {
  void _navigateToSecret(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UploaderPage(),
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
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        GestureDetector(
          onTap: () => _navigateToSecret(context),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Theme.of(context).colorScheme.primary,),
            height: 200,
            
            child: Center(
              child: Text(
                'Share your memories here! We offer photo uploads, so you can share your time at your favourite events, as well as seeing how everyone else enjoyed it too. Click here to upload now',
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