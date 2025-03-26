// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'login.dart';
import 'dart:convert';
import 'statistics.dart';
import 'settings.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'home.dart';
import 'iconlist.dart';
import 'package:flutter/services.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:data_table_2/data_table_2.dart';



// import 'statistics.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}



class _TestPageState extends State<TestPage> {
  final TextEditingController _controller = TextEditingController();
  final RegExp _dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');


  TextEditingController date = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        print(picked);
        print(picked.month);
        print(picked.year);
        print(picked.day);
        _dateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        print(_dateController.text);
      });
    }
  }
  String ip = dotenv.get('IP_ADDRESS');

  final TextEditingController _startingDateController = TextEditingController();
  final TextEditingController _endingDateController = TextEditingController();

  List<Map<String, dynamic>> _departmentVisitors = [];

  Future<void> _getDepartmentVisitors() async {
    final url = Uri.parse('http://$ip/kpi_itave/statistics.php?action=getDepartmentVisitors');
    try {
      final response = await http.post(
        url,
        body: {
          'starting_date': _startingDateController.text,
          'ending_date': _endingDateController.text,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _departmentVisitors = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print("Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }




  @override
  void initState(){
    super.initState();
    _getDepartmentVisitors();
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _goToStatistics(){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => StatisticsPage())
    );
  }
  void _goToSettings(){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage())
    );
  }
  void _goToTest(){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage(title: 'Home Page')),
    );
  }




  @override
  Widget build(BuildContext context) {
    
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
            Text("Test Home", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            PopupMenuButton<int>(
              icon: Icon(Icons.account_circle, color: Colors.white, size: 30),
              onSelected: (value) {
                if (value == 3) {
                  _logout();
                } else if (value == 2) {
                  _goToSettings();
                } else if (value == 1) {
                  _goToStatistics();
                } else if (value == 4) {
                  _goToTest();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 0,
                  child: Text("Why", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(LucideIcons.lineChart, color: const Color.fromARGB(255, 0, 0, 0)),
                      SizedBox(width: 8),
                      Text("Analytics", style: GoogleFonts.poppins(color: const Color.fromARGB(255, 0, 0, 0))),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: const Color.fromARGB(255, 0, 0, 0)),
                      SizedBox(width: 8),
                      Text("Settings", style: GoogleFonts.poppins(color: const Color.fromARGB(255, 0, 0, 0))),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 3,
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text("Logout", style: GoogleFonts.poppins(color: Colors.red)),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 4,
                  child: Row(
                    children: [
                      Icon(LucideIcons.activity, color: const Color.fromARGB(255, 0, 0, 0)),
                      SizedBox(width: 8),
                      Text("Test", style: GoogleFonts.poppins(color: const Color.fromARGB(255, 0, 0, 0))),
                    ],
                  ),
                ),
                
              ],
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _startingDateController,
              decoration: InputDecoration(
                labelText: "Starting Date",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _endingDateController,
              decoration: InputDecoration(
                labelText: "Ending Date",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _getDepartmentVisitors,
              child: Text("Search"),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text("Button ID")),
                    DataColumn(label: Text("Button Name")),
                    DataColumn(label: Text("Counter Count")),
                    DataColumn(label: Text("Average Feedback")),
                  ],
                  rows: _departmentVisitors.map((data) {
                    return DataRow(cells: [
                      DataCell(Text(data['button_id'].toString())),
                      DataCell(Text(data['button_name'].toString())),
                      DataCell(Text(data['counter_count'].toString())),
                      DataCell(Text(data['average_feedback']?.toString() ?? 'N/A')),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), ''); 

    String formatted = "";
    if (digitsOnly.length > 4) {
      formatted += digitsOnly.substring(0, 4) + "-";
      if (digitsOnly.length > 6) {
        formatted += digitsOnly.substring(4, 6) + "-";
        formatted += digitsOnly.substring(6, digitsOnly.length.clamp(6, 8));
      } else {
        formatted += digitsOnly.substring(4, digitsOnly.length);
      }
    } else {
      formatted = digitsOnly;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}