import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Screens/club/channel/channel_form.dart';
import 'package:learningx_flutter_app/api/common/confirm_popup.dart';
import 'package:learningx_flutter_app/api/model/channel_model.dart';
import 'package:learningx_flutter_app/api/model/club_model.dart';
import 'package:learningx_flutter_app/api/provider/channel_member_provider.dart';
import 'package:learningx_flutter_app/api/provider/channel_provider.dart';

class BottomSheetChannelInfo {
  void showBottomSheet(BuildContext context, ClubItem clubItem, Channel channel,
      bool isAdmin, String currentUserId) {
    Future<void> leaveChannel() async {
      Map<String, dynamic> map = HashMap();
      map['channel'] = channel.id;
      map['_id'] = currentUserId;
      await deleteChannelMemberApi(context, map);
      Navigator.pop(context);
    }

    Future<void> deleteChannel() async {
      await deleteChannelApi(context, channel.id);
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
                Text(
                  clubItem.clubName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Text('${clubItem.members.length} members'),
                Visibility(
                    visible: true,
                    child: ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(clubItem.category == "council"
                          ? 'Council Info'
                          : 'Club Info'),
                      onTap: () {
                        Navigator.pop(context);
                        if (clubItem.category == "council") {
                          context.push("/council/${clubItem.id}");
                        } else {
                          context.push("/club/about/${clubItem.id}");
                        }
                      },
                    )),
                Visibility(
                    visible: !isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.group_outlined),
                      title: const Text('View members'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push("/channel/member/${channel.id}", extra: {
                          'channel': channel,
                          'clubName': clubItem.clubName,
                        });
                      },
                    )),
                Visibility(
                    visible: isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('Edit Channel'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChannelFormScreen(
                                    clubId: channel.club,
                                    channel: channel,
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: const Text('Manage Members'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push("/channel/member/${channel.id}", extra: {
                          'channel': channel,
                          'clubName': clubItem.clubName,
                        });
                      },
                    )),
                Visibility(
                    visible: (!isAdmin || clubItem.admin.length > 1),
                    child: ListTile(
                      leading: const Icon(Icons.logout_outlined),
                      title: const Text('Leave Channel'),
                      onTap: () async {
                        Navigator.pop(context);
                        await confirmPopup(
                            context, leaveChannel, "Leave Channel");
                      },
                    )),
                Visibility(
                    visible: isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Delete Channel'),
                      onTap: () async {
                        Navigator.pop(context);
                        await confirmPopup(
                            context, deleteChannel, "Delete Channel");
                      },
                    )),
              ],
            ),
          );
        });
  }
}
