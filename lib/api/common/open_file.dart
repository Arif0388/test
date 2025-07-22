import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<void> openFile(
    String fileUrl, void Function(double progress) onProgress) async {
  try {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String savePath = join(appDocDir.path, basename(fileUrl));

    if (File(savePath).existsSync()) {
      var result = await OpenFilex.open(savePath);
      if (result.type != ResultType.done) {
        print("Error opening file: ${result.message}");
      }
      return;
    }

    Dio dio = Dio();
    await dio.download(fileUrl, savePath, onReceiveProgress: (received, total) {
      if (total != -1) {
        onProgress((received / total) * 100);
      }
    });

    var result = await OpenFilex.open(savePath);
    if (result.type != ResultType.done) {
      print("Error opening file: ${result.message}");
    }
  } catch (e) {
    print("File download/open error: $e");
  }
}
