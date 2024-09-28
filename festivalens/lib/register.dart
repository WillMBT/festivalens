import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class RegisterPage extends StatefulWidget {
  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
 // Define Input text editors
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _success = false;
  String _statusMessage = '';

  // Register function
  void _register() async {
    try {
      // Checks if inputs are empty
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        setState(() {
          _statusMessage = "Email and password cannot be empty.";
          _success = false;
        });
        return;
      }
      // Defines created user
      final User? user = (
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        )
      ).user;
      // if user is created, say they have successfully registered
      if (user != null) {
        setState(() {
          _success = true;
          _statusMessage = 'Successfully registered: ${user.email}';
        });
        print('User registered successfully: ${user.email}');
      } else {
        // Otherwise print error message
        setState(() {
          _success = false;
          _statusMessage = "Registration failed.";
        });
      }
    } catch (e) {
      setState(() { // Error Message cont.
        _success = false;
        _statusMessage = 'Registration failed: $e';
      });
      print('Registration failed: $e');
    }
  }
// Building Page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(15, 110, 0, 0),
              child: const Text(
                "Register",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 35, left: 20, right: 30),
              child: Column(
                children: <Widget>[
                  TextField(
                    // Calls controller to edit text
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'EMAIL',
                      labelStyle: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20,),
                  TextField(
                    // Calls controller to edit text
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'PASSWORD',
                      labelStyle: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 40,),
                  Container(
                    height: 40,
                    child: Material(
                      borderRadius: BorderRadius.circular(20),
                      shadowColor: Colors.greenAccent,
                      color: Colors.black,
                      elevation: 7,
                      child: GestureDetector(
                        onTap: _register, // Registers when register button pressed
                        child: const Center(
                          child: Text(
                            'SIGNUP',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Go Back',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15,),
                  // Says if it is success or not
                  Center(
                    child: Text(
                      _statusMessage,
                      style: TextStyle(
                        color: _success ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// End of code