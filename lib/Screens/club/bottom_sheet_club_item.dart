import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Screens/club/channel/manage_channels.dart';
import 'package:learningx_flutter_app/Screens/club/form/club_form1.dart';
import 'package:learningx_flutter_app/Screens/common/qr_creator.dart';
import 'package:learningx_flutter_app/api/common/confirm_popup.dart';
import 'package:learningx_flutter_app/api/model/club_model.dart';
import 'package:learningx_flutter_app/api/provider/club_member_provider.dart';

class BottomSheetClubItem {
  void showBottomSheet(BuildContext context, ClubItem club, bool isAdmin,
      String currentUserId, void Function(String) onRemoveClub) {
    void shareText() {
      String text = "to join our club !\n\n https://clubchat.live/club/about";
      // String text = "to join our club !\n\n https://clubchat.live/club/about/${club.id}";
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => QrCreator(
                  appBarText: "Invite members",
                  sharedText: text,
                  url: "https://clubchat.live/club/about/${club.id}",
                  imageUrl: club.clubImg,
                )),
      );
    }

    Future<void> leaveClub() async {
      Map<String, dynamic> map = HashMap();
      map['club'] = club.id;
      map['user'] = currentUserId;
      await deleteClubMemberApi(context, map);
      onRemoveClub(club.id);
    }

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
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
                  club.clubName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Text('${club.members.length} memebers'),
                Visibility(
                    visible: true,
                    child: ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(club.category == "council"
                          ? 'Council Info'
                          : 'Club Info'),
                      onTap: () {
                        Navigator.pop(context);
                        if (club.category == "council") {
                          context.push("/council/${club.id}");
                        } else {
                          context.push("/club/about/${club.id}");
                        }
                      },
                    )),
                Visibility(
                    visible: !isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.group_outlined),
                      title: const Text('View Members'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push("/club/member/${club.id}", extra: {
                          'isAdmin': false,
                        });
                      },
                    )),
                Visibility(
                    visible: isAdmin && club.category != "council",
                    child: ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('Edit Club'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ClubForm1Activity(
                                    clubId: club.id,
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: const Text('Manage Channels'),
                      onTap: () {
                        Navigator.pop(context); // Close the bottom sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ManageChannelsPage(
                                    clubItem: club,
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: isAdmin && club.category != "council",
                    child: ListTile(
                      leading: const Icon(Icons.group_outlined),
                      title: const Text('Manage Members'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push("/club/member/${club.id}", extra: {
                          'isAdmin': true,
                        });
                      },
                    )),
                Visibility(
                    visible: club.category != "council",
                    child: ListTile(
                      leading: const Icon(Icons.share_outlined),
                      title: const Text('Invite members'),
                      onTap: () {
                        Navigator.pop(context); // Close the bottom sheet
                        shareText();
                      },
                    )),
                Visibility(
                    visible: (!isAdmin || club.admin.length > 1),
                    child: ListTile(
                      leading: const Icon(Icons.logout_outlined),
                      title: Text(club.category == "council"
                          ? 'Leave Council'
                          : 'Leave Club'),
                      onTap: () async {
                        var word = "Leave Club";
                        if (club.category == "council") {
                          word = "Leave Council";
                        } else {
                          word = "Leave Club";
                        }
                        Navigator.pop(context);
                        await confirmPopup(context, leaveClub, word);
                      },
                    )),
              ],
            ),
          );
        });
  }
}
