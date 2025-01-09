import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'home_page.dart';

String? fcmToken;

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background messaging
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

Future<bool> checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isLoggedIn') ?? false;
}

Future<Map<String, String>> getUserDetails() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String username = prefs.getString('username') ?? 'User';
  String mobileToken = prefs.getString('mobile_token') ?? '';
  return {'username': username, 'mobile_token': mobileToken};
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set up the background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Retrieve FCM token
  fcmToken = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $fcmToken");

  // Check login status
  bool isLoggedIn = await checkLoginStatus();
  Map<String, String> userDetails = isLoggedIn ? await getUserDetails() : {};

  runApp(MyApp(isLoggedIn: isLoggedIn, userDetails: userDetails));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final Map<String, String> userDetails;

  MyApp({required this.isLoggedIn, required this.userDetails});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn
          ? FarmDashboardPage(
              username: userDetails['username']!,
              mobile_token: userDetails['mobile_token']!,
            )
          : LoginPage(), // Redirect to login if not logged in
    );
  }
}
