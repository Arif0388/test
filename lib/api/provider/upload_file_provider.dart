import 'dart:convert';
import 'dart:io'; // For web file handling
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:learningx_flutter_app/api/common/compress_image.dart';
import 'package:mime/mime.dart';
import 'package:learningx_flutter_app/api/model/uploaded_file_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart'; // For XFile, but only for web

class UploadFileProvider {
  static Future<List<UploadedFileModel>> uploadImage(
      String filename, List<File> selectedFiles, bool isImage) async {
    List<File> filesToUpload = [];

    for (int i = 0; i < selectedFiles.length; i++) {
      if (isImage && !kIsWeb) {
        // On mobile, compress the image
        var compressedImage =
            await ImageCompress.compressImage(selectedFiles[i]);
        filesToUpload.add(compressedImage);
      } else {
        // For web, handle files differently
        filesToUpload.add(selectedFiles[i]);
      }
    }

    final uri = Uri.parse('${dotenv.env['BASE_API_URL']}/imageUpload');
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

    if (filesToUpload.isEmpty) {
      throw Exception('File does not exist');
    }

    final imageUploadRequest = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = "Bearer $token";

    for (int i = 0; i < filesToUpload.length; i++) {
      if (kIsWeb) {
        // Handle file upload for the web
        XFile xFile = XFile(filesToUpload[i].path);
        final bytes = await xFile.readAsBytes();
        final multipartFile = http.MultipartFile.fromBytes(
          'imageFile',
          bytes,
          filename: filename,
          contentType: MediaType("file", filename.split(".")[1]),
        );
        imageUploadRequest.files.add(multipartFile);
      } else {
        final mimeTypeData = lookupMimeType(filesToUpload[i].path)?.split('/');

        if (mimeTypeData == null || mimeTypeData.length != 2) {
          throw Exception('Failed to get MIME type');
        }
        // Handle file upload for mobile
        final file = await http.MultipartFile.fromPath(
          'imageFile',
          filesToUpload[i].path,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        );
        imageUploadRequest.files.add(file);
      }
    }

    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        print(jsonResponse);
        return jsonResponse
            .map((data) => UploadedFileModel.fromJson(data))
            .toList();
      } else {
        throw Exception(
            'Failed to upload file. Status code: ${response.statusCode}, Response: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }
}
