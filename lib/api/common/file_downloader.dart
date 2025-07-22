import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

Future<void> downloadFile(
    BuildContext context, String fileUrl, String fileName) async {
  try {
    // Create an instance of Dio
    Dio dio = Dio();

    // Determine the appropriate directory based on the platform
    Directory? downloadDir;
    if (Platform.isAndroid) {
      downloadDir = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      downloadDir = await getApplicationDocumentsDirectory();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unsupported platform")),
      );
      return;
    }

    if (downloadDir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to get the storage directory.")),
      );
      return;
    }

    // Ensure that the path to the Downloads folder is used (specific to Android)
    String downloadsPath = Platform.isAndroid
        ? '${downloadDir.path}/Download/Learningx'
        : '${downloadDir.path}/Learningx';

    // Create the Learningx folder
    Directory learningXDir = Directory(downloadsPath);
    if (!learningXDir.existsSync()) {
      learningXDir.createSync(recursive: true);
    }

    // Create the output file path
    String outputFile = '${learningXDir.path}/$fileName';

    // Download the file
    await dio.download(fileUrl, outputFile);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("File downloaded to $outputFile")),
    );
  } catch (e) {
    print(e.toString());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: ${e.toString()}")),
    );
  }
}
