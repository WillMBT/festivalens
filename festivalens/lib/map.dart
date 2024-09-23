import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'all_events_page.dart';

import 'homepg.dart';
import 'upload.dart';
import 'profile.dart';


class EventsMapPage extends StatefulWidget {
  @override
  _EventsMapPageState createState() => _EventsMapPageState();
}

class _EventsMapPageState extends State<EventsMapPage> {
  List<dynamic> _events = [];
  bool _isLoading = true;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  int _selectedIndex = 0;
  static List<Widget> get _pages => [
        FestivaLensHomePage(),
        AllEventsPage(),
        EventsMapPage(),
        UploaderPage(),
        ProfilePage(),
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

  Future<void> _fetchEvents() async {
    final response = await http.get(
      Uri.parse(
          'https://app.ticketmaster.com/discovery/v2/events.json?classificationName=music&countryCode=NZ&apikey=ytLHZaQDHtMK8EGePOX2GKjj6GiDYdu6'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _events = json.decode(response.body)['_embedded']['events'];
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load events');
    }
  }

  List<Marker> _buildMarkers() {
    return _events.map((event) {
      final venue = event['_embedded']['venues'][0];
      final lat = double.parse(venue['location']['latitude']);
      final lon = double.parse(venue['location']['longitude']);
      return Marker(
        width: 80.0,
        height: 80.0,
        point: LatLng(lat, lon),
        child: GestureDetector(
          onTap: () {
            _showEventInfo(event);
          },
          child: Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40.0,
          ),
        ),
      );
    }).toList();
  }

  void _showEventInfo(dynamic event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(event['name']),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Date: ${event['dates']['start']['localDate']}'),
                Text('Time: ${event['dates']['start']['localTime']}'),
                Text('Venue: ${event['_embedded']['venues'][0]['name']}'),
                if (event['priceRanges'] != null && event['priceRanges'].isNotEmpty)
                  Text('Price: \$${event['priceRanges'][0]['min']} - \$${event['priceRanges'][0]['max']}'),
                SizedBox(height: 10),
                Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(event['info'] ?? 'No description available.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface, //change your color here
        ),
        
        title: Text(
          'Map',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.all(8.0)),
          // Map Section
          
        Align(
  alignment: Alignment.center,
    child: ClipRRect(
        borderRadius: BorderRadius.circular(20), // Adjust the radius as needed
        child: Container(
          height: MediaQuery.of(context).size.height / 1.55,
          width: MediaQuery.of(context).size.width / 1.1, // Adjust height as needed
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(-41.2865, 174.7762), // Wellington, NZ
                    initialZoom: 6.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: _buildMarkers(),
                    ),
                  ],
                ),
        ),
      ),
        ),

          // Events Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Events',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Container(
            height: 100, // Height for events carousel
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    width: 150,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        event['name'] ?? 'Unnamed Event',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.surface,
                        )
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
            icon: Icon(Icons.event, color: Theme.of(context).colorScheme.onSurface),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on, color: Theme.of(context).colorScheme.secondary),
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
