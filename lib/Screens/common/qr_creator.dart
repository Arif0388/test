import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class QrCreator extends StatelessWidget {
  final String appBarText;
  final String sharedText;
  final String url;
  final String imageUrl;

  const QrCreator(
      {Key? key,
      required this.appBarText,
      required this.sharedText,
      required this.url,
      required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    GlobalKey qrKey = GlobalKey();

    // Function to capture QR code as image and share
    Future<void> shareQrCode() async {
      try {
        // Ensure the widget is fully rendered
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          RenderRepaintBoundary boundary =
              qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
          ui.Image image = await boundary.toImage(pixelRatio: 3.0);
          ByteData? byteData =
              await image.toByteData(format: ui.ImageByteFormat.png);
          Uint8List pngBytes = byteData!.buffer.asUint8List();

          // Save QR image to a temporary file
          final tempDir = await getTemporaryDirectory();
          final file = await File('${tempDir.path}/qr_code.png').create();
          await file.writeAsBytes(pngBytes);

          // Share the QR code image
          await Share.shareXFiles([XFile(file.path)],
              text: 'Hey there, Scan this QR code $sharedText');
        });
      } catch (e) {
        print(e);
      }
    }

    // Function to share the URL
    Future<void> shareLinkWithImage() async {
      try {
        // Download the image from the URL
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          // Get a temporary directory
          final directory = await getTemporaryDirectory();
          final imagePath = '${directory.path}/shared_image.png';

          // Save the image file locally
          final file = File(imagePath);
          await file.writeAsBytes(response.bodyBytes);

          // Share text with the image
          Share.shareXFiles(
            [XFile(imagePath)],
            text: "Hey there, you can use the link below $sharedText",
            subject: 'Check out this link!',
          );
        } else {
          print('Failed to download the image');
        }
      } catch (e) {
        print('Error sharing link with image: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarText),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Hey there, Scan this QR code $sharedText',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            RepaintBoundary(
              key: qrKey,
              child: QrImageView(
                data: url,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor:
                    Colors.white, // Set the QR code itself to black
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: shareQrCode,
              child: const Text('Share QR Code'),
            ),
            const SizedBox(height: 8),
            const Text("or"),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: shareLinkWithImage,
              child: const Text('Share Link'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
