import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kpi_test/statistics.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'login.dart';
import 'dart:convert';

// import 'statistics.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {
  int adminCounter = 0;
  int technicalCounter = 0;
  int retailInquiryCounter = 0;
  int printingAvenueCounter = 0;
  
  Map<String, bool> isButtonDisabled = {
    "Admin": false,
    "Technical": false,
    "Retail Inquiry": false,
    "Printing Avenue": false,
  };
  @override
  void initState() {
    super.initState();
    _fetchClickCounts();
  }

  

  Future<void> _sendClickData(String buttonType) async {
    final url = Uri.parse('http://192.168.1.182/kpi_itave/store_click.php');
    try {
      final response = await http.post(url, body: {'buttonType': buttonType});
      if (response.statusCode == 200) {
        print("Click recorded successfully");
      } else {
        print("Failed to record click: \${response.statusCode}");
      }
    } catch (e) {
      print("Error sending click data: $e");
    }
  }
  Future<void> _fetchClickCounts() async {
    final url = Uri.parse('http://192.168.1.182/kpi_itave/store_click.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          adminCounter = int.tryParse(data["Admin"].toString()) ?? 0;
          technicalCounter = int.tryParse(data["Technical"].toString()) ?? 0;
          retailInquiryCounter = int.tryParse(data["Retail Inquiry"].toString()) ?? 0;
          printingAvenueCounter = int.tryParse(data["Printing Avenue"].toString()) ?? 0;
        });
      }
    } catch (e) {
      print("Error fetching counts: $e");
    }
  }


  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _GotoStatistics(){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => StatisticsPage())
    );
  }

  void _incrementCounter(String buttonType) {
    if (isButtonDisabled[buttonType] == true) return;

    setState(() {
      isButtonDisabled[buttonType] = true;
    });

    _sendClickData(buttonType).then((_) => _fetchClickCounts());

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        isButtonDisabled[buttonType] = false;
      });
    });
  }

  Widget _buildCounterCard(String title, int count, IconData icon, Color color, double screenWidth) {
    double buttonFontSize = screenWidth < 400 ? 12 : 16;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            SizedBox(height: 5),
            Text('Clicked: $count times', style: TextStyle(fontSize: 16, color: Colors.grey[700]), textAlign: TextAlign.center),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: isButtonDisabled[title]! ? null : () => _incrementCounter(title),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Center(
                child: Text("Click $title", style: TextStyle(fontSize: buttonFontSize), textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth * 0.9;
    double containerHeight = MediaQuery.of(context).size.height * 1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 227, 64, 55),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipOval(
              child: Image.asset(
                'assets/image/logo.png',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            Text(widget.title, style: TextStyle(color: Colors.white, fontSize: 20)),
            TextButton(
              onPressed: _logout,
              child: Text("Logout", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Center(
        child: Container(
          width: containerWidth,
          height: containerHeight,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)],
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildCounterCard("Admin", adminCounter, LucideIcons.user, Colors.blue, screenWidth)),
                    SizedBox(width: 10),
                    Expanded(child: _buildCounterCard("Technical", technicalCounter, LucideIcons.settings, Colors.green, screenWidth)),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildCounterCard("Retail Inquiry", retailInquiryCounter, LucideIcons.shoppingCart, Colors.orange, screenWidth)),
                    SizedBox(width: 10),
                    Expanded(child: _buildCounterCard("Printing Avenue", printingAvenueCounter, LucideIcons.printer, Colors.purple, screenWidth)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _GotoStatistics();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("Statistics", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}