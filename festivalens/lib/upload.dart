import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'all_events_page.dart';
import 'map.dart';
import 'profile.dart';

class UploaderPage extends StatefulWidget {
  @override
  _UploaderPageState createState() => _UploaderPageState();
}



class _UploaderPageState extends State<UploaderPage> {
// Defines
File? _imageFile;
String? _downloadURL;
List<String> _imageUrls = [];
List<dynamic> _events = [];
String? _selectedEventId;
int _selectedIndex = 0;
// Updates states
@override
  void initState() {
    super.initState();
    _fetchTicketmasterEvents();
  }
// Defines pages for navbar
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
      this.context,
      MaterialPageRoute(builder: (context) => _pages[index]),
    );
  }
// Fetches ticketmaster events (only ticketmaster available currently)
Future<List<dynamic>> _fetchTicketmasterEvents() async {
    try {
      final response = await http.get(
        Uri.parse('https://app.ticketmaster.com/discovery/v2/events.json?classificationName=music&countryCode=NZ&apikey=ytLHZaQDHtMK8EGePOX2GKjj6GiDYdu6'),
      );

       if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['_embedded'] != null && jsonResponse['_embedded']['events'] != null) {
          setState(() {
            _events = jsonResponse['_embedded']['events'];
          });
          return jsonResponse['_embedded']['events'];
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




// Picks image to upload
Future<void> _pickImage() async {

  final pickedFile = await ImagePicker()
      .pickImage(source: ImageSource.gallery, imageQuality: 100);
  setState(() {
    _imageFile = File(pickedFile!.path);
  });
}
// Uploads Image
Future<void> _uploadImage() async {
    if (_imageFile == null || _selectedEventId == null) return;

    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('event_images/${_selectedEventId}/$fileName');
    await storageRef.putFile(_imageFile!);
    final url = await storageRef.getDownloadURL();
  
  setState(() {
    _downloadURL = url; //stores URL in database & to displays image

  });
   _loadImagesFromFirebase(_selectedEventId!);
}
 // Displays images at hte bottom
 Future<void> _loadImagesFromFirebase(String eventId) async {
    final ListResult result = await FirebaseStorage.instance.ref('event_images/$eventId').listAll();
    final List<String> urls = [];

    for (var ref in result.items) {
      final url = await ref.getDownloadURL();
      urls.add(url);
    }

    setState(() {
      _imageUrls = urls;
    });
  }

// Building of page
 @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        
        title: Text(
          'Upload',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Event Dropdown
                LayoutBuilder(
  builder: (context, constraints) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: DropdownButton<String>(
        // Dropdown to select events
        hint: Text(
          'Select an event',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface), 
        ),
        value: _selectedEventId, // gathered from API
        isExpanded: true,
        dropdownColor: Theme.of(context).colorScheme.surface,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface), 
        items: _events.map<DropdownMenuItem<String>>((event) {
          return DropdownMenuItem<String>(
            
            value: event['id'], // From API, creates folder for event
            child: Text(
              event['name'], // From API
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          );
        }).toList(), // 
        onChanged: (value) {
          setState(() {
            _selectedEventId = value;
            _loadImagesFromFirebase(_selectedEventId!); // Displays images at bottom
          });
        },
      ),
    );
  },
),
                SizedBox(height: 20),
                _imageFile != null
                    ? Image.file(_imageFile!, height: 250, width: 250)
                    : Container(
                        height: 250,
                        width: 250,
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.onSurface),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(Icons.image, color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                ElevatedButton(
                  onPressed: _pickImage, child: Text("Choose Image", // Calls pick image
                  style: TextStyle(color: Theme.of(context).colorScheme.surface),),
                  style: ElevatedButton.styleFrom(
                     backgroundColor: Theme.of(context).colorScheme.secondary,
            ),),
                SizedBox(width: 50,),

                 ElevatedButton(
                  onPressed: _uploadImage, child: Text("Upload Image", // Call Upload Image
                  style: TextStyle(color: Theme.of(context).colorScheme.surface),),
                  style: ElevatedButton.styleFrom(
                     backgroundColor: Theme.of(context).colorScheme.tertiary,
            ),),
                ]),
                _downloadURL != null
                    ? Image.network(
                        _downloadURL!,
                        height: 0,
                        width: 0,
                      )
                    : SizedBox(height: 20),
                SizedBox(height: 40),
                Text("Uploaded Images:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                SizedBox(height: 20),
                _imageUrls.isNotEmpty
                    ? GridView.builder(
                        shrinkWrap: true,
                        
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Display 3 images per row
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _imageUrls.length,
                        itemBuilder: (context, index) {
                          // Displays Images
                          return Image.network(_imageUrls[index], fit: BoxFit.cover);
                        },
                      )
                    : Text("No images uploaded yet.", style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ),
        ),
      ),
//Navbar
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
            icon: Icon(Icons.location_on, color: Theme.of(context).colorScheme.onSurface),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_upload_outlined, color: Theme.of(context).colorScheme.secondary),
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