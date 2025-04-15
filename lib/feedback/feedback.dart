// ignore_for_file: avoid_print, library_private_types_in_public_api, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rating_and_feedback_collector/rating_and_feedback_collector.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'dart:convert';
import '../home/home.dart';


class CustomerFeedback extends StatefulWidget {
  const CustomerFeedback({super.key});
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<CustomerFeedback> {
  String ip = dotenv.get('IP_ADDRESS');  
  
  List<Map<String, dynamic>> _departments = [];
  int? _selectedDepartment;
  
  List<Map<String, dynamic>> _questions = [];
  Map<int, double> _ratings = {}; 
  
  TextEditingController CustomerNameController = TextEditingController();

   @override
  void initState() {
    super.initState();
    _fetchQuestions();
    _fetchDepartments();
  }
  
  Future<void> _fetchDepartments() async {
    final url = Uri.parse('http://$ip/kpi_itave/settings.php?section=buttons&action=getdepartments&filter');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _departments.clear(); 
          _departments = List<Map<String, dynamic>>.from(data);
        });

      } else {
        print("Failed to fetch departments: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching department data: $e");
    }
  }
  Future<void> _fetchQuestions() async {
    final url = Uri.parse('http://$ip/kpi_itave/settings.php?section=questions&action=getQuestions');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          List<dynamic> data = jsonDecode(response.body);

          setState(() {
            _questions.clear(); 
            _questions = List<Map<String, dynamic>>.from(data);
            _ratings = {for (var question in _questions) question['question_id']: 4.5};
          });

        } else {
          print("Failed to fetch questions: ${response.statusCode}");
        }
      } else {
        print("Failed to fetch questions: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching questions data: $e");
    }
  }

  Future<void> submitFeedback() async {
    if (_selectedDepartment == null) {
      _showDialog("Error", "Please select a department.");
      return;
    }
    final url = Uri.parse('http://$ip/kpi_itave/submit_feedback.php');

    String departmentId = _selectedDepartment != null
        ? _departments.firstWhere((dept) => dept['button_id'] == _selectedDepartment)['button_id'].toString()
        : "";

    List<Map<String, dynamic>> responses = _ratings.entries.map((entry) => {
          "question_id": entry.key,
          "rating": entry.value,
        }).toList();

    final body = {
      "customer_name": CustomerNameController.text.isNotEmpty ? CustomerNameController.text : "",
      "department_id": departmentId,
      "responses": jsonEncode(responses),
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          _showSuccessDialog("Success", "Feedback submitted! Customer ID: ${responseData['customer_id']}");
        } else {
          _showDialog("Error", "Failed to submit feedback: ${responseData['message']}");
        }
      } else {
        _showDialog("Error", "Server error: ${response.statusCode}");
      }
    } catch (e) {
      _showDialog("Error", "Error submitting feedback: $e");
    }
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage(title: 'Home Page')),
                );
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth * (screenWidth < 700?  1 : 0.8);
    double containerHeight = MediaQuery.of(context).size.height * 0.9;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(111, 5, 6, 1),
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage(title: 'Home Page')),
                );
              },
              icon: const Icon(LucideIcons.arrowLeftCircle, size: 30, color: Colors.white),
            ),
            SizedBox(width: 10),
            Text("Customer Feedback", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Center(
        child: Container(
          width: containerWidth,
          height: containerHeight,
          // color: Colors.red,
          padding: EdgeInsets.all(0),
          child: Column(
            children: [
              Expanded(
                child: _questions.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.alertCircle, size: 100),
                        SizedBox(height: 15),
                        Text("There is no Question Added"),
                      ],
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: screenWidth > 800 ? 2 : 1, 
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: _questions.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildCustomerNameCard();
                        } else {
                          return _buildQuestionCard(
                            context,
                            index, 
                            _questions[index - 1]['question'],
                          );
                        }
                      },
                    ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        submitFeedback();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text("Submit", style: GoogleFonts.poppins(fontSize: 18)),
                    ),
                  ],
                )
              ), 
    
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildCustomerNameCard() {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth < 600 ? 14 : 18;  
    double padding = screenWidth < 600 ? 12 : 15;  
    double inputHeight = screenWidth < 600 ? 45 : 50;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromARGB(91, 0, 0, 0)),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Customer Name",
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 5),
            Container(
              width: screenWidth * 0.8,  // Make the text field responsive
              height: inputHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.white,
              ),
              child: TextField(
                controller: CustomerNameController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  border: InputBorder.none,
                  hintText: "Enter Name...",
                  hintStyle: GoogleFonts.poppins(fontSize: fontSize, color: Colors.grey),
                ),
                style: GoogleFonts.poppins(fontSize: fontSize),
              ),
            ),
            SizedBox(height: 30),
            Text(
              "Department",
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 5),
            Container(
              width: screenWidth * 0.8, 
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedDepartment,
                  hint: Text(
                    "Select Department",
                    style: GoogleFonts.poppins(fontSize: fontSize, color: Colors.grey),
                  ),
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.black54),
                  items: _departments.map((dept) {
                    return DropdownMenuItem<int>(
                      value: dept['button_id'],
                      child: Text(dept['button_name'], style: GoogleFonts.poppins(fontSize: fontSize)),
                    );
                  }).toList(),
                  onChanged: (int? value) {
                    setState(() {
                      _selectedDepartment = value!;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildQuestionCard(BuildContext context, int index, String question) {
    var screenType = ResponsiveBreakpoints.of(context).breakpoint.name;
  
  double questionTitleFont = screenType == MOBILE ? 0.05 : 0.037 ;
  double questionFont = screenType == MOBILE ? 0.046 : 0.03 ; 
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        height: 350,
        width: double.infinity,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromARGB(91, 0, 0, 0)),
          borderRadius: BorderRadius.circular(15),
        ),
        child:GestureDetector(
          onTapDown: (TapDownDetails details) {
            setState(() {
              _ratings[index] = _ratings[index] == 5.0 ? 0.0 : _ratings[index]! + 0.5;
            });
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    color: Colors.white,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double screenWidth = constraints.maxWidth;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Question $index",
                                    style: GoogleFonts.poppins(
                                      fontSize: screenWidth * questionTitleFont,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.justify,
                                    softWrap: true,
                                  ),
                                  Container(width: 30, height: 2, color: Color.fromRGBO(111, 5, 6, 1)),
                                ]
                              ),
                              Text(
                                "${_ratings[index]}/5",
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * questionFont,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                double availableHeight = constraints.maxHeight; // Get dynamic height
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: availableHeight * 0.1),
                                    Column(
                                      children: [
                                        Container(
                                          width: screenWidth,
                                          child: Text(
                                            question,
                                            style: GoogleFonts.poppins(
                                              fontSize: screenWidth * questionFont,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                            softWrap: true,
                                          ),
                                        ),
                                        SizedBox(height: 10,),
                                        RatingBar(
                                          iconSize: availableHeight * 0.2,
                                          allowHalfRating: true,
                                          filledIcon: Icons.star,
                                          halfFilledIcon: Icons.star_half,
                                          emptyIcon: Icons.star_border,
                                          filledColor: Colors.amber,
                                          emptyColor: Colors.grey,
                                          currentRating: _ratings[index] ?? 3.0,
                                          onRatingChanged: (rating) {
                                            setState(() {
                                              _ratings[index] = rating;
                                            });
                                          },
                                        )
                                      ]
                                    ),
                                  ],
                                );
                              },
                            ),
                          )
                        ],
                      );
                    }
                  )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}