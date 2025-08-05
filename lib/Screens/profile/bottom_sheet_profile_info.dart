import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/Screens/college/college_selection_search.dart';
import 'package:learningx_flutter_app/Screens/common/qr_creator.dart';
import 'package:learningx_flutter_app/Screens/common/report_form.dart';
import 'package:learningx_flutter_app/api/model/profile_model.dart';

class BottomSheetProfileInfo {
  void showBottomSheet(
      BuildContext context,
      Profile currentProfile,
      String userId,
      bool isBlocked,
      void Function(Map<String, dynamic>) refreshCurrentProfile) {
    void shareText() {
      String text = "to view the profile !\n\n https://clubchat.live/profile";
      // String text = "to view the profile !\n\n https://clubchat.live/profile/$userId";
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => QrCreator(
                  appBarText: "Share Profile",
                  sharedText: text,
                  url: "https://clubchat.live/profile/$userId",
                  imageUrl: currentProfile.user.userImg,
                )),
      );
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
                    visible: currentProfile.id != userId,
                    child: ListTile(
                      leading: const Icon(Icons.report_outlined),
                      title: const Text('Report Profile'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReportActivity(
                                    id: userId,
                                    reportOn: "profile",
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: currentProfile.id != userId && !isBlocked,
                    child: ListTile(
                      leading: const Icon(Icons.block_outlined),
                      title: const Text('Block Person'),
                      onTap: () async {
                        final updatedBlockedUser =
                            (List<String>.from(currentProfile.blockedUser!)
                              ..add(userId));
                        Navigator.pop(context);
                        Map<String, dynamic> map = HashMap();
                        map['_id'] = currentProfile.id;
                        map['blockedUser'] = updatedBlockedUser;
                        refreshCurrentProfile(map);
                      },
                    )),
                Visibility(
                    visible: currentProfile.id != userId && isBlocked,
                    child: ListTile(
                      leading: const Icon(Icons.public_outlined),
                      title: const Text('Unblock Person'),
                      onTap: () async {
                        final updatedBlockedUser =
                            (List<String>.from(currentProfile.blockedUser!)
                              ..remove(userId));
                        Navigator.pop(context);
                        Map<String, dynamic> map = HashMap();
                        map['_id'] = currentProfile.id;
                        map['blockedUser'] = updatedBlockedUser;
                        refreshCurrentProfile(map);
                      },
                    )),
                Visibility(
                    visible: true,
                    child: ListTile(
                      leading: const Icon(Icons.share_outlined),
                      title: const Text('Share Profile'),
                      onTap: () {
                        Navigator.pop(context);
                        shareText();
                      },
                    )),
                Visibility(
                    visible: currentProfile.id == userId,
                    child: ListTile(
                      leading: const Icon(Icons.change_circle_outlined),
                      title: const Text('Change your Campus'),
                      onTap: () {
                        Navigator.pop(context);
                        Map<String, dynamic> map = HashMap();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CollegeSelectionWidget(map: map),
                          ),
                        );
                      },
                    )),
              ],
            ),
          );
        });
  }
}
