import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Screens/common/qr_creator.dart';
import 'package:learningx_flutter_app/Screens/common/report_form.dart';
import 'package:learningx_flutter_app/Screens/common/view_admin_page.dart';
import 'package:learningx_flutter_app/Screens/event/comment/event_comment_page.dart';
import 'package:learningx_flutter_app/Screens/event/form/club_workshop_form.dart';
import 'package:learningx_flutter_app/Screens/event/form/event_form_page.dart';
import 'package:learningx_flutter_app/Screens/event/manage/manage_event_admin.dart';
import 'package:learningx_flutter_app/Screens/event/manage/manage_event_team.dart';
import 'package:learningx_flutter_app/Screens/event/manage/upload_result.dart';
import 'package:learningx_flutter_app/api/common/confirm_popup.dart';
import 'package:learningx_flutter_app/api/model/event_model.dart';
import 'package:learningx_flutter_app/api/provider/event_provider.dart';

class BottomSheetEventInfo {
  void showBottomSheet(BuildContext context, Event event, bool isAdmin,
      bool isNietCollegeAdmin, Function? onRemove, Function updateEvent) {
    var hostedBy = "";
    var hostLink = "/home";
    if (event.club != null) {
      hostedBy = event.club!.clubName;
      hostLink = "/club/about/${event.club!.id}";
    } else if (event.festival != null) {
      hostedBy = event.festival!.festName;
      hostLink = "/club/fest/${event.festival!.id}";
    } else if (event.college != null) {
      hostedBy = event.college!.collegeName;
      hostLink = "/college/${event.college!.id}";
    }

    void shareText() {
      String text =
          "to register event named ${event.eventTitle} !\n\n https://clubchat.live/events/${event.id}";
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => QrCreator(
                  appBarText: "Share Event",
                  sharedText: text,
                  url: "https://clubchat.live/events/${event.id}",
                  imageUrl: event.eventImg,
                )),
      );
    }

    Future<void> deleteEvent() async {
      await deleteEventApi(context, event.id);
      if (onRemove != null) {
        onRemove(event.id);
      }
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
                  event.eventTitle,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Text(hostedBy),
                Visibility(
                    visible: true,
                    child: ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('View details of Host'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push(hostLink);
                      },
                    )),
                Visibility(
                    visible: false,
                    child: ListTile(
                      leading: const Icon(Icons.favorite_outline),
                      title: const Text('Add to favourites'),
                      onTap: () {
                        Navigator.pop(context);
                        // Implement your logic
                      },
                    )),
                Visibility(
                    visible: true,
                    child: ListTile(
                      leading: const Icon(Icons.comment_outlined),
                      title: const Text('Chat about this event'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EventCommentActivity(event: event)),
                        );
                      },
                    )),
                Visibility(
                    visible: isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('Manage Event'),
                      onTap: () {
                        Navigator.pop(context);
                        if (event.eventType == "workshop") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ClubWorkshopForm(
                                    formData: {"eventId": event.id})),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EventFormPage(
                                    formData: {"eventId": event.id})),
                          );
                        }
                      },
                    )),
                Visibility(
                    visible: isAdmin && event.takeRegistration,
                    child: ListTile(
                      leading: const Icon(Icons.groups),
                      title: const Text('Registered Teams'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EventRegisteredTeams(eventId: event.id)),
                        );
                      },
                    )),
                Visibility(
                    visible: isAdmin &&
                        event.eventType == "contest" &&
                        event.stages != null &&
                        event.stages!.isNotEmpty,
                    child: ListTile(
                      leading: const Icon(Icons.upload_file_outlined),
                      title: const Text('Upload Result'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EventResultForm(
                                    eventId: event.id,
                                    stages: event.stages!,
                                    results: event.results ?? [],
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
                              builder: (context) => ManageEventAdmin(
                                    event: event,
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: !isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.group_outlined),
                      title: const Text('View Admin'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewAdminPage(
                                    admin: event.admin,
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: isNietCollegeAdmin && !event.verified,
                    child: ListTile(
                      leading: const Icon(Icons.verified_outlined),
                      title: const Text('Approve event'),
                      onTap: () async {
                        Navigator.pop(context);
                        await updateEvent(true);
                      },
                    )),
                Visibility(
                    visible: isNietCollegeAdmin && event.verified,
                    child: ListTile(
                      leading: const Icon(Icons.remove_circle_outline_outlined),
                      title: const Text('Remove from College Page'),
                      onTap: () async {
                        Navigator.pop(context);
                        await updateEvent(false);
                      },
                    )),
                Visibility(
                    visible: !isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.report_outlined),
                      title: const Text('Report Event'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReportActivity(
                                    id: event.id,
                                    reportOn: "event",
                                  )),
                        );
                      },
                    )),
                Visibility(
                    visible: true,
                    child: ListTile(
                      leading: const Icon(Icons.share_outlined),
                      title: const Text('Share Event'),
                      onTap: () {
                        Navigator.pop(context);
                        shareText();
                      },
                    )),
                Visibility(
                    visible: isAdmin && event.registerdTeamLead!.isEmpty,
                    child: ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Delete Event'),
                      onTap: () async {
                        Navigator.pop(context);
                        await confirmPopup(
                            context, deleteEvent, "Delete Event");
                      },
                    )),
              ],
            ),
          );
        });
  }
}
