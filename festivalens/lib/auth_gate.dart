import 'package:festvialens/home.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart'; 
import 'package:flutter/material.dart';



class AuthGate extends StatelessWidget {
 const AuthGate({super.key});
// Builds page
 @override
 Widget build(BuildContext context) {
   return StreamBuilder<User?>(
    // Detect authentication state change (logged in or out)
     stream: FirebaseAuth.instance.authStateChanges(), 
     builder: (context, snapshot) {
       if (!snapshot.hasData) {
         return SignInScreen(
           providers: [
            // Email Login
             EmailAuthProvider(), 
             // Google Login
             GoogleProvider(clientId: "391014440478-vmiscpr7km57tsmu6vdec38060eo7gti.apps.googleusercontent.com"), 
           ],
           headerBuilder: (context, constraints, shrinkOffset) {
             return Padding(
               padding: const EdgeInsets.all(20),
               child: AspectRatio(
                 aspectRatio: 1,
                 
               ),
             );
           },
           subtitleBuilder: (context, action) {
             return Padding(
               padding: const EdgeInsets.symmetric(vertical: 8.0),
               child: action == AuthAction.signIn // Calls sign in action from firebase
                   ? const Text('Welcome to FestivaLens please sign in!')
                   : const Text('Welcome to FestivaLens, please sign up!'),
             );
           },
           footerBuilder: (context, action) {
             return const Padding(
               padding: EdgeInsets.only(top: 16),
               child: Text(
                 'By signing in, you agree to our terms and conditions.',
                 style: TextStyle(color: Colors.grey),
               ),
             );
           },
           sideBuilder: (context, shrinkOffset) {
             return Padding(
               padding: const EdgeInsets.all(20),
               child: AspectRatio(
                 aspectRatio: 1,
                 
               ),
             );
           },
         );
       }

       return FestivaLensHomePage(); // Goes to home page on login
     },
   );
 }
}