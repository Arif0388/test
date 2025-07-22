import 'dart:collection';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/api/common/confirm_popup.dart';
import 'package:universal_html/html.dart' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/Screens/common/report_form.dart';
import 'package:learningx_flutter_app/api/common/file_downloader.dart';
import 'package:learningx_flutter_app/api/common/full_image_page.dart';
import 'package:learningx_flutter_app/api/common/launch_url.dart';
import 'package:learningx_flutter_app/api/common/open_file.dart';
import 'package:learningx_flutter_app/api/common/video_player_page.dart';
import 'package:learningx_flutter_app/api/model/files_model.dart';
import 'package:learningx_flutter_app/api/provider/files_provider.dart';

class BottomSheetFileItem {
  void showBottomSheet(BuildContext context, Files file, bool isAdmin,
      void Function(String) onDeleteFile) {
    bool isMounted = true; // Track if the bottom sheet is still visible

    Future<void> deleteFile() async {
      Map<String, dynamic> map = HashMap();
      map['channel'] = file.channel;
      map['id'] = file.id;
      await deleteFileApi(context, map);
      onDeleteFile(file.id);
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            bool isDownloading = false;

            Future<void> handleDownload() async {
              if (!isMounted) return; // Ensure widget is still active
              setState(() {
                isDownloading = true;
              });

              await openFile(file.filesLink, (_) {
                // Do nothing as progress isn't tracked
              });

              if (!isMounted) return;
              setState(() {
                isDownloading = false;
              });
            }

            void openWebFile() {
              // ignore: unused_local_variable
              html.AnchorElement anchorElement =
                  html.AnchorElement(href: file.filesLink)
                    ..setAttribute('download', '')
                    ..click();
            }

            // ignore: deprecated_member_use
            return WillPopScope(
              onWillPop: () async {
                isMounted = false; // Mark as unmounted when dismissed
                return true;
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                        child: Container(
                            width: 60,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: Color(0x51000000),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))))),
                    const SizedBox(height: 12),
                    Visibility(
                        visible: file.filetype != "link",
                        child: ListTile(
                          leading: const Icon(Icons.remove_red_eye_outlined),
                          title: const Text('View file'),
                          onTap: () async {
                            Navigator.pop(context);
                            if (file.filetype == "video") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VideoPlayerPage(
                                          url: file.filesLink,
                                        )),
                              );
                            }
                            if (file.filetype == "image") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FullImagePage(
                                        url: file.filesLink,
                                        displayName: file.user.displayName)),
                              );
                            }
                            if (file.filetype == "file") {
                              if (kIsWeb) {
                                openWebFile();
                              } else {
                                if (!isDownloading) {
                                  await handleDownload();
                                }
                              }
                            }
                          },
                        )),
                    Visibility(
                        visible: file.filetype != "link",
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('View profile'),
                          onTap: () async {
                            Navigator.pop(context);
                            context.push("/profile/${file.user.id}");
                          },
                        )),
                    Visibility(
                        visible: false,
                        child: ListTile(
                          leading: const Icon(Icons.download_outlined),
                          title: const Text('Download file'),
                          onTap: () async {
                            downloadFile(
                                context, file.filesLink, file.filename);
                          },
                        )),
                    Visibility(
                        visible: file.filetype == "link",
                        child: ListTile(
                          leading: const Icon(Icons.login_outlined),
                          title: const Text('Open link'),
                          onTap: () {
                            Navigator.pop(context);
                            LaunchUrl.openUrl(file.filesLink);
                          },
                        )),
                    Visibility(
                        visible: true,
                        child: ListTile(
                          leading: const Icon(Icons.report_outlined),
                          title: const Text('Report file'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReportActivity(
                                        id: file.id,
                                        reportOn: "file",
                                      )),
                            );
                          },
                        )),
                    Visibility(
                        visible: isAdmin,
                        child: ListTile(
                          leading: const Icon(Icons.delete_outline),
                          title: const Text('Delete file'),
                          onTap: () async {
                            Navigator.pop(context);
                            await confirmPopup(
                                context, deleteFile, "Delete file");
                          },
                        )),
                    if (isDownloading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      // Ensure cleanup happens after the bottom sheet is closed
      isMounted = false;
    });
  }
}
