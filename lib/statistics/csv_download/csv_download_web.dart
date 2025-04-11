// ignore_for_file: unused_local_variable, deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';

Future<void> downloadCSV(BuildContext context, String csvData, String type) async {
  final bytes = utf8.encode(csvData);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', '$type.csv')
    ..click();
  html.Url.revokeObjectUrl(url);
}
