// ignore_for_file: unused_import, avoid_print, unnecessary_import, deprecated_member_use, avoid_web_libraries_in_flutter, prefer_interpolation_to_compose_strings

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_framework/responsive_framework.dart';
import 'csv_download/csv_download_io.dart' if (dart.library.html) 'csv_download/csv_download_web.dart';
import 'package:csv/csv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cupertino_sidebar/cupertino_sidebar.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:file_saver/file_saver.dart';
import '../home/home.dart';
import 'table_source/tables.dart';

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
    today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _dayDateController.text = today;
    fetchWeekdayStatistics();
    _getDepartmentVisitors();
    _fetchDepartments();
    fetchStatistics();
    fetchVisitors();
    fetchAverageFeedback();
  }

  late List<Widget> _pages;
  int _selectedIndex = 0;
  
  int selectedOption = 0;
  
  final TextEditingController _startingDateController = TextEditingController();
  final TextEditingController _endingDateController = TextEditingController();
  final TextEditingController _dayDateController = TextEditingController();
  final TextEditingController _weekStartController = TextEditingController();
  final TextEditingController _weekEndController = TextEditingController();
  

  List<dynamic> _visitors = [];
  List<dynamic> _departmentVisitors = [];
  List<dynamic> _feedbacks = [];
  final List<dynamic> tables = [
    {"table_id" : 1, "table_name" : "Department Visitors", "csv_title" : "visitor_data"},
    {"table_id" : 2, "table_name" : "Department Visitor Count", "csv_title" : "department_visitor_data"},
    {"table_id" : 3, "table_name" : "Average Feedback Per Department", "csv_title" : "department_average_feedback"}
  ];
  List<dynamic> statistics = [];

  String selectedYear = '';
  String selectedMonth = ''; 
  String selectedWeek = '1';
  String today = '';
  DateTime? weekStartDate;
  DateTime? weekEndDate;
  int selectedDepartment = 0; 
  int selectedDepartmentFeedback = 0;
  int selectedTable = 0;
  int rowsPerPage = 20;
  double barWidth = 12; 
  int page = 1;

  List<dynamic> years = [];
  List<Map<String, String>> months = [];
  Map<String, int> weekdayStatistics = {};
  List<Map<String, dynamic>> departments = [];
  final List<String> weekdaysOrder = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];

  String _getMonthName(String monthNumber) {
    const monthNames = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    int index = int.parse(monthNumber) - 1;
    return monthNames[index];
  }
  void reset() {
    years.clear();
    months.clear();
    selectedYear = '';
    selectedMonth = '';
    _startingDateController.clear();
    _endingDateController.clear();
    _dayDateController.clear();
    _weekStartController.clear();
    _weekEndController.clear();
  }
  void refresh() {
    fetchWeekdayStatistics();
    _getDepartmentVisitors();
    _fetchDepartments();
    fetchStatistics();
    fetchVisitors();
    fetchAverageFeedback();
    
  }

  Future<void> fetchStatistics() async {
    final url = Uri.parse('http://$ip/kpi_itave/statistics1.php');
    try {
      final response = await http.post(url,
        body: {
          'daily_date' : _dayDateController.text,
          'starting_date': _startingDateController.text,
          'ending_date': _endingDateController.text,
          'year': selectedYear,
          'month': selectedMonth,
          'week_start': _weekStartController.text,
          'week_end': _weekEndController.text
        }
      );
      if (response.statusCode == 200) {
        try {
          List<dynamic> data = jsonDecode(response.body);
          setState(() {
            statistics = data;
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

  double _getTotalAverageFeedback(int department_id) {
    double totalFeedback = 0.0;
    int count = 0;

    for (var data in _feedbacks) {
      if (data['department_id'] == department_id) {
        totalFeedback += double.parse(data['average_feedback'].toString());
        count++;
      }
    }
    return count.round() > 0 ? ((totalFeedback / count) * 100).round() / 100.0 : 0.0;
  }


  Future<void> fetchWeekdayStatistics() async {
    final buttonId = departments[selectedDepartment]["button_id"];
    final url = Uri.parse('http://$ip/kpi_itave/statistics1.php?action=getWeekdays&department=$buttonId');
    try {
      final response = await http.post(
        url,
        body: {
          'daily_date' : _dayDateController.text,
          'starting_date': _startingDateController.text,
          'ending_date': _endingDateController.text,
          'year': selectedYear,
          'month': selectedMonth,
          'week_start': _weekStartController.text,
          'week_end': _weekEndController.text
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
  void _createWeek() {
    int weekNum = int.parse(selectedWeek);
    int startDay = (weekNum - 1) * 7 + 1;
    int endDay = weekNum * 7;
    int maxDay = DateTime(int.parse(selectedYear), int.parse(selectedMonth) + 1, 0).day;
    if (endDay > maxDay) endDay = maxDay;
    DateTime startDate = DateTime(int.parse(selectedYear), int.parse(selectedMonth), startDay);
    DateTime endDate = DateTime(int.parse(selectedYear), int.parse(selectedMonth), endDay);
    _weekStartController.text = DateFormat('yyyy-MM-dd').format(startDate);
    _weekEndController.text = DateFormat('yyyy-MM-dd').format(endDate);
    return;
  }
  Future<void> _fetchYear() async {
    final url = Uri.parse('http://$ip/kpi_itave/statistics1.php?action=getYears');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          years = data;
          selectedYear = years.isNotEmpty ? years[0] : '';
        });
      } else {
        print("Failed to fetch years: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching years: $e");
    }
    return;
  }
  Future<void> _fetchMonth() async {
    final url = Uri.parse('http://$ip/kpi_itave/statistics1.php?action=getMonths&year=$selectedYear');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          months = data.map<Map<String, String>>((m) {
            return {
              "value": m.toString(),
              "label": _getMonthName(m.toString()),
            };
          }).toList();
        });
        if (months.isNotEmpty) {
          selectedMonth = months[0]['value']!;
          refresh();
        }
        fetchVisitors();
      } else {
        print("Failed to fetch Months: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching Months: $e");
    }
  }
  

  Future<void> generateCSV(BuildContext context, String type) {
    List<List<String>> rows = [];
    if (type == "visitor_data") {
      rows.add(["Visitor", "Department Visit", "TimeStamp"]);
      for (var visitor in _visitors) {
        rows.add([visitor['id'].toString(), visitor['button_name'], visitor['timestamp']]);
      }
      rows.add(["","Total Visitors: ",_getTotalVisitorCount().toString()]);
    } else if (type == "department_visitor_data") {
      rows.add(["Department ID", "Department", "Visitor Count", "Average Feedback"]); 
      for (var department in _departmentVisitors) {
        rows.add([department['button_id'].toString(), department['button_name'], department['counter_count'].toString(), department['average_feedback']?.toString() ?? 'N/A']);
      }
      rows.add(["","Total Visitors: ",_getTotalVisitorCount().toString()]);
    } else if (type == "department_average_feedback"){
      rows.add(["Question ID", "Department", "Number of Feedback", "Average Feedback"]);
      for (var feedback in _feedbacks) {
        rows.add(["Question "+feedback['question_id'].toString(), feedback['button_name'], feedback['feedback_count'].toString(), feedback['average_feedback']?.toString() ?? 'N/A']);
        if (feedback["question_id"] == 8){
          rows.add(["","","Total Average: ",_getTotalAverageFeedback(feedback["department_id"]).toString()]);
          rows.add(["","","",""]);
        }
      }
    }

    String csvData = const ListToCsvConverter().convert(rows);

    return downloadCSV(context, csvData, type);
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
        if (controller == _weekStartController) {
          weekStartDate = picked;
          weekEndDate = picked.add(Duration(days: 6));

          _weekEndController.text = DateFormat('yyyy-MM-dd').format(weekEndDate!);
        }

        refresh();
      });
    }
  }
  Future<void> fetchVisitors() async {
    final url = Uri.parse('http://$ip/kpi_itave/statistics.php?action=getVisitors');
    try {
      final response = await http.post(
        url,
        body: {
          'daily_date' : _dayDateController.text,
          'starting_date': _startingDateController.text,
          'ending_date': _endingDateController.text,
          'year': selectedYear,
          'month': selectedMonth,
          'week_start': _weekStartController.text,
          'week_end': _weekEndController.text
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

  Future<void> fetchAverageFeedback() async {
    final url = Uri.parse('http://$ip/kpi_itave/statistics.php?action=getAverageFeedback');
    try {
      final response = await http.post(
        url,
        body: {
          'daily_date' : _dayDateController.text,
          'starting_date': _startingDateController.text,
          'ending_date': _endingDateController.text,
          'year': selectedYear,
          'month': selectedMonth,
          'week_start': _weekStartController.text,
          'week_end': _weekEndController.text
        }
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _feedbacks = List<Map<String, dynamic>>.from(data);
          _reportTable();
        });
      } else {
        print("Failed to fetch average feedback: ${response.statusCode}");
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
          'daily_date' : _dayDateController.text,
          'starting_date': _startingDateController.text,
          'ending_date': _endingDateController.text,
          'year': selectedYear,
          'month': selectedMonth,
          'week_start': _weekStartController.text,
          'week_end': _weekEndController.text
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
    for (int i = 0; i < statistics.length; i++) {
      final item = statistics[i];
      final double value = (item['occurrences'] as num).toDouble();
      
      bars.add(
        BarChartGroupData(x: i, barRods: [
          BarChartRodData(
            toY: value,
            color: Colors.blue,
            width: barWidth,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
        ]),
      );
    }
    return bars;
  }

  @override
  Widget build(BuildContext context) {
    var screenType = ResponsiveBreakpoints.of(context).breakpoint.name;
    double buttonFont = screenType == MOBILE ? 10 : 16;
    double textFieldSize = screenType == MOBILE ? 35 : 50;
    double font = screenType == MOBILE ? 10 : 16;
    double radioSize = screenType == MOBILE ? 16 : 24;
    List<Widget> getPages() {
      fetchWeekdayStatistics(); 
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: Colors.grey[50],
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          _buildRadioTile('Daily', 1, font, radioSize),
                          _buildRadioTile('Weekly', 2, font, radioSize),
                          _buildRadioTile('Monthly', 3, font, radioSize),
                          _buildRadioTile('Yearly', 4, font, radioSize),
                          _buildRadioTile('Custom', 5, font, radioSize),
                          selectedOption != 0 ?
                          ElevatedButton(
                            onPressed: () {
                              setState (() {
                                selectedOption = 0;
                                reset();
                                refresh();
                              });
                            }, 
                            child: Text(
                                "Clear",
                                style: GoogleFonts.poppins(
                                  fontSize: buttonFont, color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.start,
                              ),
                          ) : SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  selectedOption == 1 ? 
                    Container(
                      width: 350,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal:  16.0),
                            width: 530,
                            child: Text(
                              "Select Date: ",
                              style: GoogleFonts.poppins(
                                fontSize: buttonFont, color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          SizedBox(height: 10,),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal:  16.0),
                            width: double.infinity,
                            child: SizedBox(
                              width: 250,
                              height: textFieldSize,
                              child: TextField(
                                style: GoogleFonts.poppins(fontSize: buttonFont),
                                controller: _dayDateController,
                                decoration: InputDecoration(
                                  labelText: "Date",
                                  labelStyle: TextStyle(color: Colors.grey, fontSize:  buttonFont),
                                  hintText: "YYYY-MM-DD",
                                  border: OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    onPressed: () => _selectDate(context, _dayDateController), 
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
                                  reset();
                                  refresh();
                                },
                              ),
                            ),
                          ),
                        ]
                      ),
                    ) : SizedBox.shrink(),
                  selectedOption == 2 ? 
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          DropdownButton<String>(
                            value: selectedWeek,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedWeek = newValue;
                                  _createWeek();
                                  refresh();
                                });
                              }
                            },
                            items: List.generate(selectedMonth == "02" ? 4 : 5, (index) {
                              int weekNumber = index + 1;
                              String suffix;
                              if (weekNumber == 1) suffix = 'st';
                              else if (weekNumber == 2) suffix = 'nd';
                              else if (weekNumber == 3) suffix = 'rd';
                              else suffix = 'th';

                              return DropdownMenuItem<String>(
                                value: "$weekNumber",
                                child: Text(
                                  "$weekNumber$suffix Week",
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }),
                          ),
                          SizedBox(width: 20), 
                          DropdownButton<String>(
                            value: selectedMonth,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedMonth = newValue;
                                  selectedWeek = "1";
                                  rowsPerPage = 20;
                                  _createWeek();
                                  refresh();
                                });
                              }
                            },
                            items: months.isEmpty
                              ? [
                                  DropdownMenuItem<String>(
                                    value: '',
                                    child: Text("None"),
                                  )
                                ]
                              : months.map((month) {
                                  return DropdownMenuItem<String>(
                                    value: month['value'],
                                    child: Text(
                                      month['label'] ?? '',
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      softWrap: true,
                                    ),
                                  );
                                }).toList(),
                          ),
                          SizedBox(width: 20), 
                          DropdownButton<String>(
                            value: selectedYear,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() async{
                                  selectedYear = newValue;
                                  await _fetchMonth();
                                  refresh();
                                });
                              }
                            },
                            items: years.isEmpty
                              ? [
                                  DropdownMenuItem<String>(
                                    value: '',
                                    child: Text("None"),
                                  )
                                ]
                              : years.map((year) {
                                return DropdownMenuItem(
                                  value: year.toString(),
                                  child: Text(
                                    year.toString(),
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    softWrap: true,
                                  ),
                                );
                              }).toList(),
                          ),
                        ],
                      ),
                    ):SizedBox.shrink(),
                  selectedOption == 3 ? 
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          DropdownButton<String>(
                            value: selectedMonth,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  selectedMonth = newValue;
                                  rowsPerPage = 20;
                                  refresh();
                                });
                              }
                            },
                            items: months.isEmpty
                              ? [
                                  DropdownMenuItem<String>(
                                    value: '',
                                    child: Text("None"),
                                  )
                                ]
                              : months.map((month) {
                                  return DropdownMenuItem<String>(
                                    value: month['value'],
                                    child: Text(
                                      month['label'] ?? '',
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      softWrap: true,
                                    ),
                                  );
                                }).toList(),
                          ),
                          SizedBox(width: 20), 
                          DropdownButton<String>(
                            value: selectedYear,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() async{
                                  selectedYear = newValue;
                                  await _fetchMonth();
                                  refresh();
                                });
                              }
                            },
                            items: years.isEmpty
                              ? [
                                  DropdownMenuItem<String>(
                                    value: '',
                                    child: Text("None"),
                                  )
                                ]
                              : years.map((year) {
                                return DropdownMenuItem(
                                  value: year.toString(),
                                  child: Text(
                                    year.toString(),
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    softWrap: true,
                                  ),
                                );
                              }).toList(),
                          ),
                        ],
                      ),
                    ):SizedBox.shrink(),
                  selectedOption == 4 ? 
                    Container(
                      child: DropdownButton<String>(
                        value: selectedYear,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedYear = newValue;
                              rowsPerPage = 20; 
                              refresh();
                            });
                          }
                        },
                        items: years.isEmpty
                              ? [
                                  DropdownMenuItem<String>(
                                    value: '',
                                    child: Text("None"),
                                  )
                                ]
                              : years.map((year) {
                          return DropdownMenuItem(
                            value: year.toString(),
                            child: Text(year.toString(), style: GoogleFonts.poppins(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),softWrap: true,),
                          );
                        }).toList(),
                      ),
                    ):SizedBox.shrink(),
                  selectedOption == 5 ? 
                    Container(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal:  16.0),
                            width: 530,
                            child: Text(
                              "Select Date: ",
                              style: GoogleFonts.poppins(
                                fontSize: buttonFont, color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                          SizedBox(height: 10,),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal:  16.0),
                            width: double.infinity,
                            child: ResponsiveRowColumn(
                              rowMainAxisAlignment: MainAxisAlignment.center,
                              rowCrossAxisAlignment: CrossAxisAlignment.center,
                              columnMainAxisAlignment: MainAxisAlignment.center,
                              columnCrossAxisAlignment: CrossAxisAlignment.center,
                              layout: ResponsiveBreakpoints.of(context).smallerThan(TABLET)
                                ? ResponsiveRowColumnType.COLUMN
                                : ResponsiveRowColumnType.ROW,
                              children: [
                                ResponsiveRowColumnItem(
                                  child: SizedBox(
                                    width: 250,
                                    height: textFieldSize,
                                    child: TextField(
                                      style: GoogleFonts.poppins(fontSize: buttonFont),
                                      controller: _startingDateController,
                                      decoration: InputDecoration(
                                        labelText: "Starting Date",
                                        labelStyle: TextStyle(color: Colors.grey, fontSize:  buttonFont),
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
                                        reset();
                                        _getDepartmentVisitors();
                                        fetchStatistics();
                                        fetchWeekdayStatistics();
                                        fetchVisitors();
                                      },
                                    ),
                                  ),
                                ),
                                ResponsiveRowColumnItem(
                                  child: SizedBox(width: 10, height: 10,),
                                ),
                                ResponsiveRowColumnItem(
                                  child: SizedBox(
                                    width: 250,
                                    height: textFieldSize,
                                    child: TextField(
                                      style: GoogleFonts.poppins(fontSize: buttonFont),
                                      controller: _endingDateController,
                                      decoration: InputDecoration(
                                        labelText: "Ending Date",
                                        labelStyle: TextStyle(color: Colors.grey, fontSize:  buttonFont),
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
                                        reset();
                                        _getDepartmentVisitors();
                                        fetchStatistics();
                                        fetchWeekdayStatistics();
                                        fetchVisitors();
                                      },
                                    ),
                                  ),
                                )
                              ],
                            )
                          ),
                        ]
                      ),
                    ) :
                    SizedBox.shrink(),
                    
                  SizedBox(height: 10,),
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
                                  tabs: [
                                      CupertinoFloatingTab(child: Text('Reports', style: GoogleFonts.poppins(color: Colors.black, fontSize: buttonFont, fontWeight: FontWeight.bold),softWrap: true,)),
                                      CupertinoFloatingTab(child: Text('Visual Reports', style: GoogleFonts.poppins(color: Colors.black, fontSize: buttonFont, fontWeight: FontWeight.bold),softWrap: true,)),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10,),
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
    debugPrint = (String? message, {int? wrapWidth}) {};
    var screenType = ResponsiveBreakpoints.of(context).breakpoint.name;
    double font = screenType == MOBILE? 7: 16;
    return SizedBox(
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<String>(
                      value: tables[selectedTable]["table_name"],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedTable = tables.indexWhere((table) => table["table_name"] == newValue);
                            rowsPerPage = 20; 
                            _reportTable();
                          });
                        }
                      },
                      items: tables.map((table) {
                        return DropdownMenuItem(
                          value: table["table_name"].toString(),
                          child: Text(table["table_name"].toString(), style: GoogleFonts.poppins(color: Colors.black, fontSize: font, fontWeight: FontWeight.bold),softWrap: true,),
                        );
                      }).toList(),
                    ),
                    selectedTable == 2 ?
                      departments.isEmpty ?
                      Text("Empty") :
                      DropdownButton<String>(
                        value: departments[selectedDepartmentFeedback]["button_name"],
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedDepartmentFeedback = departments.indexWhere((dept) => dept["button_name"] == newValue);
                              // fetchWeekdayStatistics();
                            });
                          }
                        },
                        items: departments.map((dept) {
                          return DropdownMenuItem(
                            value: dept["button_name"].toString(),
                            child: Text(dept["button_name"].toString(), style: GoogleFonts.poppins(color: Colors.black, fontSize: font, fontWeight: FontWeight.bold),softWrap: true,),
                          );
                        }).toList(),
                      ): SizedBox.shrink(),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {generateCSV(context, tables[selectedTable]["csv_title"]);},
                  child: Text("Download CSV", style: TextStyle(fontSize: font)),
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
            child: PaginatedDataTable2(
              key: ValueKey('$selectedTable-$selectedOption'),
              headingTextStyle: GoogleFonts.poppins(
                textStyle: TextStyle(
                  fontSize: font,
                  fontWeight: FontWeight.bold,
                ),
              ),
              rowsPerPage: rowsPerPage,
              availableRowsPerPage: const [5, 10, 15, 20],
              showFirstLastButtons: true,
              onRowsPerPageChanged: (value) {
                setState(() {
                  rowsPerPage = value!;
                });
              },
              columns: selectedTable == 0  ? [
                DataColumn2(label: MouseRegion(child: Text("Visitor ID", style: GoogleFonts.poppins(color: Colors.black),)), headingRowAlignment: MainAxisAlignment.center),
                DataColumn2(label: Text("Department Visit", style: GoogleFonts.poppins(color: Colors.black),), headingRowAlignment: MainAxisAlignment.center),
                DataColumn2(label: Text("TimeStamp", style: GoogleFonts.poppins(color: Colors.black),), headingRowAlignment: MainAxisAlignment.center),
              ] : selectedTable == 1 ? [
                DataColumn2(label: Text("Department ID", style: GoogleFonts.poppins(color: Colors.black),), headingRowAlignment: MainAxisAlignment.center),
                DataColumn2(label: Text("Department", style: GoogleFonts.poppins(color: Colors.black),), headingRowAlignment: MainAxisAlignment.center),
                DataColumn2(label: Text("Visitor Count", style: GoogleFonts.poppins(color: Colors.black),), headingRowAlignment: MainAxisAlignment.center),
                DataColumn2(label: Text("Feedback Count", style: GoogleFonts.poppins(color: Colors.black),), headingRowAlignment: MainAxisAlignment.center),
              ] : selectedTable == 2 ? [
                DataColumn2(label: Text("Button Name", style: GoogleFonts.poppins(color: Colors.black),), headingRowAlignment: MainAxisAlignment.center),
                DataColumn2(label: Text("Question ID", style: GoogleFonts.poppins(color: Colors.black),), headingRowAlignment: MainAxisAlignment.center),
                DataColumn2(label: Text("Visitor Count", style: GoogleFonts.poppins(color: Colors.black),), headingRowAlignment: MainAxisAlignment.center),
                DataColumn2(label: Text("Average Feedback", style: GoogleFonts.poppins(color: Colors.black),), headingRowAlignment: MainAxisAlignment.center),
              ] : [],
              source: selectedTable == 0
                ? VisitorDataSource(_visitors, font)
                : selectedTable == 1
                    ? DepartmentVisitorDataSource(_departmentVisitors, font)
                    : FeedbackDataSource(_feedbacks, font, selectedDepartmentFeedback, departments),
              
            ),

          ),
        ]
      )
    );
    
  }

  Widget _visualReport(){
    var screenType = ResponsiveBreakpoints.of(context).breakpoint.name;
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth * 0.9;
    double titleFont = screenType == MOBILE? 12: 22;
    double font = screenType == MOBILE? 8: 12;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("Visitor Counts", style: GoogleFonts.poppins(fontSize: titleFont, fontWeight: FontWeight.bold)),
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
                    maxY: statistics.isNotEmpty
                      ? (((statistics.map((e) => e["occurrences"] as int).reduce((a, b) => a > b ? a : b) + 10) / 10).ceil() * 10).toDouble()
                      : 10.0,                    
                    barGroups: getBarChartData(),
                    titlesData: FlTitlesData(
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false,reservedSize: font)
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            int index = value.toInt();
                            if (index < 0 || index >= departments.length) return Container(); 
                            return Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Transform.rotate(
                                angle: -0.3,
                                child: Text(
                                  departments.firstWhere(
                                    (d) => d['button_id'].toString() == statistics[index]['button_id'].toString(),
                                    orElse: () => {"button_name": "Unknown"},
                                  )['button_name'],
                                  style: GoogleFonts.poppins(fontSize: font),
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
              Text("Weekday Statistics", style: GoogleFonts.poppins(fontSize: titleFont, fontWeight: FontWeight.bold)),
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
                        child: Text(dept["button_name"].toString(), style: GoogleFonts.poppins(color: Colors.black, fontSize: font, fontWeight: FontWeight.bold),softWrap: true,),
                      );
                    }).toList(),
                  )
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
                      sideTitles: SideTitles(showTitles: false,reservedSize: font),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false,reservedSize: font)
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Transform.rotate(
                            angle: -0.4,
                            child: Text(weekdaysOrder[value.toInt()], style: GoogleFonts.poppins(fontSize:font)),
                          );
                        },
                      ),
                    ),
                    
                  ),
                ),
              ),
          ),
          // Text("Weekday Statistics", style: GoogleFonts.poppins(fontSize: titleFont, fontWeight: FontWeight.bold)),

        ],
      ),
    );
  }
  Widget _buildRadioTile(String label, int value, font, radioSize) {
    return InkWell(
      onTap: () { 
        setState(() async{
          selectedOption = value;
          reset();
          if (value == 1) {
            today = DateFormat('yyyy-MM-dd').format(DateTime.now());
            _dayDateController.text = today;
          } else if (value == 2) {
            await _fetchYear();
            await _fetchMonth(); 
            _createWeek();
            refresh();   
          } else if (value == 3) {
            await _fetchYear();
            await _fetchMonth();
          } else if (value == 4) {
            await _fetchYear();
          }                
          refresh();
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Transform.scale(
            scale: radioSize / 24,
            child: Radio(
              value: value,
              groupValue: selectedOption,
              onChanged: (val) {
                setState(() async{
                  selectedOption = val!;
                  reset();
                  if (value == 1) {
                    today = DateFormat('yyyy-MM-dd').format(DateTime.now());
                    _dayDateController.text = today;
                  } else if (value == 2) {
                    await _fetchYear();
                    await _fetchMonth();
                    _createWeek();

                    refresh();                   
                  } else if (value == 3) {
                    await _fetchYear();
                    await _fetchMonth();
                  } else if (value == 4) {
                    await _fetchYear();
                  }                
                  refresh();
                });
              },
            ),
          ),
          Text(label, style: TextStyle(fontSize: font, color: Colors.black87)),
        ],
      )
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

    if (formatted.endsWith('-')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}


