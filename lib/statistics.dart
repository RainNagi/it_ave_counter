import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'home.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  void initState() {
    super.initState();
    fetchYears();
    fetchWeekdayStatistics();
  }

  Map<String, int> statistics = {};
  String selectedYear = DateTime.now().year.toString();
  String selectedMonthValue = "01"; 
  String selectedMonthName = "January"; 
  String selectedDepartment = "Admin"; 
  double barWidth = 30; 

  List<String> years = [];
  List<Map<String, String>> months = [];
  Map<String, int> weekdayStatistics = {};
  final List<String> departments = ["Admin", "Retail Inquiry", "Printing Avenue", "Technical"];
  final List<String> weekdaysOrder = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];


  final List<String> monthNames = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];
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

  Future<void> fetchYears() async {
    final url = Uri.parse('http://192.168.1.182/kpi_itave/statistics.php?action=getYears');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          years = List<String>.from(data);
          selectedYear = years.first; // Default to first available year
          fetchMonths(selectedYear);
        });
      }
    } catch (e) {
      print("Error fetching years: $e");
    }
  }

  Future<void> fetchMonths(String year) async {
    final url = Uri.parse('http://192.168.1.182/kpi_itave/statistics.php?action=getMonths&year=$year');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          months = data.map<Map<String, String>>((monthValue) => {
            "name": monthNames[int.parse(monthValue.toString()) - 1], 
            "value": monthValue.toString()
          }).toList();


          
          if (months.isNotEmpty) {
            selectedMonthValue = months.first["value"]!;
            selectedMonthName = months.first["name"]!;
            fetchStatistics();
          }
        });
      }
    } catch (e) {
      print("Error fetching months: $e");
    }
  }

  Future<void> fetchWeekdayStatistics() async {
    final url = Uri.parse('http://192.168.1.182/kpi_itave/statistics.php?action=getWeekdays&department=$selectedDepartment');
    try {
      final response = await http.get(url);
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



  Future<void> fetchStatistics() async {
    final url = Uri.parse('http://192.168.1.182/kpi_itave/statistics.php?year=$selectedYear&month=$selectedMonthValue');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          statistics = {for (var item in data) item["button_name"]: item["occurrences"]};
        });
      } else {
        print("Failed to fetch statistics: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching statistics: $e");
    }
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
    // double containerHeight = MediaQuery.of(context).size.height * 1;

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
      body: Center(
        child: SingleChildScrollView(
          child: Container(
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
                    Flexible(
                      child: DropdownButton<String>(
                        value: selectedYear,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedYear = newValue;
                              fetchMonths(selectedYear);
                            });
                          }
                        },
                        items: years.map((String year) {
                          return DropdownMenuItem(value: year, child: Text(year));
                        }).toList(),
                      ),
                    ),
                    Flexible(
                      child: DropdownButton<String>(
                        value: selectedMonthValue,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedMonthValue = newValue;
                              selectedMonthName = months.firstWhere((month) => month["value"] == newValue)["name"]!;
                              fetchStatistics();
                            });
                          }
                        },
                        items: months.map((month) {
                          return DropdownMenuItem(value: month["value"], child: Text(month["name"]!));
                        }).toList(),
                      ),
                    ),
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
                                      angle: -0.4,
                                      child: Text(
                                        statistics.keys.elementAt(value.toInt()), 
                                        style: GoogleFonts.poppins(fontSize: 12),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 5, // Ensure labels appear only at intervals of 5
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  return value % 5 == 0
                                      ? Text(value.toInt().toString(), style: GoogleFonts.poppins(fontSize: 12))
                                      : Container();
                                },
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
                      child: DropdownButton<String>(
                        value: selectedDepartment,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedDepartment = newValue;
                              fetchWeekdayStatistics();
                            });
                          }
                        },
                        items: departments.map((String department) {
                          return DropdownMenuItem(value: department, child: Text(department));
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
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 5, // Ensure labels appear only at intervals of 5
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    return value % 5 == 0
                                        ? Text(value.toInt().toString(), style: GoogleFonts.poppins(fontSize: 12))
                                        : Container();
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
        ),
      ),

    );
  }
}
