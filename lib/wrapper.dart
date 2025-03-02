import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:secretary/screens/dashboard.dart';
import 'package:secretary/screens/login_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  Future<String?> _getUserRole(String uid) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        return userDoc.data()?['role'] ?? 'secretary';
      } else {
        return 'secretary';
      }
    } catch (e) {
      print("Error fetching user role: $e");
      return 'secretary';
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;

          if (user == null) {
            return LoginScreen();
          } else {
            return FutureBuilder<String?>(
              future: _getUserRole(user.uid),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (roleSnapshot.hasError || !roleSnapshot.hasData) {
                  return Scaffold(
                    body: Center(child: Text("Error fetching user role")),
                  );
                } else {
                  final String? userRole = roleSnapshot.data;
                  userRole ?? 'secretary';
                  return Dashboard(userRole: userRole ?? 'secretary');
                }
              },
            );
          }
        }
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
