import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/Screens/club/channel/manage_channels.dart';
import 'package:learningx_flutter_app/Screens/common/qr_creator.dart';
import 'package:learningx_flutter_app/Screens/common/report_form.dart';
import 'package:learningx_flutter_app/Screens/common/view_admin_page.dart';
import 'package:learningx_flutter_app/Screens/council/council_form.dart';
import 'package:learningx_flutter_app/Screens/council/manage_council_admin.dart';
import 'package:learningx_flutter_app/api/model/council_model.dart';

class BottomSheetCouncilInfo {
  void showBottomSheet(BuildContext context, Council council, bool isAdmin) {
    void shareText() {
      String text =
          "to discover clubs and events of the council ${council.councilName} !\n\n https://clubchat.live/council/${council.id}";
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => QrCreator(
                  appBarText: "Share Council",
                  sharedText: text,
                  url: "https://clubchat.live/council/${council.id}",
                  imageUrl: council.councilImg,
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
                                    id: council.id,
                                    reportOn: "councilival",
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
                                    admin: council.admin,
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
                              builder: (context) => CouncilForm(
                                    council: council,
                                    collegeId: council.college.id,
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
                              builder: (context) => ManageCouncilAdmin(
                                    council: council,
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
                                    clubItem: council.clubItem,
                                  )),
                        );
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
