import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Screens/club/file/bottom_sheet_file_item.dart';
import 'package:learningx_flutter_app/Style/custom_style.dart';
import 'package:learningx_flutter_app/api/common/full_image_page.dart';
import 'package:learningx_flutter_app/api/common/video_player_page.dart';
import 'package:learningx_flutter_app/api/common/open_file.dart';
import 'package:learningx_flutter_app/api/common/launch_url.dart';
import 'package:learningx_flutter_app/api/model/files_model.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart';

class FileItemCard extends StatefulWidget {
  final Files file;
  final bool isAdmin;
  final void Function(String) onDeleteFile;
  const FileItemCard({
    super.key,
    required this.file,
    required this.isAdmin,
    required this.onDeleteFile,
  });

  @override
  State<FileItemCard> createState() => _FilesPageState();
}

class _FilesPageState extends State<FileItemCard> {
  bool isDownloading = false;

  Future<void> handleOpenFile() async {
    if (widget.file.filetype == "video") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerPage(
            url: widget.file.filesLink,
          ),
        ),
      );
    } else if (widget.file.filetype == "image") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullImagePage(
            url: widget.file.filesLink,
            displayName: widget.file.user.displayName,
          ),
        ),
      );
    } else if (widget.file.filetype == "file") {
      if (kIsWeb) {
        // ignore: unused_local_variable
        html.AnchorElement anchorElement =
            html.AnchorElement(href: widget.file.filesLink)
              ..setAttribute('download', '')
              ..click();
      } else {
        if (!isDownloading) {
          setState(() {
            isDownloading = true;
          });
          await openFile(widget.file.filesLink, (_) {});
          setState(() {
            isDownloading = false;
          });
        }
      }
    } else if (widget.file.filetype == "link") {
      LaunchUrl.openUrl(widget.file.filesLink);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: handleOpenFile,
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.all(2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    if (widget.file.filetype == "image")
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Image.asset('assets/icons/image.png'),
                      ),
                    if (widget.file.filetype == "video")
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Image.asset('assets/icons/film.png'),
                      ),
                    if (widget.file.filetype == "file")
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Image.asset('assets/icons/file.png'),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () =>
                          context.push("/profile/${widget.file.user.id}"),
                      child: Text(
                        widget.file.user.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    Text(
                      widget.file.filename,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${Utils.formatBytes(int.parse(widget.file.filesize), 2)} • ${Utils.getTimeAgo(widget.file.createdAtDate)}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () {
                  final BottomSheetFileItem sheetFileItem =
                      BottomSheetFileItem();
                  sheetFileItem.showBottomSheet(context, widget.file,
                      widget.isAdmin, widget.onDeleteFile);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
