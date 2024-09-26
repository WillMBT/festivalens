import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

class ProfilePage extends StatelessWidget {
  
  
  
  
  
  
  
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          Future.microtask(() {
            Navigator.of(context).pushReplacementNamed('/sign-in');
          });
          
        }

        final user = snapshot.data;

        return ProfileScreen(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(
              'Your Profile',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            centerTitle: true,
          ),
          actions: [
            SignedOutAction((context) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                print('Cannot pop the screen');
              }
            }),
          ],
        
        );
      },
    );
  }
}