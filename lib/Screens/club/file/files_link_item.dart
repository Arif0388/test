import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Screens/club/file/bottom_sheet_file_item.dart';
import 'package:learningx_flutter_app/Style/custom_style.dart';
import 'package:learningx_flutter_app/api/common/launch_url.dart';
import 'package:learningx_flutter_app/api/model/files_model.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';

class FilesLinkItemWidget extends StatelessWidget {
  final Files file;
  final bool isAdmin;
  final void Function(String) onDeleteFile;
  const FilesLinkItemWidget(
      {super.key,
      required this.file,
      required this.isAdmin,
      required this.onDeleteFile});

  @override
  Widget build(BuildContext context) {
    return Card(
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
              child: SizedBox(
                width: 40,
                height: 40,
                child: Image.asset('assets/icons/link.png'),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => context.push("/profile/${file.user.id}"),
                    child: Text(
                      file.user.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                      onTap: () {
                        LaunchUrl.openUrl(file.filesLink);
                      },
                      child: Text(
                        file.filesLink,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      )),
                  const SizedBox(height: 8),
                  Text(
                    Utils.getTimeAgo(file.createdAtDate),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                final BottomSheetFileItem sheetFileItem = BottomSheetFileItem();
                sheetFileItem.showBottomSheet(
                    context, file, isAdmin, onDeleteFile);
              },
              icon: const Icon(Icons.more_horiz),
              iconSize: 24,
              padding: const EdgeInsets.all(4),
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
