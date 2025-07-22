import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Screens/post/bottom_sheet_post_more.dart';
import 'package:learningx_flutter_app/Screens/post/bottom_sheet_post_share.dart';
import 'package:learningx_flutter_app/api/common/image_slider.dart';
import 'package:learningx_flutter_app/api/common/video_player.dart';
import 'package:learningx_flutter_app/api/model/post_model.dart';
import 'package:learningx_flutter_app/api/provider/post_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class PostItemWidget extends ConsumerStatefulWidget {
  List<Post> totalPosts;
  late Post post;
  void Function(String) onDeletePost;
  PostItemWidget(
      {super.key,
      required this.totalPosts,
      required this.post,
      required this.onDeletePost});

  @override
  ConsumerState<PostItemWidget> createState() => _PostItemState();
}

class _PostItemState extends ConsumerState<PostItemWidget> {
  String _currentUserId = "";
  bool isAdmin = false;
  bool isExpanded = false;

  @override
  void initState() {
    _loadCurrentUser();
    super.initState();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString("id") ?? "";
    });
  }

  void toggleLike(String userId) {
    setState(() {
      final updatedLikes = widget.post.likes!.contains(userId)
          ? (List<String>.from(widget.post.likes!)..remove(userId))
          : (List<String>.from(widget.post.likes!)..add(userId));
      widget.post = widget.post.copyWith(likes: updatedLikes);
      Map<String, dynamic> data = HashMap();
      data['_id'] = widget.post.id;
      data['likes'] = updatedLikes;
      updatePostApi(context, data);
    });
  }

  void handleSaveToggle(Post updatedPost) {
    setState(() {
      widget.post = updatedPost;
    });
  }

  @override
  Widget build(BuildContext context) {
    var link = "/home";
    var isPostAdmin = false;
    var postUsername = "";
    var postUserImg =
        "https://learningx-s3.s3.ap-south-1.amazonaws.com/user.png";
    Widget collegName = const Text("");
    if (widget.post.user != null) {
      link = "/profile/${widget.post.user!.id}";
      postUsername = widget.post.user!.displayName;
      postUserImg = widget.post.user!.userImg;
      isPostAdmin = widget.post.user!.id == _currentUserId;
      if (widget.post.user!.college != null &&
          widget.post.user!.college!.id != dotenv.env['OTHER_COLLEGE_ID']) {
        collegName = Text(
          widget.post.user!.college!.collegeName,
          overflow: TextOverflow.ellipsis,
        );
      } else {
        collegName = Text(widget.post.user!.userName);
      }
    } else if (widget.post.club != null) {
      link = "/club/about/${widget.post.club!.id}";
      postUsername = widget.post.club!.clubName;
      postUserImg = widget.post.club!.clubImg;
      isPostAdmin = widget.post.club!.admin.contains(_currentUserId);
      if (widget.post.club!.college != null) {
        collegName = Text(
          widget.post.club!.college!.collegeName,
          overflow: TextOverflow.ellipsis,
        );
      } else {
        collegName = Text(widget.post.club!.category);
      }
    } else if (widget.post.fest != null) {
      link = "/club/fest/${widget.post.fest!.id}";
      postUsername = widget.post.fest!.festName;
      postUserImg = widget.post.fest!.festImg;
      isPostAdmin = widget.post.fest!.admin.contains(_currentUserId);
      collegName = Text(
        widget.post.fest!.college.collegeName,
        overflow: TextOverflow.ellipsis,
      );
    }
    if (widget.post.privacy != null) {
      collegName = Row(
        children: [
          const Icon(
            Icons.lock_outline,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            widget.post.privacy!.clubName,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    var sharedPostUsername = "";
    var sharedPostUserImg =
        "https://learningx-s3.s3.ap-south-1.amazonaws.com/user.png";
    if (widget.post.sharedPost != null) {
      if (widget.post.sharedPost!.user != null) {
        sharedPostUsername = widget.post.sharedPost!.user!.displayName;
        sharedPostUserImg = widget.post.sharedPost!.user!.userImg;
      } else if (widget.post.sharedPost!.club != null) {
        sharedPostUsername = widget.post.sharedPost!.club!.clubName;
        sharedPostUserImg = widget.post.sharedPost!.club!.clubImg;
      } else if (widget.post.sharedPost!.fest != null) {
        sharedPostUsername = widget.post.sharedPost!.fest!.festName;
        sharedPostUserImg = widget.post.sharedPost!.fest!.festImg;
      }
    }
    final isTextOverflow = !isExpanded && widget.post.text.length > 100;

    return Card(
      margin: const EdgeInsets.all(2),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                    onTap: () {
                      context.push(link);
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(postUserImg),
                      backgroundColor: Colors.transparent,
                    )),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      postUsername,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    collegName
                  ],
                )),
                IconButton(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      final BottomSheetPostItem sheetPostItem =
                          BottomSheetPostItem();
                      sheetPostItem.showBottomSheet(
                          context,
                          widget.post,
                          isPostAdmin,
                          _currentUserId,
                          handleSaveToggle,
                          widget.onDeletePost);
                    },
                    icon: const Icon(Icons.more_horiz)),
              ],
            ),
            const SizedBox(height: 16),
            Visibility(
                visible: widget.post.text.isNotEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.text,
                      maxLines: isExpanded ? null : 3,
                      overflow: isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black),
                    ),
                    if (isTextOverflow)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                        },
                        child: Text(
                          isExpanded ? 'Show less' : 'See more',
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                  ],
                )),
            Visibility(
                visible: widget.post.images.length == 1,
                child: Container(
                  margin: const EdgeInsets.only(top: 5),
                  width: MediaQuery.of(context).size.width - 10,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        widget.post.images.isNotEmpty
                            ? widget.post.images.first
                            : "https://learningx-s3.s3.ap-south-1.amazonaws.com/user.png",
                        fit: BoxFit.contain,
                        width: MediaQuery.of(context).size.height / 1.8,
                      ),
                    ),
                  ),
                )),
            Visibility(
                visible: widget.post.images.length > 1,
                child: Container(
                  margin: const EdgeInsets.only(top: 5),
                  width: MediaQuery.of(context).size.width - 10,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: ImageSlider(imgList: widget.post.images)),
                )),
            if (widget.post.videofile != null)
              VideoPlayerWidget(
                url: widget.post.videofile!,
              ),
            const SizedBox(
              height: 5,
            ),
            if (widget.post.sharedPost != null)
              Card(
                  elevation: 1,
                  child: GestureDetector(
                      onTap: () {
                        context.push("/posts/${widget.post.sharedPost!.id}");
                      },
                      child: Container(
                        color: const Color.fromRGBO(255, 255, 255, 0.4),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage:
                                      NetworkImage(sharedPostUserImg),
                                  backgroundColor: Colors.transparent,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  sharedPostUsername,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Visibility(
                                visible:
                                    widget.post.sharedPost!.text.isNotEmpty,
                                child: Text(
                                  widget.post.sharedPost!.text,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.black),
                                )),
                            Visibility(
                                visible:
                                    widget.post.sharedPost!.images.length == 1,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  width: MediaQuery.of(context).size.width - 10,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        widget.post.sharedPost!.images
                                                .isNotEmpty
                                            ? widget
                                                .post.sharedPost!.images.first
                                            : "https://learningx-s3.s3.ap-south-1.amazonaws.com/user.png",
                                        fit: BoxFit.contain,
                                        width:
                                            MediaQuery.of(context).size.height /
                                                1.8,
                                      ),
                                    ),
                                  ),
                                )),
                            Visibility(
                                visible:
                                    widget.post.sharedPost!.images.length > 1,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  width: MediaQuery.of(context).size.width - 10,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                      padding: const EdgeInsets.all(1.0),
                                      child: ImageSlider(
                                          imgList:
                                              widget.post.sharedPost!.images)),
                                )),
                            if (widget.post.sharedPost!.videofile != null)
                              VideoPlayerWidget(
                                url: widget.post.sharedPost!.videofile!,
                              ),
                            const SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ))),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                children: [
                  Row(
                    children: [
                      IconButton(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          toggleLike(_currentUserId);
                        },
                        icon: widget.post.likes!.contains(_currentUserId)
                            ? const Icon(Icons.favorite)
                            : const Icon(Icons.favorite_border),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Row(children: [
                          Text("${widget.post.likes?.length} likes"),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      IconButton(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            context.push("/posts/${widget.post.id}/comments");
                          },
                          icon: const Icon(Icons.chat_bubble_outline)),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Row(children: [
                          Text("${widget.post.commentsCount} comments"),
                        ]),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        final BottomSheetPostShare sheetPostShare =
                            BottomSheetPostShare();
                        sheetPostShare.showBottomSheet(
                            context, widget.post, _currentUserId);
                      },
                      icon: const Icon(Icons.share_outlined)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
