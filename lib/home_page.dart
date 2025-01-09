import 'package:flutter/material.dart';
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
  List<String> farms = ['Farm1'];
  String? selectedFarm;

  void _addFarm() {
    setState(() {
      farms.add('Farm${farms.length + 1}');
    });
  }

  void _deleteFarm() {
    if (selectedFarm != null) {
      setState(() {
        farms.remove(selectedFarm);
        selectedFarm = null;
      });
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
                  onPressed: _deleteFarm,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: farms.length,
                    itemBuilder: (context, index) {
                      final farm = farms[index];
                      return ListTile(
                        title: Text(
                          farm,
                          style: TextStyle(
                            color: selectedFarm == farm
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                        tileColor: selectedFarm == farm
                            ? Colors.white
                            : Colors.green,
                        onTap: () {
                          setState(() {
                            selectedFarm = farm;
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
                            selectedFarm!,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text('Token: XYZ12345'), // Replace with actual token
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
                    builder: (context) => ProfilePage(
                     
                    ),
                  ),
                );
              } else if (value == 'change_password') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePasswordPage(
                      username: widget.username,
                    ),
                  ),
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
