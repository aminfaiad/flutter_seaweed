import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  final String username;
  final String email;
  final String mobile_token;

  ProfilePage({required this.username, required this.email, required this.mobile_token});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _usernameController;
  bool _isEditing = false;

  List<String> _listedFarms = []; // To hold the farm names
  bool _isLoadingFarms = true; // To indicate farm list loading state
  String _error = ''; // To hold any error messages

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _fetchFarms(); // Fetch the farms on page load
  }

  Future<void> _fetchFarms() async {
    try {
      final response = await http.post(
        Uri.parse('https://smartseaweed.site/Real/get_farm_mobile.php'),
        body: {'mobile_token': widget.mobile_token},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['error'] != null) {
          setState(() {
            _error = data['error'];
          });
        } else if (data['farms'] != null) {
          setState(() {
            _listedFarms = (data['farms'] as List)
                .map((farm) => farm['name'].toString())
                .toList();
            _isLoadingFarms = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load farms. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoadingFarms = false;
      });
    }
  }

  void _toggleEdit() async {
  setState(() {
    _isEditing = !_isEditing;
  });

  if (!_isEditing) {
    // Save the updated username to backend
    final String updatedUsername = _usernameController.text;
    final String mobileToken = widget.mobile_token;

    try {
      final response = await http.post(
        Uri.parse('https://smartseaweed.site/Real/change_username_mobile.php'),
        body: {
          'mobile_token': mobileToken,
          'username': updatedUsername,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Username updated successfully!")),
          );
        } else {
          // Show error message from the server
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "Failed to update username.")),
          );
        }
      } else {
        // Handle server error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: Unable to connect to the server.")),
        );
      }
    } catch (e) {
      // Handle request error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit,
              color: Colors.green,
            ),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            SizedBox(height: 20),

            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('asset/default.jpg'), // Default picture path
            ),
            SizedBox(height: 20),

            // Your Information
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Your Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Username
            TextField(
              controller: _usernameController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Email (Non-editable)
            TextField(
              controller: TextEditingController(text: widget.email),
              enabled: false,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Listed Farms (Fetched from API)
            if (_isLoadingFarms)
              CircularProgressIndicator()
            else if (_error.isNotEmpty)
              Text(
                _error,
                style: TextStyle(color: Colors.red),
              )
            else
              TextField(
                controller: TextEditingController(
                  text: _listedFarms.join(", "),
                ), // Join farm list into a string
                enabled: false,
                decoration: InputDecoration(
                  labelText: "Listed Farms",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}
