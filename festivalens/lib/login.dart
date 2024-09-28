import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      actions: [
        ForgotPasswordAction((context, email) {
          // Handles forgot password
          Navigator.pushNamed(context, '/forgot-password', arguments: email);
        }),
        AuthStateChangeAction<SignedIn>((context, state) {
          Navigator.pushReplacementNamed(context, '/profile');
        }),
      ],
      providers: [
        // Email Login
        EmailAuthProvider(), 
        // Google Login
        GoogleProvider(clientId: "391014440478-vmiscpr7km57tsmu6vdec38060eo7gti.apps.googleusercontent.com"), 
      ],
    );
  }
}
