import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/Screens/college/college_about_fragment.dart';
import 'package:learningx_flutter_app/Screens/college/college_form.dart';
import 'package:learningx_flutter_app/Screens/college/college_selection_search.dart';
import 'package:learningx_flutter_app/Screens/college/manage_college_admin.dart';
import 'package:learningx_flutter_app/Screens/common/qr_creator.dart';
import 'package:learningx_flutter_app/Screens/common/report_form.dart';
import 'package:learningx_flutter_app/Screens/common/view_admin_page.dart';
import 'package:learningx_flutter_app/api/model/college_model.dart';

class BottomSheetCollegeInfo {
  void showBottomSheet(
      BuildContext context, College college, bool isAdmin, bool isYourCollege) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          void shareText() {
            String text =
                "to discover clubs and events of the campus ${college.collegeName} !\n\n https://clubchat.live/college/${college.id}";
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => QrCreator(
                        appBarText: "Share Campus",
                        sharedText: text,
                        url: "https://clubchat.live/college/${college.id}",
                        imageUrl: college.collegeImg,
                      )),
            );
          }

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
                  college.collegeName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                Text(college.city.address),
                const SizedBox(height: 8),
                Visibility(
                    visible: isYourCollege,
                    child: ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('Campus Info'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CollegeAboutFragment(
                              college: college,
                              isMyCampus: true,
                            ),
                          ),
                        );
                      },
                    )),
                Visibility(
                    visible: !isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.report),
                      title: const Text('Report Campus Page'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReportActivity(
                                    id: college.id,
                                    reportOn: "college",
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: !isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.remove_red_eye_outlined),
                      title: const Text('View Campus Admin'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewAdminPage(
                                    admin: college.admin,
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('Edit Campus Page'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CollegeFormActivity(
                                    college: college,
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: const Text('Manage Campus Admin'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ManageCollegeAdmin(
                                    college: college,
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: false,
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
                Visibility(
                    visible: true,
                    child: ListTile(
                      leading: const Icon(Icons.share_outlined),
                      title: const Text('Share Campus'),
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
