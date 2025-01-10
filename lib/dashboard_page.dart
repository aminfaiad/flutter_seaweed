import 'dart:async'; // For Timer
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'salinity_page.dart';
import 'ph_page.dart';
import 'light_page.dart';
import 'temperature_page.dart';
import 'camera_page.dart';
import 'main.dart';
double current_water_level=0.0;
class DashboardPage extends StatefulWidget {
  final String username;
  final String mobile_token;
  final String farm_token;

  DashboardPage(
      {required this.username, required this.mobile_token, required this.farm_token});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String salinity = 'Loading...';
  String phValue = 'Loading...';
  String lightIntensity = 'Loading...';
  String temperature = 'Loading...';
  String water_level = 'Loading...';

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
    _startAutoRefresh();
    sendPostRequest(fcmToken: fcmToken, mobileToken: widget.mobile_token);
    requestNotificationPermission();
  }

  @override
  void dispose() {
    _timer?.cancel();
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

  Future<void> requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined permission');
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
          'farm_token': widget.farm_token,
          'farm_range': 'current',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          final data = responseData['data'];
          setState(() {
            salinity = '${data['salinity']} ppt';
            phValue = '${data['ph_value']} pH';
            lightIntensity = '${data['light_intensity']} lux';
            temperature = '${data['temperature']}°C';
            water_level = '${data['water_level']}cm';
            current_water_level = double.tryParse(data['water_level'])?? 0.0;
            //print(current_water_level);
          });
        } else {
          setState(() {
            salinity = 'No Data';
            phValue = 'No Data';
            lightIntensity = 'No Data';
            temperature = 'No Data';
            water_level = 'No Data';
          });
        }
      } else {
        throw Exception('Failed to connect to the server');
      }
    } catch (e) {
      setState(() {
        salinity = 'Error';
        phValue = 'Error';
        lightIntensity = 'Error';
        temperature = 'Error';
        water_level = "Error";
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, ${widget.username}',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
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
                  _buildDashboardBox(context, 'Salinity', salinity,
                      Colors.blue, SalinityPage(farm_token: widget.farm_token, type: "salinity")),
                  _buildDashboardBox(context, 'pH', phValue, Colors.green,
                      PhPage(farm_token: widget.farm_token, type: "ph_value")),
                  _buildDashboardBox(context, 'Light', lightIntensity,
                      Colors.yellow, LightPage(farm_token: widget.farm_token, type: "light_intensity")),
                  _buildDashboardBox(context, 'Temperature', temperature,
                      Colors.red, TemperaturePage(farm_token: widget.farm_token, type: "temperature")),
                  _buildDashboardBox(
                      context, 'Water Level', water_level, Colors.cyan, null),
                  _buildDashboardBox(
                      context,
                      'Cameras',
                      'Active',
                      Colors.orange,
                      CameraPage(farm_token: widget.farm_token)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardBox(
      BuildContext context, String title, String value, Color color, Widget? page) {
    return GestureDetector(
      onTap: () {
        if (title == "Water Level" && double.tryParse(value.substring(0, value.length - 2)) != null) {
          _showWaterLevelDialog(context);
        } else if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => page,
            ),
          );
        }
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
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.bold),
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

  void _showWaterLevelDialog(BuildContext context) {
  final TextEditingController waterLevelController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Calibrate Water Level',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your current water level:',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: 16),
            TextField(
              controller: waterLevelController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter value in cm',
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
  onPressed: () async {
    String enteredValue = waterLevelController.text.trim();

    // Input validation: Check if the input is a valid number
    if (enteredValue.isEmpty || double.tryParse(enteredValue) == null) {
      // Show an error popup if validation fails
      _showErrorDialog(context, 'Invalid Input',
          'Please enter a valid numeric value for the water level.');
    } else {
      // Prepare the API call
      final url = Uri.parse('https://smartseaweed.site/Real/update_water_level.php');
      final requestData = {
        'farm_token': widget.farm_token, // Assuming widget.farmToken is available
        'current_water_level': current_water_level,
        'new_water_level': double.parse(enteredValue),
      };

      try {
        // Make the POST request
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestData),
        );

        // Parse the response
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);

          if (responseData['status'] == 'success') {
            // Show a success message
            _showSuccessDialog(context, 'Success', responseData['message']);

          } else {
            // Show an error message from the API
            _showErrorDialog(context, 'Error', responseData['message']);
          }
        } else {
          // Handle non-200 status code
          _showErrorDialog(context, 'Error', 'Failed to update water level. Please try again later.');
        }
      } catch (e) {
        // Handle exceptions during the API call
        _showErrorDialog(context, 'Error', 'An error occurred: $e');
      }
    }
  },
  child: Text(
    'Confirm',
    style: TextStyle(color: Colors.green),
  ),
)
,
        ],
      );
    },
  );
}

void _showSuccessDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          title,
          style: TextStyle(color: Colors.green),
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close success dialog
              Navigator.pop(context); // Close the main dialog
            },
            child: Text(
              'OK',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      );
    },
  );
}

void _showErrorDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          title,
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close error dialog
            },
            child: Text(
              'OK',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      );
    },
  );
}


}