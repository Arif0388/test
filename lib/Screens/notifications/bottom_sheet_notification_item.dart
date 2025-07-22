import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/Screens/common/report_form.dart';
import 'package:learningx_flutter_app/api/model/notification_model.dart';
import 'package:learningx_flutter_app/api/provider/notification_provider.dart';

class BottomSheetNotificationItem {
  void showBottomSheet(BuildContext context, NotificationModel notification,
      void Function(String) onRemoveItem) {
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
                    visible: true,
                    child: ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Remove this notification'),
                      onTap: () async {
                        Navigator.pop(context);
                        onRemoveItem(notification.id);
                        await deleteNotificationApi(context, notification.id);
                      },
                    )),
                Visibility(
                    visible: true,
                    child: ListTile(
                      leading: const Icon(Icons.report_outlined),
                      title: const Text('Report Issue'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReportActivity(
                                    id: notification.id,
                                    reportOn: "notification",
                                  )),
                        );
                      },
                    )),
              ],
            ),
          );
        });
  }
}
