import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dashboard_page.dart';

class CameraPage extends StatefulWidget {
  final String username;
  final String mobile_token;

  CameraPage({required this.username, required this.mobile_token});

  final String farm_token = "8a2dcd67646081ef53ed4b21958c57f4";

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  String? _imageUrl;
  Timer? _imageTimer;
  Widget? _currentImageWidget;
  String? _errorMessage;
  bool _isFetching = false; // Prevent concurrent API calls

  @override
  void initState() {
    super.initState();
    _startFetchingImages();
  }

  @override
  void dispose() {
    _imageTimer?.cancel();
    super.dispose();
  }

  void _startFetchingImages() {
    _imageTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (!_isFetching) {
        _fetchImageUrl();
      }
    });
  }

  Future<void> _fetchImageUrl() async {
    setState(() {
      _isFetching = true;
    });

    try {
      final url = Uri.parse('https://smartseaweed.site/Real/get_img.php');
      final response = await http.post(
        url,
        body: {'farm_token': widget.farm_token},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          final newImageUrl = 'https://smartseaweed.site/Real/' + jsonResponse['image_path'];

          if (newImageUrl != _imageUrl) {
            setState(() {
              _imageUrl = newImageUrl;
              _currentImageWidget = _buildZoomableImage(_imageUrl!);
              _errorMessage = null;
            });
          }
        } else {
          throw Exception(jsonResponse['message'] ?? 'Unknown error');
        }
      } else {
        throw Exception('Failed to fetch image URL');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch image: $e';
      });
    } finally {
      setState(() {
        _isFetching = false;
      });
    }
  }

  Widget _buildZoomableImage(String imageUrl) {
    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 4.0,
      child: Image.network(imageUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Camera Feed',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildImageDisplay(),
    );
  }

  Widget _buildImageDisplay() {
    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Center(
      child: _currentImageWidget ?? CircularProgressIndicator(),
    );
  }
}
