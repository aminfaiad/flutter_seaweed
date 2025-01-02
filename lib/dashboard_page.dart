import 'dart:async'; // For Timer
import 'package:flutter/material.dart';
import 'package:flutter_application_2/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'changepw_page.dart';
import 'salinity_page.dart';
import 'ph_page.dart';
import 'light_page.dart';
import 'temperature_page.dart';
import 'water_level_page.dart';
import 'camera_page.dart';

class DashboardPage extends StatefulWidget {
  final String username;
  final String mobile_token;
  
  DashboardPage({required this.username,required this.mobile_token
   
  });
  

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String salinity = 'Loading...';
  String phValue = 'Loading...';
  String lightIntensity = 'Loading...';
  String temperature = 'Loading...';
  
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
    _startAutoRefresh();
    sendPostRequest(fcmToken:fcmToken ,mobileToken: widget.mobile_token);
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the page is disposed
    super.dispose();
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      fetchDashboardData();
    });
  }

  final String url = 'https://smartseaweed.site/Real/fcm_token_api.php';

  Future<String> getDeviceType() async {
    if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else {
      return 'Unknown';
    }
  }

  Future<void> sendPostRequest({
    required String mobileToken,
    required String? fcmToken,
  }) async {
    try {
      final deviceType = await getDeviceType();
      final response = await http.post(
        Uri.parse(url),
        body: {
          'mobile_token': mobileToken,
          'fcm_token': fcmToken,
          'device_type': deviceType,
        },
      );

      if (response.statusCode == 200) {
        print('Request successful: ${response.body}');
      } else {
        print('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> fetchDashboardData() async {
    final url = Uri.parse('https://smartseaweed.site/Real/get_data.php');
    try {
      final response = await http.post(
        url,
        body: {
          'farm_token': 'test',
          'farm_range': 'current',
        },
      );

      //print('Response status: ${response.statusCode}');
      //print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          final data = responseData['data'];
          setState(() {
            salinity = '${data['salinity']} ppt';
            phValue = '${data['ph_value']} pH';
            lightIntensity = '${data['light_intensity']} lux';
            temperature = '${data['temperature']}°C';
          });
        } else if (responseData['status'] == 'error' &&
            responseData['message'] == 'No recent data found.') {
          setState(() {
            salinity = 'No Data';
            phValue = 'No Data';
            lightIntensity = 'No Data';
            temperature = 'No Data';
          });
        } else {
          throw Exception('Unexpected API response');
        }
      } else {
        throw Exception('Failed to connect to the server');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        salinity = 'Error';
        phValue = 'Error';
        lightIntensity = 'Error';
        temperature = 'Error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text("Profile"),
                value: 'profile',
              ),
              PopupMenuItem(
                child: Text("Change Password"),
                value: 'change_password',
              ),
              PopupMenuItem(
                child: Text("Logout"),
                value: 'logout',
              ),
            ],
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              } else if (value == 'change_password') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                );
              } else if (value == 'logout') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, ${widget.username}',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              DateTime.now().toLocal().toString().split(' ')[0],
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardBox(context, 'Salinity', salinity, Colors.blue, SalinityPage()),
                  _buildDashboardBox(context, 'pH', phValue, Colors.green, PhPage()),
                  _buildDashboardBox(context, 'Light', lightIntensity, Colors.yellow, LightPage()),
                  _buildDashboardBox(context, 'Temperature', temperature, Colors.red, TemperaturePage()),
                  _buildDashboardBox(context, 'Water Level', '50 cm', Colors.cyan, WaterLevelPage()),
                  _buildDashboardBox(context, 'Cameras', 'Active', Colors.orange, CameraPage()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardBox(BuildContext context, String title, String value, Color color, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}