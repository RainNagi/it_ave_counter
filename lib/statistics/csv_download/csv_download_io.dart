import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';

Future<void> downloadCSV(BuildContext context, String csvData, String type) async {
  if (await Permission.storage.request().isDenied) {
    _showDialog(context, "Storage Permission Denied", "Please allow storage access.");
    return;
  }

  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

  if (selectedDirectory == null) {
    _showDialog(context, "No Folder Selected", "Please select a folder to save the file.");
    return;
  }

  try {
    final intent = AndroidIntent(
      action: 'android.intent.action.CREATE_DOCUMENT',
      type: 'text/csv',
      arguments: {
        'android.intent.extra.TITLE': '$type.csv',
      },
    );

    await intent.launch();

    _showDialog(context, "Download Started", "Please select a folder to save the file.");
  } catch (e) {
    _showDialog(context, "Error Saving File", "An error occurred: $e");
  }
}

void _showDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
