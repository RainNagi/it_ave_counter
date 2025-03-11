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

  Widget _buildCounterCard(String title, int count, IconData icon, Color color) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonFontSize = 16;
    double titleFontSize = 18;
    double counterFontSize = 30;
    double visitorFont = 10;
    double iconSize = 64;
    double horizontalPadding = 20;
    if (screenHeight < 850) {
      if (screenWidth < 500) {
        buttonFontSize = 10;
        titleFontSize = 10;
        counterFontSize = 12;
        visitorFont = 5;
        iconSize = 64;
        horizontalPadding = 5;
      } else if (screenWidth < 600) {
        buttonFontSize = 15;
        titleFontSize = 20;
        counterFontSize = 30;
        visitorFont = 12;
        iconSize = 70;
        horizontalPadding = 5;
      }
    } else {
        if (screenWidth < 500) {
        buttonFontSize = 16;
        titleFontSize = 6;
        counterFontSize = 8;
        visitorFont = 5;
        iconSize = 64;
        horizontalPadding = 5;
      } else if (screenWidth < 650) {
        buttonFontSize = 15;
        titleFontSize = 20;
        counterFontSize = 30;
        visitorFont = 12;
        iconSize = 100;
        horizontalPadding = 5;
      } else {
        buttonFontSize = 20;
        titleFontSize = 30;
        counterFontSize = 50;
        visitorFont = 15;
        iconSize = 100;
        horizontalPadding = 20;
      }
    }
    


    

    return Card(
      // elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(91, 0, 0, 0),
            
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
              // width: 500,
              // height: 500,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                // border: Border(
                //   top: BorderSide(color: Colors.black),
                //   left: BorderSide(color: Colors.black),
                //   right: BorderSide(color: Colors.black),
                //   bottom: BorderSide.none,
                // ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),  
                ),
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                style: TextStyle(
                                  fontSize: titleFontSize, 
                                  fontWeight: FontWeight.bold,
                                  ), 
                                textAlign: TextAlign.justify, 
                                softWrap: true,
                              ),
                              Container(
                                width: 30,
                                height: 2,
                                color: Color.fromRGBO(111, 5, 6, 1),
                              ),                            
                            ]
                          ),
                        ),
                        SizedBox(width: 30,),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('$count', 
                                style: TextStyle(
                                  fontSize: counterFontSize, 
                                  color: Colors.black, 
                                  fontWeight: FontWeight.bold
                                ),
                                textAlign: TextAlign.center
                              ),
                              Text('Visitors', 
                                style: TextStyle(
                                  fontSize: visitorFont,
                                  color: Colors.grey[700]
                                ), 
                                textAlign: TextAlign.center
                              ),
                            ],
                          ),
                        )
                      ]
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 10),
                        Icon(icon, size: iconSize, color: Color.fromRGBO(151, 81, 2, 1)),
                        SizedBox(height: 5),
                        SizedBox(height: 10),
                      ],
                    ),
                  )
                  
                ],
                
              ),
            ),
            ),
            
            ElevatedButton(
              onPressed: isButtonDisabled[title]! ? null : () => _incrementCounter(title),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(53, 53, 63, 1),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
              ),
              child: Center(
                child: Text("$title Visitor", style: TextStyle(fontSize: buttonFontSize), textAlign: TextAlign.center),
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
    double containerWidth = screenWidth * (screenWidth < 700?  1 : 0.8);
    double containerHeight = MediaQuery.of(context).size.height * 0.9;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(111, 5, 6, 1),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipOval(
              child: Container(
                color: Colors.white,
                child: Image.asset(
                  'assets/image/logo.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
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
          // color: Colors.red,
          padding: EdgeInsets.all(16),
          // decoration: BoxDecoration(
          //   color: Colors.white,
          //   borderRadius: BorderRadius.circular(20),
          //   boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)],
          // ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildCounterCard("Admin", adminCounter, LucideIcons.userCircle2, Colors.blue)),
                    SizedBox(width: 10),
                    Expanded(child: _buildCounterCard("Technical", technicalCounter, LucideIcons.settings, Colors.green)),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildCounterCard("Retail Inquiry", retailInquiryCounter, LucideIcons.shoppingCart, Colors.orange)),
                    SizedBox(width: 10),
                    Expanded(child: _buildCounterCard("Printing Avenue", printingAvenueCounter, LucideIcons.printer, Colors.purple)),
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