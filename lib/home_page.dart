import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_page.dart';
import 'profile_page.dart';
import 'changepw_page.dart';
import 'login_page.dart';

class FarmDashboardPage extends StatefulWidget {
  final String username;
  final String mobile_token;

  FarmDashboardPage({required this.username, required this.mobile_token});

  @override
  _FarmDashboardPageState createState() => _FarmDashboardPageState();
}

class _FarmDashboardPageState extends State<FarmDashboardPage> {
  List<Map<String, dynamic>> farms = [];
  String? selectedFarm;

  @override
  void initState() {
    super.initState();
    _fetchFarms();
  }

  Future<void> _fetchFarms() async {
    final url = 'https://smartseaweed.site/Real/get_farm_mobile.php';
    try {
      final response = await http.post(Uri.parse(url), body: {
        'mobile_token': widget.mobile_token,
      });
      final data = json.decode(response.body);

      if (data['error'] == null && data['farms'] != null) {
        setState(() {
          farms = List<Map<String, dynamic>>.from(data['farms']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Failed to fetch farms')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _addFarm() async {
    final url = 'https://smartseaweed.site/Real/add_farm_mobile.php';
    try {
      final response = await http.post(Uri.parse(url), body: {
        'mobile_token': widget.mobile_token,
      });
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        _fetchFarms(); // Refresh farm list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Farm added successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to add farm')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _deleteFarm(String farmToken) async {
    final url = 'https://smartseaweed.site/Real/del_farm_mobile.php';
    try {
      final response = await http.post(Uri.parse(url), body: {
        'mobile_token': widget.mobile_token,
        'farm_token': farmToken,
      });
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          // Clear the selected farm if it was deleted
          if (selectedFarm == farmToken) {
            selectedFarm = null;
          }
        });

        _fetchFarms(); // Refresh farm list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Farm deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to delete farm')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear session data
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  void _goToFarmDashboard() {
    if (selectedFarm != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(
            username: widget.username,
            mobile_token: widget.mobile_token,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a farm to proceed.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Green Side Area
          Container(
            width: 100,
            color: Colors.green,
            child: Column(
              children: [
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.white),
                  onPressed: selectedFarm != null
                      ? () => _deleteFarm(selectedFarm!)
                      : null,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: farms.length,
                    itemBuilder: (context, index) {
                      final farm = farms[index];
                      return ListTile(
                        title: Text(
                          farm['name'] ?? 'Unknown Farm',
                          style: TextStyle(
                            color: selectedFarm == farm['farm_token']
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                        tileColor: selectedFarm == farm['farm_token']
                            ? Colors.white
                            : Colors.green,
                        onTap: () {
                          setState(() {
                            selectedFarm = farm['farm_token'];
                          });
                        },
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.white),
                  onPressed: _addFarm,
                ),
              ],
            ),
          ),

          // White Main Area
          Expanded(
            child: Container(
              color: Colors.white,
              child: selectedFarm == null
                  ? Center(
                      child: Text('Select a farm to view details'),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            farms.firstWhere(
                                  (farm) => farm['farm_token'] == selectedFarm,
                                  orElse: () => {'name': 'Unknown Farm'},
                                )['name'] ??
                                'Unknown Farm',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text('Token: $selectedFarm'),
                          SizedBox(height: 20),
                          Text(
                            'Use this token to connect your Raspberry Pi.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.green,
            child: Icon(Icons.arrow_forward),
            onPressed: _goToFarmDashboard,
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
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
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(),
                  ),
                );
              } else if (value == 'change_password') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ChangePasswordPage(mobileToken: widget.mobile_token)),
                );
              } else if (value == 'logout') {
                _logout();
              }
            },
          ),
        ],
      ),
    );
  }
}
