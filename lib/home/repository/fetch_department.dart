// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:async';

String ip = dotenv.get('IP_ADDRESS');

Future<List<Map<String, dynamic>>> fetchDepartments() async {
  final url = Uri.parse('http://$ip/kpi_itave/settings.php?section=buttons&action=getdepartments');
  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      print("Failed to fetch departments: ${response.statusCode}");
      return [];
    }
  } catch (e) {
    print("Error fetching department data: $e");
    return [];
  }
}

  // Future<void> _fetchDepartments() async {
  //   final url = Uri.parse('http://$ip/kpi_itave/settings.php?section=buttons&action=getdepartments');
  //   try {
  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       List<dynamic> data = jsonDecode(response.body);

  //       setState(() {
  //         _departments.clear(); 
  //         _departments = List<Map<String, dynamic>>.from(data);
  //       });
  //       isButtonDisabled = {
  //         for (var department in _departments)
  //           department["button_name"] as String: false
  //       };

  //     } else {
  //       print("Failed to fetch departments: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("Error fetching department data: $e");
  //   }
  // }
  
