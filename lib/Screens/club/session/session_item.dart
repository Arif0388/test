import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/club/session/bottom_sheet_session_details.dart';
import 'package:learningx_flutter_app/api/model/session_model.dart';
import 'package:learningx_flutter_app/api/provider/session_provider.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';

class SessionItemWidget extends ConsumerStatefulWidget {
  final Session session;
  final bool isAdmin;
  const SessionItemWidget(
      {super.key, required this.session, required this.isAdmin});

  @override
  ConsumerState<SessionItemWidget> createState() => _SessionItemWidgetState();
}

class _SessionItemWidgetState extends ConsumerState<SessionItemWidget> {
  Future<void> deleteSession(String sessionId) async {
    await ref
        .read(sessionProvider("${widget.session.channel}/session").notifier)
        .deleteSessionApi(
            context, {"_id": sessionId, "channel": widget.session.channel});
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var location = "online";
    if (widget.session.location == "offline") {
      location = widget.session.venue;
    }
    return GestureDetector(
        onTap: () {
          final SessionDetailsWidget sessionDetailsWidget =
              SessionDetailsWidget();
          sessionDetailsWidget.showBottomSheet(
              context, widget.session, widget.isAdmin, deleteSession);
        },
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 75,
                  margin: const EdgeInsets.only(right: 16),
                  child: Image.network(
                    widget.session.sessionImg,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.session.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            location,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.purple[700],
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                              child: Text(
                            Utils.formatDate(widget.session.startedAtDate),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.purple[700],
                              overflow: TextOverflow.visible,
                            ),
                            overflow: TextOverflow.visible,
                            softWrap: true,
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
