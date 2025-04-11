
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../authentication/login.dart';
import '../../statistics/statistics.dart';
import '../../settings/settings.dart';
import '../../feedback/feedback.dart';

void logout(context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
  );
}

void goToStatistics(context){
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => StatisticsPage())
  );
}
void goToCustomerFeedBack(context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => CustomerFeedback())
  );
}
void goToSettings(context){
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => SettingsPage())
  );
}