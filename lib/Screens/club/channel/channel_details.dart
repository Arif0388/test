import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Screens/club/channel/bottom_sheet_channel_info.dart';
import 'package:learningx_flutter_app/Screens/club/discussion/discussion_page.dart';
import 'package:learningx_flutter_app/Screens/club/file/files_page.dart';
import 'package:learningx_flutter_app/Screens/club/session/session_form.dart';
import 'package:learningx_flutter_app/Screens/club/session/session_page.dart';
import 'package:learningx_flutter_app/Screens/club/discussion/group_discussion_form.dart';
import 'package:learningx_flutter_app/Screens/common/bottom_sheet_select_filetype.dart';
import 'package:learningx_flutter_app/api/model/channel_model.dart';
import 'package:learningx_flutter_app/api/model/club_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChannelInfoScreen extends StatefulWidget {
  final Channel channel;
  final ClubItem clubItem;
  const ChannelInfoScreen(
      {super.key, required this.channel, required this.clubItem});

  @override
  State<ChannelInfoScreen> createState() => _ChannelInfoScreenState();
}

class _ChannelInfoScreenState extends State<ChannelInfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  String _currentUserId = "";
  bool isAdmin = false;
  bool refreshPage = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      widget.channel.unreadCount = 0;
    });
    unsubscribeToFCM(widget.channel.club);
    _loadCurrentUser();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
        // Unfocus the TextField when switching tabs
        FocusScope.of(context).unfocus();
      });
    });
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString("id") ?? "";
      isAdmin = widget.channel.admin.contains(_currentUserId);
    });
  }

  @override
  void dispose() {
    subscribeToFCM(widget.channel.club);
    _tabController.dispose();
    super.dispose();
  }

  void subscribeToFCM(String clubId) async {
    var firebaseMessaging = FirebaseMessaging.instance;
    if (Platform.isMacOS || Platform.isIOS) {
      String? apnsToken = await firebaseMessaging.getAPNSToken();
      if (apnsToken != null) {
        await firebaseMessaging.subscribeToTopic(clubId);
      } else {
        await Future<void>.delayed(
          const Duration(seconds: 3),
        );
        apnsToken = await firebaseMessaging.getAPNSToken();
        if (apnsToken != null) {
          await firebaseMessaging.subscribeToTopic(clubId);
        }
      }
    } else {
      await firebaseMessaging.subscribeToTopic(clubId);
    }
  }

  void unsubscribeToFCM(String clubId) async {
    var firebaseMessaging = FirebaseMessaging.instance;
    if (Platform.isMacOS || Platform.isIOS) {
      String? apnsToken = await firebaseMessaging.getAPNSToken();
      if (apnsToken != null) {
        await firebaseMessaging.unsubscribeFromTopic(clubId);
      } else {
        await Future<void>.delayed(
          const Duration(seconds: 3),
        );
        apnsToken = await firebaseMessaging.getAPNSToken();
        if (apnsToken != null) {
          await firebaseMessaging.unsubscribeFromTopic(clubId);
        }
      }
    } else {
      await firebaseMessaging.unsubscribeFromTopic(clubId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<List<Widget>> appBarActions = [
      [
        IconButton(
          icon: const Icon(Icons.groups_3_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DiscussionFormActivity(
                        channel: widget.channel,
                      )),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz, size: 30),
          onPressed: () {
            final BottomSheetChannelInfo sheetChannelInfo =
                BottomSheetChannelInfo();
            sheetChannelInfo.showBottomSheet(context, widget.clubItem,
                widget.channel, isAdmin, _currentUserId);
          },
        ),
        const SizedBox(width: 8),
      ],
      [
        Visibility(
            visible: widget.channel.permission == "public" ||
                (widget.channel.permission == "private" &&
                    widget.channel.admin.contains(_currentUserId)),
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                final SelectFiletypeBottomSheet bottomSheet =
                    SelectFiletypeBottomSheet();
                bottomSheet.showBottomSheet(
                    context, "file", null, widget.channel, null, null);
              },
            )),
        IconButton(
          icon: const Icon(Icons.more_horiz, size: 30),
          onPressed: () {
            final BottomSheetChannelInfo sheetChannelInfo =
                BottomSheetChannelInfo();
            sheetChannelInfo.showBottomSheet(context, widget.clubItem,
                widget.channel, isAdmin, _currentUserId);
          },
        ),
        const SizedBox(width: 8),
      ],
      [
        Visibility(
            visible: isAdmin,
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SessionFormActivity(
                            channel: widget.channel,
                          )),
                );
              },
            )),
        IconButton(
          icon: const Icon(Icons.more_horiz, size: 30),
          onPressed: () {
            final BottomSheetChannelInfo sheetChannelInfo =
                BottomSheetChannelInfo();
            sheetChannelInfo.showBottomSheet(context, widget.clubItem,
                widget.channel, isAdmin, _currentUserId);
          },
        ),
        const SizedBox(width: 8),
      ]
    ];

    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 211, 232, 255),
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
          actions: appBarActions[_currentIndex],
          title: Row(
            children: [
              GestureDetector(
                  onTap: () {
                    if (widget.clubItem.category == "council") {
                      context.push("/council/${widget.channel.club}");
                    } else {
                      context.push("/club/about/${widget.channel.club}");
                    }
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(widget.clubItem.clubImg),
                  )),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                    onTap: () {
                      if (widget.clubItem.category == "council") {
                        context.push("/council/${widget.channel.club}");
                      } else {
                        context.push("/club/about/${widget.channel.club}");
                      }
                    },
                    child: Text(
                      widget.channel.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
                color: const Color.fromARGB(255, 211, 232, 255),
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: "Chats"),
                    Tab(text: "Files"),
                    Tab(text: "Session"),
                  ],
                  labelColor: const Color.fromARGB(255, 56, 114, 220),
                  unselectedLabelColor: Colors.black,
                  indicatorColor: const Color.fromARGB(255, 56, 114, 220),
                )),
            Expanded(
                child: TabBarView(
              controller: _tabController,
              children: [
                DiscussionPageScreen(channel: widget.channel),
                FilesPage(
                  channel: widget.channel,
                ),
                SessionPageScreen(
                  channel: widget.channel,
                ),
              ],
            )),
          ],
        ));
  }
}
