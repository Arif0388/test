import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Screens/common/report_form.dart';
import 'package:learningx_flutter_app/api/common/confirm_popup.dart';
import 'package:learningx_flutter_app/api/model/discussion_model.dart';
import 'package:learningx_flutter_app/api/provider/discussion_provider.dart';

class BottomSheetChatItem {
  void copyLink(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("text copied!!")),
    );
  }

  void showBottomSheet(BuildContext context, Discussion chat,
      void Function(String) onDeleteChat, bool isAllowedToDelete) {
    Future<void> deleteChat() async {
      Map<String, dynamic> map = HashMap();
      map['channel'] = chat.channel;
      map['id'] = chat.id;
      onDeleteChat(chat.id);
      await deleteDiscussionApi(context, map);
    }

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
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
                    visible: true,
                    child: ListTile(
                      leading: const Icon(Icons.remove_red_eye_outlined),
                      title: const Text('View Profile'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push("/profile/${chat.sender.id}");
                      },
                    )),
                Visibility(
                    visible: true,
                    child: ListTile(
                      leading: const Icon(Icons.report_outlined),
                      title: const Text('Report Chat'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReportActivity(
                                    id: chat.id,
                                    reportOn: "discussion",
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: chat.filetype == "text",
                    child: ListTile(
                      leading: const Icon(Icons.copy_all_outlined),
                      title: const Text('Copy Text'),
                      onTap: () {
                        Navigator.pop(context);
                        copyLink(context,
                            chat.title != null ? chat.title! : chat.chat);
                      },
                    )),
                Visibility(
                    visible: isAllowedToDelete,
                    child: ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Delete Chat'),
                      onTap: () async {
                        Navigator.pop(context);
                        await confirmPopup(context, deleteChat, "Delete chat");
                      },
                    )),
              ],
            ),
          );
        });
  }
}
