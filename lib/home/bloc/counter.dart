import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


String ip = dotenv.get('IP_ADDRESS');

void incrementCounter(String buttonType, int buttonId, BuildContext context, VoidCallback refreshDepartments) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Adding to $buttonType"),
        content: Text("$buttonType Visitor?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("No"),
          ),
          TextButton(
            onPressed: () async {
              sendClickData(buttonId);
              refreshDepartments();
              Navigator.of(context).pop(true);
            },            
            child: Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

void sendClickData(int buttonId) async {
  String ip = dotenv.get('IP_ADDRESS');
  
  final url = Uri.parse('http://$ip/kpi_itave/store_click.php');
  try {
    final response = await http.post(url, body: {'button_id': buttonId.toString()});
    if (response.statusCode == 200) {
      print("Click recorded successfully");
    } else {
      print("Failed to record click: \${response.statusCode}");
    }
  } catch (e) {
    print("Error sending click data: $e");
  }
}