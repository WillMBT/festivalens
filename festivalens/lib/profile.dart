import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  ProfileScreen(
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
            Navigator.of(context).pop();
          }),
        ],
      );
    
  }
}