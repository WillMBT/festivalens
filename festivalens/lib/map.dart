import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'all_events_page.dart';
import 'home.dart';
import 'upload.dart';
import 'profile.dart';


class EventsMapPage extends StatefulWidget {
  @override
  _EventsMapPageState createState() => _EventsMapPageState();
}

class _EventsMapPageState extends State<EventsMapPage> {
  // Definese events and map controller
  List<dynamic> _events = [];
  bool _isLoading = true;
  final MapController _mapController = MapController();
// Updates state of page & calls fetch events
  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }
// Defines pages for navbar
  int _selectedIndex = 0;
  static List<Widget> get _pages => [
        FestivaLensHomePage(),
        AllEventsPage(),
        EventsMapPage(),
        UploaderPage(),
        ProfilePage(),
      ];
// Function for working navbar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _pages[index]),
    );
  }
// Fetch Events function
  Future<void> _fetchEvents() async {
    final response = await http.get(
      Uri.parse(
          'https://app.ticketmaster.com/discovery/v2/events.json?classificationName=music&countryCode=NZ&apikey=ytLHZaQDHtMK8EGePOX2GKjj6GiDYdu6'),
    );
// If successful response, get venue info
    if (response.statusCode == 200) {
      setState(() {
        _events = json.decode(response.body)['_embedded']['events'];
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load events');
    }
  }
// Function to build map markers
  List<Marker> _buildMarkers() {
    return _events.map((event) {
      final venue = event['_embedded']['venues'][0];
      // Uses Latitude and Longitude from API call
      final lat = double.parse(venue['location']['latitude']);
      final lon = double.parse(venue['location']['longitude']);
      return Marker(
        // Builds markers
        // Hard-coded, needs to be 80 to show location accurately
        width: 80.0, 
        height: 80.0,
        point: LatLng(lat, lon), 
        child: GestureDetector(
          onTap: () {
            // Shows info of event on marker click
            _showEventInfo(event);
          },
          child: Icon(
            // Options for markers
            Icons.location_on,
            color: Colors.red,
            size: 40.0,
          ),
        ),
      );
    }).toList(); // Adds markers to list
  }
// Function to show info about event when marker clicked
  void _showEventInfo(dynamic event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(event['name']),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Info shown about events
                Text('Date: ${event['dates']['start']['localDate']}'),
                Text('Time: ${event['dates']['start']['localTime']}'),
                Text('Venue: ${event['_embedded']['venues'][0]['name']}'),
                if (event['priceRanges'] != null && event['priceRanges'].isNotEmpty)
                  Text('Price: \$${event['priceRanges'][0]['min']} - \$${event['priceRanges'][0]['max']}'),
                SizedBox(height: 10),
                Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                // Shows event info
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
// Building of App
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
        borderRadius: BorderRadius.circular(20), 
        child: Container(
          height: MediaQuery.of(context).size.height / 1.55,
          width: MediaQuery.of(context).size.width / 1.1, 
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    // Sets intial map location
                    initialCenter: LatLng(-41.2865, 174.7762), // Wellington, NZ
                    initialZoom: 6.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      // Calls marker bulding function
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
            height: MediaQuery.of(context).size.height / 10, // Height for events carousel
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              // Number of events shown determined by number of events on ist
              itemCount: _events.length,
              itemBuilder: (context, index) {
                // Events shown
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
                        // Event name from API
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
          BottomNavigationBarItem( // All Events
            icon: Icon(Icons.event, color: Theme.of(context).colorScheme.onSurface),
            label: 'Events',
          ),
          BottomNavigationBarItem( // Map (selected)
            icon: Icon(Icons.location_on, color: Theme.of(context).colorScheme.secondary),
            label: 'Map',
          ),
          BottomNavigationBarItem( // Upload
            icon: Icon(Icons.file_upload_outlined, color: Theme.of(context).colorScheme.onSurface),
            label: 'Upload',
          ),
          BottomNavigationBarItem( // Profile
            icon: Icon(Icons.person, color: Theme.of(context).colorScheme.onSurface),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
// End of code