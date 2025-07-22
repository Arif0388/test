import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageCompress {
  static Future<File> compressImage(File imageFile) async {
    const int maxImageSizeKB = 200; // Maximum target file size in kilobytes
    const int maxImageWidth = 1024; // Maximum image width
    const int maxImageHeight = 1024; // Maximum image height

    // Compress the image
    var result = await FlutterImageCompress.compressWithFile(
      imageFile.absolute.path,
      minWidth: maxImageWidth,
      minHeight: maxImageHeight,
      quality: 100,
      rotate: 0,
    );

    // Ensure the compressed image meets the size requirements
    int quality = 95;
    while (result!.length / 1024 > maxImageSizeKB && quality > 0) {
      result = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        minWidth: maxImageWidth,
        minHeight: maxImageHeight,
        quality: quality,
        rotate: 0,
      );
      quality -= 5;
    }

    // Save the compressed image to a file with the same name
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    String originalFileName = imageFile.uri.pathSegments.last;
    File compressedImageFile = File('$tempPath/$originalFileName');
    await compressedImageFile.writeAsBytes(result);

    return compressedImageFile;
  }
}
