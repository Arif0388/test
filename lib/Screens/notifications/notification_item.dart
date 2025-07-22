import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Screens/notifications/bottom_sheet_notification_item.dart';
import 'package:learningx_flutter_app/api/model/notification_model.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';

class NotificationItemWidget extends StatelessWidget {
  final NotificationModel item;
  final void Function(String) onRemoveItem;
  const NotificationItemWidget(
      {super.key, required this.item, required this.onRemoveItem});

  @override
  Widget build(BuildContext context) {
    var link = "/home";
    String img = "https://learningx-s3.s3.ap-south-1.amazonaws.com/user.png";
    int othersCount = 0;
    String summary = "";
    // ignore: unused_local_variable
    String? id;

    if (item.event != null) {
      img = item.event!.eventImg;
    } else if (item.club != null) {
      img = item.club!.clubImg;
    } else if (item.userBy != null) {
      img = item.userBy!.userImg;
    }

    if (item.post != null) {
      link = "/posts/${item.post!.id}";
      id = item.post!.id;
      if (item.msg == "liked your post.") {
        othersCount = item.post!.likes!.length - 1;
      } else {
        othersCount = item.post!.commentsCount - 1;
      }
      if (othersCount > 0) {
        summary =
            "${item.userBy!.firstname} ${item.userBy!.lastname} and $othersCount others ${item.msg}.";
      } else {
        summary =
            "${item.userBy!.firstname} ${item.userBy!.lastname} ${item.msg}.";
      }
    } else if (item.club != null && item.userBy != null) {
      link = "/club/about/${item.club!.id}";
      id = item.club!.id;
      summary =
          "${item.userBy!.firstname} ${item.userBy!.lastname} ${item.msg}.";
    } else if (item.club != null && item.userBy == null) {
      link = "/club/about/${item.club!.id}";
      id = item.club!.id;
      summary = "${item.club!.clubName} ${item.msg}.";
    } else if (item.event != null && item.userBy != null) {
      link = "/events/${item.event!.id}";
      id = item.event!.id;
      summary =
          "${item.userBy!.firstname} ${item.userBy!.lastname} ${item.msg}.";
    } else if (item.event != null && item.userBy == null) {
      link = "/events/${item.event!.id}";
      id = item.event!.id;
      summary = "${item.event!.eventTitle} ${item.msg}.";
    } else {
      summary = item.msg;
    }
    return GestureDetector(
        onTap: () {
          context.push(link);
        },
        child: Container(
          margin: const EdgeInsets.all(1),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(left: 8),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(img),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Utils.getTimeAgo(item.createdAtDate),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    final BottomSheetNotificationItem sheetNotificationItem =
                        BottomSheetNotificationItem();
                    sheetNotificationItem.showBottomSheet(
                        context, item, onRemoveItem);
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
