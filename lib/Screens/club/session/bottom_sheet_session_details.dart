import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/Screens/club/session/bottom_sheet_manage_session.dart';
import 'package:learningx_flutter_app/api/common/launch_url.dart';
import 'package:learningx_flutter_app/api/model/session_model.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';

class SessionDetailsWidget {
  void showBottomSheet(BuildContext context, Session session, bool isAdmin,
      void Function(String) onRemoveSession) {
    var location = "online";
    if (session.location == "offline") {
      location = session.venue;
    }
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                Image.network(
                  session.sessionImg,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        session.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow
                            .ellipsis, // Ensures long text is truncated
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert,
                        size: 20,
                      ),
                      onPressed: () {
                        final BottomSheetManageSession manageSession =
                            BottomSheetManageSession();
                        manageSession.showBottomSheet(
                            context, session, isAdmin, onRemoveSession);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.apartment_outlined,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      session.club.clubName,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_outlined,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Utils.formatDate(session.startedAtDate),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      location,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      session.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (session.location == "online" &&
                    session.sessionLink.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        LaunchUrl.openUrl(session.sessionLink);
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Join Session'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          );
        });
  }
}
