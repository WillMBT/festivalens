import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'tickets.dart';  

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

class FestivaLensHomePage extends StatelessWidget {
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
            SizedBox(height: 16),
            YourTicketsSection(),
            SizedBox(height: 16),
            YourEventSection(),
          ],
        ),
      ),
    );
  }
}

class UpcomingEventsSection extends StatelessWidget {
  void _showModalBottomSheet(BuildContext context, String event) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Details for $event'),
                ElevatedButton(
                  child: const Text('Close BottomSheet'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Events',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        CarouselSlider(
          items: [1, 2, 3].map((i) {
            return GestureDetector(
              onTap: () => _showModalBottomSheet(context, 'Event #$i'),
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
                    "Event #$i",
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
          ),
        ),
      ],
    );
  }
}

class YourTicketsSection extends StatelessWidget {
  void _navigateToTicketsPage(BuildContext context, String eventName, String eventDetails) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketsPage(eventName: eventName, eventDetails: eventDetails),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Tickets',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _navigateToTicketsPage(context, 'Event #2', 'Be there 14th May, 8:00PM'),
          child: Container(
            height: 50,
            color: Colors.red,
            child: Center(
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
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _navigateToTicketsPage(context, 'Event #3', 'Be there 30th December, 9:45AM'),
          child: Container(
            height: 50,
            color: Colors.orange,
            child: Center(
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
        SizedBox(height: 8),
        Container(
          height: 100,
          color: Colors.amber,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Event #4\nInformation about the event will be here:\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
