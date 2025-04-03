import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';

Future<void> downloadCSV(BuildContext context, String csvData) async {
  final bytes = utf8.encode(csvData);
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'visitor_data.csv')
    ..click();
  html.Url.revokeObjectUrl(url);
}
