// ignore_for_file: unused_import, avoid_print

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String ip = dotenv.get('IP_ADDRESS');

  @override
  void initState() {
    super.initState();
    // fetchYears();
    fetchWeekdayStatistics();
    _getDepartmentVisitors();
    _fetchDepartments();
    fetchStatistics();
  }
  
  final TextEditingController _startingDateController = TextEditingController();
  final TextEditingController _endingDateController = TextEditingController();

  List<dynamic> _departmentVisitors = [];
  Map<String, int> statistics = {};
  String selectedYear = DateTime.now().year.toString();
  // String selectedMonthValue = "01"; 
  // String selectedMonthName = "January"; 
  int selectedDepartment = 1; 
  double barWidth = 30; 

  // List<String> years = [];
  // List<Map<String, String>> months = [];
  Map<String, int> weekdayStatistics = {};
  List<Map<String, dynamic>> departments = [];
  final List<String> weekdaysOrder = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];


  // final List<String> monthNames = [
  //   "January", "February", "March", "April", "May", "June",
  //   "July", "August", "September", "October", "November", "December"
  // ];
  
  // Future<void> fetchYears() async {
    
  //   final url = Uri.parse('http://$ip/kpi_itave/statistics1.php?action=getYears');
  //   try {
  //     final response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       List<dynamic> data = jsonDecode(response.body);
  //       setState(() {
  //         years = List<String>.from(data);
  //         selectedYear = years.first; 
  //         fetchMonths(selectedYear);
  //       });
  //     }
  //   } catch (e) {
  //     print("Error fetching years: $e");
  //   }
  // }
  // Future<void> fetchMonths(String year) async {
  //   final url = Uri.parse('http://$ip/kpi_itave/statistics1.php?action=getMonths&year=$year');
  //   try {
  //     final response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       List<dynamic> data = jsonDecode(response.body);
  //       setState(() {
  //         months = data.map<Map<String, String>>((monthValue) => {
  //           "name": monthNames[int.parse(monthValue.toString()) - 1], 
  //           "value": monthValue.toString()
  //         }).toList();

  //         if (months.isNotEmpty) {
  //           selectedMonthValue = months.first["value"]!;
  //           selectedMonthName = months.first["name"]!;
  //           fetchStatistics();
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     print("Error fetching months: $e");
  //   }
  // }
  Future<void> fetchStatistics() async {
    final url = Uri.parse('http://$ip/kpi_itave/statistics1.php');
    try {
      print("Fetching statistics from: $url");
      print("Starting Date: ${_startingDateController.text}");
      print("Ending Date: ${_endingDateController.text}");

      final response = await http.post(url,
        body: {
          'starting_date': _startingDateController.text,
          'ending_date': _endingDateController.text,
        }
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          List<dynamic> data = jsonDecode(response.body);
          setState(() {
            statistics = {for (var item in data) item["button_id"].toString(): item["occurrences"]};

          });
          print("Statistics: $statistics");
        } catch (e) {
          print("Error decoding JSON: $e");
        }
      } else {
        print("Failed to fetch statistics: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching statistics: $e");
    }
  }


  Future<void> fetchWeekdayStatistics() async {
    final url = Uri.parse('http://$ip/kpi_itave/statistics1.php?action=getWeekdays&department=$selectedDepartment');

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
          weekdayStatistics = {for (var item in data) item["weekday"]: item["occurrences"]};
        });
      } else {
        print("Failed to fetch weekday statistics: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching weekday statistics: $e");
    }
  }

  
  Future<void> _selectDate(BuildContext context, controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _getDepartmentVisitors() async {
    final url = Uri.parse('http://$ip/kpi_itave/statistics.php?action=getDepartmentVisitors');
    try {
      final response = await http.post(
        url,
        body: {
          'starting_date': _startingDateController.text,
          'ending_date': _endingDateController.text,
        }
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _departmentVisitors = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print("Failed to archive department: ${response.statusCode}");
      }
      
    } catch (e) {
      print("Error fetching department visitor data: $e");
    }
  }
  Future<void> _fetchDepartments() async {
    final url = Uri.parse('http://$ip/kpi_itave/settings.php?section=buttons&action=getdepartments');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        setState(() {
          departments.clear(); 
          departments = List<Map<String, dynamic>>.from(data);
        });

      } else {
        print("Failed to fetch departments: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching department data: $e");
    }
  }
  List<BarChartGroupData> getWeekdayBarChartData() {
    List<BarChartGroupData> bars = [];
    int index = 0;
    for (var day in weekdaysOrder) {
      bars.add(
        BarChartGroupData(x: index, barRods: [
          BarChartRodData(
            toY: weekdayStatistics[day]?.toDouble() ?? 0,
            color: Colors.orange,
            width: barWidth,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.zero,
              bottomRight: Radius.zero,
            ),
          ),
        ]),
      );
      index++;
    }
    return bars;
  }
  List<BarChartGroupData> getBarChartData() {
    List<BarChartGroupData> bars = [];
    int index = 0;
    statistics.forEach((key, value) {
      bars.add(
        BarChartGroupData(x: index, barRods: [
          BarChartRodData(
            toY: value.toDouble(), 
            color: Colors.blue, 
            width: barWidth,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),  
              topRight: Radius.circular(10), 
              bottomLeft: Radius.zero, 
              bottomRight: Radius.zero, 
            ),
          ),
        ]),
      );
      index++;
    });
    return bars;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth * 0.9;
    return Scaffold(
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
            Text("Statistics", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal:  16.0),
                    width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Select Date: ",
                          style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.black54,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(height: 5,),
                        TextField(
                          controller: _startingDateController,
                          decoration: InputDecoration(
                            labelText: "Starting Date",
                            hintText: "YYYY-MM-DD",
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: () => _selectDate(context, _startingDateController), 
                              icon: Icon(Icons.calendar_month)
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10), 
                            FilteringTextInputFormatter.digitsOnly, 
                            DateInputFormatter(), 
                          ],
                        ),
                        SizedBox(height: 10,),
                        TextField(
                          controller: _endingDateController,
                          decoration: InputDecoration(
                            labelText: "Ending Date",
                            hintText: "YYYY-MM-DD",
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: () => _selectDate(context, _endingDateController), 
                              icon: Icon(Icons.calendar_month)
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10), 
                            FilteringTextInputFormatter.digitsOnly, 
                            DateInputFormatter(), 
                          ],
                        ),
                        SizedBox(height: 10,),
                        InkWell(
                          onTap: (){
                            _getDepartmentVisitors();
                            fetchStatistics();
                            fetchWeekdayStatistics();
                          }, 
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.all(Radius.circular(8))
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Search"),
                                SizedBox(width: 5,),
                                Icon(Icons.search)
                              ]
                            )
                          )
                        ),
                      ],
                    )
                  ),
                  SizedBox(height: 30,),
                  Center(
                    child: SizedBox(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            color: Colors.white
                          ),
                          columns: [
                            DataColumn(label: Text("Department ID")),
                            DataColumn(label: Text("Department")),
                            DataColumn(label: Text("Visitor Count")),
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
                  ),
                ]
              ),
            ),
            Container(
              width: containerWidth,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdowns Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Montly Statistics", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(width: 15),
                      // Flexible(
                      //   child: years.isEmpty ?
                      //   Text("Empty") :
                      //   DropdownButton<String>(
                      //     value: selectedYear,
                      //     onChanged: (String? newValue) {
                      //       if (newValue != null) {
                      //         setState(() {
                      //           selectedYear = newValue;
                      //           fetchMonths(selectedYear);
                      //         });
                      //       }
                      //     },
                      //     items: years.map((String year) {
                      //       return DropdownMenuItem(value: year, child: Text(year));
                      //     }).toList(),
                      //   ),
                      // ),
                      // Flexible(
                      //   child: months.isEmpty ?
                      //   Text("Empty") :
                      //   DropdownButton<String>(
                      //     value: selectedMonthValue,
                      //     onChanged: (String? newValue) {
                      //       if (newValue != null) {
                      //         setState(() {
                      //           selectedMonthValue = newValue;
                      //           selectedMonthName = months.firstWhere((month) => month["value"] == newValue)["name"]!;
                      //           fetchStatistics();
                      //         });
                      //       }
                      //     },
                      //     items: months.map((month) {
                      //       return DropdownMenuItem(value: month["value"], child: Text(month["name"]!));
                      //     }).toList(),
                      //   ),
                      // ),
                    ],
                  ),
                  SizedBox(height: 15),
                  
                  // First Chart
                  SizedBox(
                    height: 300,
                    child: statistics.isEmpty
                        ? Center(child: Text("No data available"))
                        : BarChart(
                          BarChartData(
                            gridData: FlGridData(
                              drawHorizontalLine: true,
                              drawVerticalLine: false  
                            ),
                            maxY: (statistics.values.isNotEmpty
                                    ? ((statistics.values.reduce((a, b) => a > b ? a : b) + 5) / 5).ceil() * 5
                                    : 10)
                                .toDouble(),
                            barGroups: getBarChartData(),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    return Padding(
                                      padding: EdgeInsets.only(top: 8), 
                                      child: Transform.rotate(
                                        angle: -0.3,
                                        child: Text(
                                          departments[value.toInt()]["button_name"], 
                                          style: GoogleFonts.poppins(fontSize: 12),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // leftTitles: AxisTitles(
                              //   sideTitles: SideTitles(
                              //     showTitles: true,
                              //     getTitlesWidget: (double value, TitleMeta meta) {
                              //       return value % 5 == 0
                              //           ? Text(value.toInt().toString(), style: GoogleFonts.poppins(fontSize: 12))
                              //           : Container();
                              //     },
                              //   ),
                              // ),
                            ),
                          ),
                        ),

                  ),

                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Weekday Statistics", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Flexible(
                        child:
                        departments.isEmpty ?
                        Text("Empty") :
                        DropdownButton<String>(
                          value: departments[selectedDepartment]["button_name"],
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedDepartment = departments.indexWhere((dept) => dept["button_name"] == newValue);
                                fetchWeekdayStatistics();
                              });
                            }
                          },
                          items: departments.map((dept) {
                            return DropdownMenuItem(
                              value: dept["button_name"].toString(),
                              child: Text(dept["button_name"].toString()),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    height: 300,
                    child: weekdayStatistics.isEmpty
                        ? Center(child: Text("No data available"))
                        : BarChart(
                            BarChartData(
                              gridData: FlGridData(
                                drawHorizontalLine: true,
                                drawVerticalLine: false  
                              ),
                              maxY: (weekdayStatistics.values.isNotEmpty
                                      ? ((weekdayStatistics.values.reduce((a, b) => a > b ? a : b) + 5) / 5).ceil() * 5
                                      : 10)
                                  .toDouble(),
                              barGroups: getWeekdayBarChartData(),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (double value, TitleMeta meta) {
                                      return Transform.rotate(
                                        angle: -0.4,
                                        child: Text(weekdaysOrder[value.toInt()], style: GoogleFonts.poppins(fontSize: 12)),
                                      );
                                    },
                                  ),
                                ),
                                
                              ),
                            ),
                          ),
                  ),
                ],
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
    if (digitsOnly.length > 3) {
      formatted += "${digitsOnly.substring(0, 4)}-";
      if (digitsOnly.length > 5) {
        formatted += "${digitsOnly.substring(4, 6)}-";
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

