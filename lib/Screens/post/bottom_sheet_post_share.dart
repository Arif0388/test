import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/Screens/post/post_form.dart';
import 'package:learningx_flutter_app/Screens/post/share_post_message.dart';
import 'package:learningx_flutter_app/api/model/post_model.dart';
import 'package:share_plus/share_plus.dart';

class BottomSheetPostShare {
  void showBottomSheet(BuildContext context, Post post, String currentUserId) {
    void shareText() {
      String text =
          "Hey there, you can use the link below to view the post !\n\n https://clubchat.live/posts/${post.id}";
      Share.share(text);
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
                    visible: post.sharedPost == null,
                    child: ListTile(
                      leading: const Icon(Icons.feed_outlined),
                      title: const Text('Share to Feed'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreatePostPage(
                                    toEdit: false,
                                    post: post,
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: true,
                    child: ListTile(
                      leading: const Icon(Icons.mail_outline),
                      title: const Text('Share to Message'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SharePostMessageScreen(
                                    currentuserId: currentUserId,
                                    link:
                                        "https://clubchat.live/posts/${post.id}",
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: true,
                    child: ListTile(
                      leading: const Icon(Icons.share_outlined),
                      title: const Text('Share Via'),
                      onTap: () {
                        Navigator.pop(context);
                        shareText();
                      },
                    )),
              ],
            ),
          );
        });
  }
}
