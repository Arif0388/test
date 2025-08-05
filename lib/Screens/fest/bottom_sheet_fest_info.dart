import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/Screens/common/qr_creator.dart';
import 'package:learningx_flutter_app/Screens/common/report_form.dart';
import 'package:learningx_flutter_app/Screens/common/view_admin_page.dart';
import 'package:learningx_flutter_app/Screens/fest/fest_form.dart';
import 'package:learningx_flutter_app/Screens/fest/manage_fest_admin.dart';
import 'package:learningx_flutter_app/api/common/confirm_popup.dart';
import 'package:learningx_flutter_app/api/model/fest_model.dart';
import 'package:learningx_flutter_app/api/provider/fest_provider.dart';

class BottomSheetFestInfo {
  void showBottomSheet(BuildContext context, Fest fest, bool isAdmin) {
    void shareText() {
      String text = "to see the details of events hosted by ${fest.festName} !\n\n https://clubchat.live/club/fest";
      // String text = "to see the details of events hosted by ${fest.festName} !\n\n https://clubchat.live/club/fest/${fest.id}";
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => QrCreator(
                  appBarText: "Share Festival",
                  sharedText: text,
                  url: "https://clubchat.live/club/fest/${fest.id}",
                  imageUrl: fest.festImg,
                )),
      );
    }

    Future<void> deleteFest() async {
      await deleteFestApi(context, fest.id);
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
                                    id: fest.id,
                                    reportOn: "festival",
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
                                    admin: fest.admin,
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
                              builder: (context) => FestFormActivity(
                                    fest: fest,
                                    collegeId: fest.college.id,
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: const Text('Manage Admin'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ManageFestAdmin(
                                    fest: fest,
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: true,
                    child: ListTile(
                      leading: const Icon(Icons.share_outlined),
                      title: const Text('Share Festival'),
                      onTap: () {
                        Navigator.pop(context);
                        shareText();
                      },
                    )),
                Visibility(
                    visible: isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.delete_forever_outlined),
                      title: const Text('Delete Fest'),
                      onTap: () async {
                        Navigator.pop(context);
                        await confirmPopup(context, deleteFest, "Delete Fest");
                      },
                    )),
              ],
            ),
          );
        });
  }
}
