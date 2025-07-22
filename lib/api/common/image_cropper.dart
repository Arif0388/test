import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageCropperPage {
  static Future<File?> cropImage(
      BuildContext context, File imgFile, double x, double y) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imgFile.path,
      aspectRatio: x != 0
          ? CropAspectRatio(ratioX: x, ratioY: y)
          : null, // Set the aspect ratio to 1:1
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Image Cropper",
          toolbarColor: const Color.fromARGB(255, 211, 232, 255),
          toolbarWidgetColor: Colors.black,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: x == 0 ? false : true,
        ),
        IOSUiSettings(
          title: "Image Cropper",
          aspectRatioLockEnabled: x == 0 ? false : true,
        ),
        WebUiSettings(
          context: context,
          size: const CropperSize(
            width: 270,
            height: 360,
          ),
        ),
      ],
    );
    if (croppedFile != null) {
      imageCache.clear();
      File imageFile = File(croppedFile.path);
      return imageFile;
    } else {
      return null;
    }
  }
}
