import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future<void> _fetchEvents() async {
    final response = await http.get(
      Uri.parse('https://app.ticketmaster.com/discovery/v2/events.json?classificationName=music&countryCode=NZ&apikey=ytLHZaQDHtMK8EGePOX2GKjj6GiDYdu6'),
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
      appBar: AppBar(
        title: Text('Events Map'),
      ),
      body: _isLoading
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
    );
  }
}