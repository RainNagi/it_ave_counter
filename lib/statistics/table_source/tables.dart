import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:data_table_2/data_table_2.dart';

    
    double _getAverageFeedback(List data,int department_id) {
      double totalFeedback = 0.0;
      int count = 0;

      for (var item in data) {
        if (item['average_feedback'] != null) {
          totalFeedback += double.tryParse(item['average_feedback'].toString()) ?? 0.0;
          count++;
        }
        if (item['department_id'] == department_id && item['department_id'] != 0) {
          totalFeedback += double.parse(item['average_feedback'].toString());
          count++;
        }
      }
      

      return count > 0 ? ((totalFeedback / count) * 100).round() / 100.0 : 0.0;
    }




class VisitorDataSource extends DataTableSource {
  final List<dynamic> data;
  final double font;

  VisitorDataSource(this.data, this.font);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      final totalVisitors = data.length;  
      return DataRow.byIndex(
        index: index,
        cells: [
          DataCell(Center(child: Text('', style: TextStyle(fontSize: font)))),
          DataCell(Center(child: Text('Total Visitors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: font)))),
          DataCell(Center(child: Text('$totalVisitors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: font)))),
        ],
      );
    }

    final row = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Center(child: Text(row['id'].toString(), style: TextStyle(fontSize: font)))),
        DataCell(Center(child: Text(row['button_name'].toString(), style: TextStyle(fontSize: font)))),
        DataCell(Center(child: Text(row['timestamp'].toString(), style: TextStyle(fontSize: font)))),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length + 1;
  @override
  int get selectedRowCount => 0;
}


class DepartmentVisitorDataSource extends DataTableSource {
  final List<dynamic> data;
  final double font;

  DepartmentVisitorDataSource(this.data, this.font);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      final totalVisitors = data.fold(0, (sum, data) => sum + int.parse(data['counter_count'].toString()));  
      return DataRow.byIndex(
        index: index,
        cells: [
          DataCell(Center(child: Text(""))), 
          DataCell(Center(child: Text("Totals", style: TextStyle(fontWeight: FontWeight.bold,fontSize: font)))), 
          DataCell(Center(child: Text('$totalVisitors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: font)))),
          DataCell(Center(child: Text(_getAverageFeedback(data, 0).toString() , style: TextStyle(fontWeight: FontWeight.bold,fontSize: font)))),
        ],
      );
    }

    final row = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Center(child: Text(row['button_id'].toString(), style: TextStyle(fontSize: font)))),
        DataCell(Center(child: Text(row['button_name'].toString(), style: TextStyle(fontSize: font)))),
        DataCell(Center(child: Text(row['counter_count'].toString(), style: TextStyle(fontSize: font)))),
        DataCell(Center(child: Text(row['average_feedback']?.toString() ?? 'N/A', style: TextStyle(fontSize: font)))),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length + 1;  

  @override
  int get selectedRowCount => 0;
}


class FeedbackDataSource extends DataTableSource {
  final List<dynamic> data;
  final double font;
  final int selectedDepartmentFeedback;
  final List<Map<String, dynamic>> departments;

  FeedbackDataSource(this.data, this.font, this.selectedDepartmentFeedback, this.departments);

  @override
  DataRow? getRow(int index) {
    final filtered = data.where((d) => d["department_id"] == departments[selectedDepartmentFeedback]["button_id"]).toList();

    if (index >= filtered.length) {
      final totalFeedbackCount = filtered.fold(0, (sum, item) => sum + int.parse(item['feedback_count'].toString()));
      return DataRow.byIndex(
        index: index,
        cells: [
          DataCell(Center(child: Text('', style: TextStyle(fontSize: font)))),
          DataCell(Center(child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: font)))),
          DataCell(Center(child: Text('$totalFeedbackCount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: font)))),
          DataCell(Center(child: Text(_getAverageFeedback(data, departments[selectedDepartmentFeedback]["button_id"]).toString() , style: TextStyle(fontWeight: FontWeight.bold,fontSize: font)))),
        ],
      );
    }

    final row = filtered[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Center(child: Text(row['button_name'].toString(), style: TextStyle(fontSize: font)))),
        DataCell(Center(child: Text("Question ${row['question_id']}", style: TextStyle(fontSize: font)))),
        DataCell(Center(child: Text(row['feedback_count'].toString(), style: TextStyle(fontSize: font)))),
        DataCell(Center(child: Text(row['average_feedback']?.toString() ?? 'N/A', style: TextStyle(fontSize: font)))),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.where((d) => d["department_id"] == departments[selectedDepartmentFeedback]["button_id"]).length + 1;  // Adding 1 for the totals row

  @override
  int get selectedRowCount => 0;
}
