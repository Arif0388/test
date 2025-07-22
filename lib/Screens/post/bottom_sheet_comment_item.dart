import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/Screens/common/report_form.dart';
import 'package:learningx_flutter_app/api/common/confirm_popup.dart';
import 'package:learningx_flutter_app/api/model/event_comment_model.dart';

class BottomSheetCommentItem {
  void showBottomSheet(BuildContext context, EventComment comment, bool isAdmin,
      void Function(String) onDeleteComment) {
    Future<void> deleteComment() async {
      Map<String, dynamic> map = HashMap();
      map['_id'] = comment.id;
      map['event'] = comment.event;
      onDeleteComment(comment.id);
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
                    visible: !isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.report_outlined),
                      title: const Text('Report Comment'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReportActivity(
                                    id: comment.id,
                                    reportOn: "eventComment",
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Delete Comment'),
                      onTap: () async {
                        Navigator.pop(context);
                        await confirmPopup(
                            context, deleteComment, "Delete Comment");
                      },
                    )),
              ],
            ),
          );
        });
  }
}
