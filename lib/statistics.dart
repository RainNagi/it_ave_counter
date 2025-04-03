// ignore_for_file: unused_import, avoid_print, unnecessary_import, deprecated_member_use, avoid_web_libraries_in_flutter, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'csv_download/csv_download_io.dart' if (dart.library.html) 'csv_download/csv_download_web.dart';
import 'package:csv/csv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cupertino_sidebar/cupertino_sidebar.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:file_saver/file_saver.dart';
import 'home/home.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
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
    fetchVisitors();
  }

  late List<Widget> _pages;
  int _selectedIndex = 0;
  
  final TextEditingController _startingDateController = TextEditingController();
  final TextEditingController _endingDateController = TextEditingController();

  List<dynamic> _visitors = [];
  List<dynamic> _departmentVisitors = [];
  Map<String, int> statistics = {};
  String selectedYear = DateTime.now().year.toString();
  // String selectedMonthValue = "01"; 
  // String selectedMonthName = "January"; 
  int selectedDepartment = 1; 
  double barWidth = 30; 
  int page = 1;

  // List<String> years = [];
  // List<Map<String, String>> months = [];
  Map<String, int> weekdayStatistics = {};
  List<Map<String, dynamic>> departments = [];
  final List<String> weekdaysOrder = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];

  Future<void> fetchStatistics() async {
    final url = Uri.parse('http://$ip/kpi_itave/statistics1.php');
    try {
      final response = await http.post(url,
        body: {
          'starting_date': _startingDateController.text,
          'ending_date': _endingDateController.text,
        }
      );

      if (response.statusCode == 200) {
        try {
          List<dynamic> data = jsonDecode(response.body);
          setState(() {
            statistics = {for (var item in data) item["button_id"].toString(): item["occurrences"]};
            page = 1;
          });
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
  
  int _getTotalVisitorCount() {
    return _departmentVisitors.fold(0, (sum, data) => sum + int.parse(data['counter_count'].toString()));
  }

  double _getAverageFeedback() {
    double totalFeedback = 0.0;
    int count = 0;

    for (var data in _departmentVisitors) {
      if (data['average_feedback'] != null) {
        totalFeedback += double.parse(data['average_feedback'].toString());
        count++;
      }
    }
    return count.round() > 0 ? totalFeedback / count : 0.0;
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
  Future<void> generateCSV(type) {
    List<List<String>> rows = [];
    if (type == "visitor_count") {
      rows.add(["Visitor", "Department Visit", "TimeStamp"]);
      _visitors.forEach((visitor) {
        rows.add([visitor['id'].toString(), visitor['button_name'], visitor['timestamp']]);
      });
      rows.add(["","Total Visitors: ",_getTotalVisitorCount().toString()]);
    } else if (type == "total_visitors") {
      rows.add(["Department ID", "Department", "Visitor Count", "Average Feedback"]); 
      _departmentVisitors.forEach((department) {
        rows.add([department['button_id'].toString(), department['button_name'], department['counter_count'].toString(), department['average_feedback']?.toString() ?? 'N/A']);
      });
      rows.add(["","Total Visitors: ",_getTotalVisitorCount().toString()]);
    }

    String csvData = const ListToCsvConverter().convert(rows);

    return downloadCSV(context, csvData);
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
        if (_startingDateController.text.isNotEmpty && _endingDateController.text.isNotEmpty){
          _getDepartmentVisitors();
          fetchStatistics();
          fetchWeekdayStatistics();
          fetchVisitors();
        } 
      });
    }
  }
  Future<void> fetchVisitors() async {
    final url = Uri.parse('http://$ip/kpi_itave/statistics.php?action=getVisitors');
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
          _visitors = List<Map<String, dynamic>>.from(data);
          _reportTable();
        });
      } else {
        print("Failed to fetch department: ${response.statusCode}");
      }
      
    } catch (e) {
      print("Error fetching department visitor data: $e");
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
    List<Widget> getPages() {
      return [
         _reportTable(),
         _visualReport()
      ];
    }
    _pages = getPages();
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
                    width: 530,
                    child: Text(
                      "Select Date: ",
                      style: GoogleFonts.poppins(
                        fontSize: 16, color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  SizedBox(height: 10,),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal:  16.0),
                    width: 1000,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 250,
                          child: TextField(
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
                            onChanged: (value) {
                              _getDepartmentVisitors();
                              fetchStatistics();
                              fetchWeekdayStatistics();
                              fetchVisitors();
                            },
                          ),
                        ),
                        SizedBox(width: 10,),
                        SizedBox(
                          width: 250,
                          child: TextField(
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
                            onChanged: (value) {
                              _getDepartmentVisitors();
                              fetchStatistics();
                              fetchWeekdayStatistics();
                              fetchVisitors();
                            },
                          ),
                        ),
                        // SizedBox(width: 10,),
                        // InkWell(
                        //   onTap: (){
                        //     _getDepartmentVisitors();
                        //     fetchStatistics();
                        //     fetchWeekdayStatistics();
                        //     fetchVisitors();
                        //   }, 
                        //   child: Container(
                        //     height: 40,
                        //     width: 40,
                        //     decoration: BoxDecoration(
                        //       border: Border.all(color: Colors.black),
                        //       borderRadius: BorderRadius.all(Radius.circular(8))
                        //     ),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: [
                        //         Icon(Icons.search)
                        //       ]
                        //     )
                        //   )
                        // ),
                      ],
                    )
                  ),
                  SizedBox(height: 20,),
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: SafeArea(
                          child: DefaultTabController(
                            length: 2,
                            child: Builder(
                              builder: (context) {
                                return CupertinoFloatingTabBar(
                                  isVibrant: true,
                                  onDestinationSelected: (value) {
                                      setState(() {
                                        _selectedIndex = value;
                                      });
                                  },
                                  tabs: const [
                                      CupertinoFloatingTab(child: Text('Reports')),
                                      CupertinoFloatingTab(child: Text('Visual Reports')),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 30,),
                  Center(
                    child: _pages.elementAt(_selectedIndex), 
                  ),
                ]
              ),
            ),
            
          ],
        ),
      ),
    );
  }
  Widget _reportTable() {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text( 
                  "Department Visitors", 
                  style: GoogleFonts.poppins(
                    fontSize: 16, color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                ElevatedButton(
                  onPressed: () {generateCSV("visitor_count");},
                  child: Text("Download CSV", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
          SizedBox(height: 20,),
          Container(
            width: double.infinity,
            height: 530,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: Colors.white
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                headingTextStyle: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                columns: [
                  DataColumn(label: MouseRegion(child: Text("Visitor ID")), headingRowAlignment: MainAxisAlignment.center),
                  DataColumn(label: Text("Department Visit"), headingRowAlignment: MainAxisAlignment.center),
                  DataColumn(label: Text("TimeStamp"), headingRowAlignment: MainAxisAlignment.center),
                ],

                rows: [
                  ..._visitors.skip((page-1)*30).take(30).map((data) {
                  return DataRow(cells: [
                    DataCell(Center(child: Text(data['id'].toString()))),
                    DataCell(Center(child: Text(data['button_name'].toString()))),
                    DataCell(Center(child: Text(data['timestamp'].toString()))),
                  ]);
                  }),

                  DataRow(cells: [
                    DataCell(Center(child: Text(""))), 
                    DataCell(Center(child: Text("Total Visitors", style: TextStyle(fontWeight: FontWeight.bold,)))), 
                    DataCell(Center(child: Text(_getTotalVisitorCount().toString(), style: TextStyle(fontWeight: FontWeight.bold,)))), 
                  ]),
                  DataRow(cells: [
                    DataCell(Center(child: page == 1? Text("") : ElevatedButton(onPressed: () {page -= 1;  fetchVisitors();}, child: Text("<")))),
                    DataCell(Center(child: Text("$page"))),  
                    DataCell(Center(child: _visitors.skip((page-1)*30).take(30).length < 30? Text("") : ElevatedButton(onPressed: () {page += 1;  fetchVisitors(); }, child: Text(">")))),  
                  ]),
                ]
              ),
            ),
          ),
          SizedBox(height: 30,),
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text( 
                  "Department Visitor Count", 
                  style: GoogleFonts.poppins(
                    fontSize: 16, color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                ElevatedButton(
                  onPressed: () {generateCSV("total_visitors");},
                  child: Text("Download CSV", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
          SizedBox(height: 20,),
          Container(
            width: double.infinity,
            height: 530,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: Colors.white
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                headingTextStyle: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                columns: [
                  DataColumn(label: Text("Department ID"), headingRowAlignment: MainAxisAlignment.center),
                  DataColumn(label: Text("Department"), headingRowAlignment: MainAxisAlignment.center),
                  DataColumn(label: Text("Visitor Count"), headingRowAlignment: MainAxisAlignment.center),
                  DataColumn(label: Text("Average Feedback"), headingRowAlignment: MainAxisAlignment.center),
                ],

                rows: [
                  ..._departmentVisitors.map((data) {
                  return DataRow(cells: [
                    DataCell(Center(child: Text(data['button_id'].toString()))),
                    DataCell(Center(child: Text(data['button_name'].toString()))),
                    DataCell(Center(child: Text(data['counter_count'].toString()))),
                    DataCell(Center(child: Text(data['average_feedback']?.toString() ?? 'N/A'))),
                  ]);
                  }).toList(),

                  DataRow(cells: [
                    DataCell(Center(child: Text(""))), 
                    DataCell(Center(child: Text("Totals", style: TextStyle(fontWeight: FontWeight.bold,)))), 
                    DataCell(Center(child: Text(_getTotalVisitorCount().toString(), style: TextStyle(fontWeight: FontWeight.bold,)))), 
                    DataCell(Center(child: Text(_getAverageFeedback().toString(), style: TextStyle(fontWeight: FontWeight.bold,)))),
                  ]),
                ]
              ),
            ),
          ),
          
        ]
      )
    );
    
  }

  Widget _visualReport(){
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth * 0.9;
    return Container(
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
              Text("Visitor Counts", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(width: 15),
            ],
          ),
          SizedBox(height: 15),
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
                            ? ((statistics.values.reduce((a, b) => a > b ? a : b) + 10) / 10).ceil() * 10
                            : 10)
                        .toDouble(),
                    barGroups: getBarChartData(),
                    titlesData: FlTitlesData(
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            int index = value.toInt();
                            if (index < 0 || index >= departments.length) return Container(); // Prevent out-of-range errors
                            return Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Transform.rotate(
                                angle: -0.3,
                                child: Text(
                                  departments[index]["button_name"], 
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                              ),
                            );
                          }
                        ),
                      ),
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
                              ? ((weekdayStatistics.values.reduce((a, b) => a > b ? a : b) + 10) / 10).ceil() * 10
                              : 10)
                          .toDouble(),
                      barGroups: getWeekdayBarChartData(),
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
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
    );

  }
}


class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), ''); 
    String formatted = "";

    if (digitsOnly.length > 4) {
      formatted = "${digitsOnly.substring(0, 4)}-";
      if (digitsOnly.length > 6) {
        formatted += "${digitsOnly.substring(4, 6)}-";
        formatted += digitsOnly.substring(6, digitsOnly.length.clamp(6, 8));
      } else {
        formatted += digitsOnly.substring(4, digitsOnly.length);
      }
    } else {
      formatted = digitsOnly;
    }

    // Remove trailing '-' if it exists
    if (formatted.endsWith('-')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}


