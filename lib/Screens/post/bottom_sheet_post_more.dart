import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learningx_flutter_app/Screens/common/report_form.dart';
import 'package:learningx_flutter_app/Screens/post/post_form.dart';
import 'package:learningx_flutter_app/api/common/confirm_popup.dart';
import 'package:learningx_flutter_app/api/model/post_model.dart';
import 'package:learningx_flutter_app/api/provider/post_provider.dart';

class BottomSheetPostItem {
  void copyLink(BuildContext context, String postId) {
    Clipboard.setData(
        ClipboardData(text: "https://clubchat.live/posts/$postId"));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Link copied!!")),
    );
  }

  void showBottomSheet(
      BuildContext context,
      Post post,
      bool isPostAdmin,
      String currentUserId,
      void Function(Post) onSaveToggled,
      void Function(String) onDeletePost) {
    void toggleSave(String userId, Post post) {
      final updatedSavedBy = post.savedBy!.contains(userId)
          ? (List<String>.from(post.savedBy!)..remove(userId))
          : (List<String>.from(post.savedBy!)..add(userId));
      final updatedPost = post.copyWith(savedBy: updatedSavedBy);
      onSaveToggled(updatedPost);
      Map<String, dynamic> data = HashMap();
      data['_id'] = post.id;
      data['savedBy'] = updatedSavedBy;
      updatePostApi(context, data);
    }

    Future<void> deletePost() async {
      await deletePostApi(context, post.id);
      onDeletePost(post.id);
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
                      leading: post.savedBy!.contains(currentUserId)
                          ? const Icon(Icons.save)
                          : const Icon(Icons.save_outlined),
                      title: post.savedBy!.contains(currentUserId)
                          ? const Text('Saved')
                          : const Text('Save Post'),
                      onTap: () {
                        Navigator.pop(context);
                        toggleSave(currentUserId, post);
                      },
                    )),
                Visibility(
                    visible: isPostAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('Edit Post'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreatePostPage(
                                    post: post,
                                    toEdit: true,
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: !isPostAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.report_outlined),
                      title: const Text('Report Post'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReportActivity(
                                    id: post.id,
                                    reportOn: "post",
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: true,
                    child: ListTile(
                      leading: const Icon(Icons.copy_outlined),
                      title: const Text('Copy Link'),
                      onTap: () {
                        Navigator.pop(context);
                        copyLink(context, post.id);
                      },
                    )),
                Visibility(
                    visible: isPostAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Delete Post'),
                      onTap: () async {
                        Navigator.pop(context);
                        await confirmPopup(context, deletePost, "Delete Post");
                      },
                    )),
              ],
            ),
          );
        });
  }
}
