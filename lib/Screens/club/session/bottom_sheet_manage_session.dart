import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/Screens/club/session/session_form.dart';
import 'package:learningx_flutter_app/Screens/common/report_form.dart';
import 'package:learningx_flutter_app/api/common/confirm_popup.dart';
import 'package:learningx_flutter_app/api/common/launch_url.dart';
import 'package:learningx_flutter_app/api/model/session_model.dart';

class BottomSheetManageSession {
  void showBottomSheet(BuildContext context, Session session, bool isAdmin,
      void Function(String) onRemoveSession) {
    Future<void> deleteSession() async {
      onRemoveSession(session.id);
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
                  session.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Text(session.club.clubName),
                Visibility(
                    visible: session.location == "online" &&
                        session.sessionLink.isNotEmpty,
                    child: ListTile(
                      leading: const Icon(Icons.login),
                      title: const Text('Join Session'),
                      onTap: () {
                        Navigator.pop(context);
                        LaunchUrl.openUrl(session.sessionLink);
                      },
                    )),
                Visibility(
                    visible: !isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.report_outlined),
                      title: const Text('Report Session'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReportActivity(
                                    id: session.id,
                                    reportOn: "session",
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: const Text('Manage Session'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SessionFormActivity(
                                    session: session,
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Delete Session'),
                      onTap: () async {
                        Navigator.pop(context);
                        await confirmPopup(
                            context, deleteSession, "Delete Session");
                      },
                    )),
              ],
            ),
          );
        });
  }
}
