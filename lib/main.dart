import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth/screens/email_password_auth_screen.dart';
import 'package:flutter_auth/screens/guest_auth_screen.dart';
import 'package:flutter_auth/screens/profile_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GlobalKey<NavigatorState> _navigator = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      navigatorKey: _navigator,
      builder: (ctx, navigator) {
        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (c) {
                return SafeArea(child: navigator!);
              },
            ),
            OverlayEntry(
              builder: (c) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _navigator.currentState!.pushReplacementNamed(
                          "/auth/email-password",
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        foregroundColor: Colors.green
                      ),
                      child: const Text('По почте и паролю'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _navigator.currentState!.pushReplacementNamed(
                          "/auth/guest",
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          foregroundColor: Colors.green
                      ),
                      child: const Text('Анонимная'),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
      routes: {
        "/auth/email-password": (ctx) => EmailPasswordAuthScreen(),
        "/auth/guest": (ctx) => GuestAuthScreen(),
        '/profile': (ctx) => ProfileScreen(),
      },
      initialRoute: "/auth/email-password",
    );
  }
}
