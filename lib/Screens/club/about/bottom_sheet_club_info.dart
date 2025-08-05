import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Screens/club/channel/manage_channels.dart';
import 'package:learningx_flutter_app/Screens/club/form/club_form1.dart';
import 'package:learningx_flutter_app/Screens/club/member/admin_member_page.dart';
import 'package:learningx_flutter_app/Screens/common/qr_creator.dart';
import 'package:learningx_flutter_app/Screens/common/report_form.dart';
import 'package:learningx_flutter_app/api/common/confirm_popup.dart';
import 'package:learningx_flutter_app/api/model/channel_model.dart';
import 'package:learningx_flutter_app/api/model/club_model.dart';
import 'package:learningx_flutter_app/api/provider/club_member_provider.dart';
import 'package:learningx_flutter_app/api/provider/club_provider.dart';

class BottomSheetClubInfo {
  void showBottomSheet(
      BuildContext context,
      List<Channel> channels,
      Club clubItem,
      String currentUserId,
      bool isAdmin,
      bool isCollegeAdmin,
      void Function(String) onDeleteClub,
      Future<void> Function(Map<String, dynamic>) onUpdateClub) {
    void shareText() {
      String text = "to join our club !\n\n https://clubchat.live/club/about";
      // String text = "to join our club !\n\n https://clubchat.live/club/about/${clubItem.id}";
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => QrCreator(
                  appBarText: "Invite members",
                  sharedText: text,
                  url: "https://clubchat.live/club/about/${clubItem.id}",
                  imageUrl: clubItem.clubImg,
                )),
      );
    }

    Future<void> leaveClub() async {
      Map<String, dynamic> map = HashMap();
      map['club'] = clubItem.id;
      map['user'] = currentUserId;
      await deleteClubMemberApi(context, map);
      onDeleteClub(clubItem.id);
    }

    Future<void> deleteClub() async {
      await deleteClubApi(context, clubItem.id);
      onDeleteClub(clubItem.id);
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
                  clubItem.clubName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Text('${clubItem.members.length} members'),
                Visibility(
                    visible: isCollegeAdmin ||
                        (!isAdmin && clubItem.members.contains(currentUserId)),
                    child: ListTile(
                      leading: const Icon(Icons.group_outlined),
                      title: const Text('View Members'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push("/club/member/${clubItem.id}", extra: {
                          'isAdmin': false,
                        });
                      },
                    )),
                Visibility(
                    visible: isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('Edit Club'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ClubForm1Activity(
                                    clubId: clubItem.id,
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
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ManageChannelsPage(
                                    clubItem: clubItem.toClubItem(),
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.group_outlined),
                      title: const Text('Manage Members'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push("/club/member/${clubItem.id}", extra: {
                          'isAdmin': true,
                        });
                      },
                    )),
                Visibility(
                    visible: !clubItem.members.contains(currentUserId) &&
                        !isCollegeAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.remove_red_eye_outlined),
                      title: const Text('View Admin'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AdminMemberPage(
                                    id: clubItem.id,
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: true,
                    child: ListTile(
                      leading: const Icon(Icons.share_outlined),
                      title: const Text('Invite members'),
                      onTap: () {
                        Navigator.pop(context);
                        shareText();
                      },
                    )),
                Visibility(
                    visible:
                        isCollegeAdmin && clubItem.collegeStatus != "verified",
                    child: ListTile(
                      leading: const Icon(Icons.verified_outlined),
                      title: const Text('Verify as Official Campus Club'),
                      onTap: () async {
                        Navigator.pop(context);
                        Map<String, dynamic> map = HashMap();
                        map['_id'] = clubItem.id;
                        map['college_status'] = "verified";
                        await onUpdateClub(map);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Verified!")),
                        );
                      },
                    )),
                Visibility(
                    visible: isCollegeAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.block_outlined),
                      title: const Text('Remove from Campus Page'),
                      onTap: () async {
                        Navigator.pop(context);
                        Map<String, dynamic> map = HashMap();
                        map['_id'] = clubItem.id;
                        map['college'] = null;
                        map['privacy'] = "private";
                        map['college_status'] = "rejected";
                        await onUpdateClub(map);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Removed!")),
                        );
                      },
                    )),
                Visibility(
                    visible: isCollegeAdmin &&
                        clubItem.collegeStatus != "unverified",
                    child: ListTile(
                      leading: const Icon(Icons.add_outlined),
                      title: const Text('Add to Campus Page as unofficial'),
                      onTap: () async {
                        Navigator.pop(context);
                        Map<String, dynamic> map = HashMap();
                        map['_id'] = clubItem.id;
                        map['college_status'] = "unverified";
                        await onUpdateClub(map);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Added to Page!")),
                        );
                      },
                    )),
                Visibility(
                    visible: !isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.report_outlined),
                      title: const Text('Report Club'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReportActivity(
                                    id: clubItem.id,
                                    reportOn: "club",
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: clubItem.members.contains(currentUserId) &&
                        (!isAdmin || clubItem.admin.length > 1),
                    child: ListTile(
                      leading: const Icon(Icons.logout_outlined),
                      title: const Text('Leave Club'),
                      onTap: () async {
                        Navigator.pop(context);
                        await confirmPopup(context, leaveClub, "Leave Club");
                      },
                    )),
                Visibility(
                    visible: isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Delete Club'),
                      onTap: () async {
                        Navigator.pop(context);
                        await confirmPopup(context, deleteClub, "Delete Club");
                      },
                    )),
              ],
            ),
          );
        });
  }
}
