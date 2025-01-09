import 'dart:convert'; // For JSON encoding
import 'dart:typed_data'; // For handling POST body data
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LightPage extends StatefulWidget {
  final String farm_token;
  final String type;

  LightPage({required this.farm_token, required this.type});

  @override
  _LightPageState createState() => _LightPageState();
}

class _LightPageState extends State<LightPage> {
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    // Initialize the WebViewController with the POST request
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color.fromARGB(255, 255, 255, 255))
      ..loadRequest(
        Uri.parse('https://smartseaweed.site/Real/get_graph_day.php'), // Replace with your actual URL
        method: LoadRequestMethod.post,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: Uint8List.fromList(
          utf8.encode(
            Uri(queryParameters: {
              'farm_token': widget.farm_token,
              'type': widget.type,
            }).query,
          ),
        ),
      );
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
        title: Text(
          'Graph Monitor',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Sensor Type: ${widget.type.capitalize()}',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 8),
          SizedBox(height: 16),
          Expanded(
            child: WebViewWidget(controller: _webViewController),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
