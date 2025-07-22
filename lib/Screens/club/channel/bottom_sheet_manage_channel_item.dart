import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Screens/club/channel/channel_form.dart';
import 'package:learningx_flutter_app/api/common/confirm_popup.dart';
import 'package:learningx_flutter_app/api/model/channel_model.dart';
import 'package:learningx_flutter_app/api/model/club_model.dart';

class BottomSheetManageChannelItem {
  void showBottomSheet(BuildContext context, Channel channel, ClubItem clubItem, bool isNew,
      void Function(String) onDeleteChannel) {
    Future<void> deleteChannel() async {
      onDeleteChannel(channel.id);
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
                Text("${channel.members.length} members"),
                Visibility(
                    visible: !isNew,
                    child: ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('View Channel'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push(
                            "/club/${clubItem.id}/discussion/${channel.id}",
                            extra: {
                              'channel': channel,
                              'clubItem': clubItem,
                            });
                      },
                    )),
                Visibility(
                    visible: true,
                    child: ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('Edit Channel'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChannelFormScreen(
                                    channel: channel,
                                    clubId: channel.club,
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: !isNew,
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
                    visible: true,
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
