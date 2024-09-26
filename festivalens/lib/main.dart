import 'package:festvialens/homepg.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'theme_notifier.dart';
import 'profile.dart';

import 'auth_gate.dart';

const clientId = 'AIzaSyATmQwvTbYD4Y_llB9uojbJ8EviqgK5iR8';

void main() async {
 WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp(
   options: DefaultFirebaseOptions.currentPlatform,
 );
runApp(ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: MyApp(),)
 
 
 );




}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'FestivaLens',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeNotifier.themeMode,
          home: AuthGate(),
          
      routes: {
        
        '/profile': (context) => ProfilePage(),  // Define profile page
        '/sign-in': (context) => AuthGate(),   // Define the sign-in page route
        },
        );
      },
    );
  }
}