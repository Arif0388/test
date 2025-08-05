import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/Screens/common/qr_creator.dart';
import 'package:learningx_flutter_app/Screens/common/report_form.dart';
import 'package:learningx_flutter_app/Screens/common/view_admin_page.dart';
import 'package:learningx_flutter_app/Screens/communities/community_form.dart';
import 'package:learningx_flutter_app/Screens/communities/manage_community_admin.dart';
import 'package:learningx_flutter_app/api/model/community_model.dart';

class BottomSheetCommunityInfo {
  void showBottomSheet(
      BuildContext context, Community community, bool isAdmin) {
    void shareText() {
      String text = "to discover clubs and events of the council ${community.title} !\n\n https://clubchat.live/council";
      // String text = "to discover clubs and events of the council ${community.title} !\n\n https://clubchat.live/council/${community.id}";
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => QrCreator(
                  appBarText: "Share Council",
                  sharedText: text,
                  url: "https://clubchat.live/council/${community.id}",
                  imageUrl: community.coverImg,
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
                    visible: !isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.report_outlined),
                      title: const Text('Report Page'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReportActivity(
                                    id: community.id,
                                    reportOn: "community",
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: !isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.remove_red_eye_outlined),
                      title: const Text('View Admin'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewAdminPage(
                                    admin: community.admin,
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('Edit Page'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CommunityForm(
                                    community: community,
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.admin_panel_settings_outlined),
                      title: const Text('Manage Admin'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ManageCommunityAdmin(
                                    community: community,
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
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => ManageChannelsPage(
                        //             clubItem: community.clubItem,
                        //           )),
                        // );
                      },
                    )),
                Visibility(
                    visible: true,
                    child: ListTile(
                      leading: const Icon(Icons.share_outlined),
                      title: const Text('Share Council'),
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
