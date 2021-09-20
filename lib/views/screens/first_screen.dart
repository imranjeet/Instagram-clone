import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:namaste/auth/pages/loginScreen.dart';

import 'main_screen.dart';

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseUser>(
      future: FirebaseAuth.instance.currentUser(),
      builder: (context, snapshot) {
        FirebaseUser user = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (user == null) {
          return LoginScreen();
        } else {
          return MainScreen(currentUserId: user.uid);
        }
      },
    );
  }
}
