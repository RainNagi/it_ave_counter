import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  Map<String, int> statistics = {};
  String selectedYear = DateTime.now().year.toString();
  String selectedMonthValue = "01"; // Stores numeric month value
  String selectedMonthName = "January"; // Stores full month name
  double barWidth = 20; // Bar width (adjustable)

  // List of years for selection
  List<String> years = List.generate(10, (index) => (DateTime.now().year - index).toString());

  // List of months (display name & value)
  final List<Map<String, String>> months = [
    {"name": "January", "value": "01"},
    {"name": "February", "value": "02"},
    {"name": "March", "value": "03"},
    {"name": "April", "value": "04"},
    {"name": "May", "value": "05"},
    {"name": "June", "value": "06"},
    {"name": "July", "value": "07"},
    {"name": "August", "value": "08"},
    {"name": "September", "value": "09"},
    {"name": "October", "value": "10"},
    {"name": "November", "value": "11"},
    {"name": "December", "value": "12"},
  ];

  @override
  void initState() {
    super.initState();
    fetchStatistics();
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
          BarChartRodData(toY: value.toDouble(), color: Colors.blue, width: barWidth),
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
    double containerHeight = MediaQuery.of(context).size.height * 1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage(title: 'Home Page')),
                );
              },
              icon: Icon(LucideIcons.arrowLeft, size: 20, color: Colors.white),
            ),
            SizedBox(width: 10),
            Text("Statistics", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Center(
        child: Container(
          width: containerWidth,
          height: containerHeight,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Statistics",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: selectedYear,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedYear = newValue!;
                        fetchStatistics();
                      });
                    },
                    items: years.map<DropdownMenuItem<String>>((String year) {
                      return DropdownMenuItem<String>(
                        value: year,
                        child: Text(year),
                      );
                    }).toList(),
                  ),

                  DropdownButton<String>(
                    value: selectedMonthValue, 
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedMonthValue = newValue!;
                        selectedMonthName = months.firstWhere((month) => month["value"] == newValue)["name"]!;
                        fetchStatistics(); 
                      });
                    },
                    items: months.map<DropdownMenuItem<String>>((Map<String, String> month) {
                      return DropdownMenuItem<String>(
                        value: month["value"],
                        child: Text(month["name"]!), 
                      );
                    }).toList(),
                  ),
                ],
              ),

              SizedBox(height: 15),
              Expanded(
                child: statistics.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : BarChart(
                        BarChartData(
                          barGroups: getBarChartData(),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  return Transform.rotate(
                                    angle: 0,
                                    child: Text(statistics.keys.elementAt(value.toInt()), style: TextStyle(fontSize: 12)),
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
      ),
    );
  }
}
