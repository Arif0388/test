// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:learningx_flutter_app/Screens/common/report_form.dart';
// import 'package:learningx_flutter_app/api/model/chat_room_model.dart';
//
// class BottomSheetChatPage {
//   void showBottomSheet(BuildContext context, ChatRoom chatroom,
//       int receiverAtIndex, void Function() updateChatRoom, bool isBlocked) {
//     showModalBottomSheet(
//         context: context,
//         builder: (BuildContext context) {
//           return Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(10),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Center(
//                     child: Container(
//                         width: 60,
//                         height: 8,
//                         decoration: const BoxDecoration(
//                             color: Color(0x51000000),
//                             borderRadius:
//                                 BorderRadius.all(Radius.circular(10))))),
//                 const SizedBox(height: 12),
//                 Visibility(
//                     visible: true,
//                     child: ListTile(
//                       leading: const Icon(Icons.remove_red_eye_outlined),
//                       title: const Text('View Profile'),
//                       onTap: () {
//                         Navigator.pop(context);
//                         context.push(
//                             "/profile/${chatroom.users[receiverAtIndex].id}");
//                       },
//                     )),
//                 Visibility(
//                     visible: true,
//                     child: ListTile(
//                       leading: const Icon(Icons.report_outlined),
//                       title: const Text('Report Chats'),
//                       onTap: () {
//                         Navigator.pop(context);
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => ReportActivity(
//                                     id: chatroom.id,
//                                     reportOn: "chatRoom",
//                                   )),
//                         );
//                       },
//                     )),
//                 Visibility(
//                     visible: !isBlocked,
//                     child: ListTile(
//                       leading: const Icon(Icons.block_outlined),
//                       title: const Text('Block Person'),
//                       onTap: () {
//                         Navigator.pop(context);
//                         updateChatRoom();
//                       },
//                     )),
//                 Visibility(
//                     visible: isBlocked,
//                     child: ListTile(
//                       leading: const Icon(Icons.public_outlined),
//                       title: const Text('Unblock Person'),
//                       onTap: () {
//                         Navigator.pop(context);
//                         updateChatRoom();
//                       },
//                     )),
//               ],
//             ),
//           );
//         });
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Screens/common/report_form.dart';
import 'package:learningx_flutter_app/api/model/chat_room_model.dart';

class BottomSheetChatPage {
  void showBottomSheet(BuildContext context, ChatRoom chatroom,
      int receiverAtIndex, void Function() updateChatRoom, bool isBlocked) {
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
                      leading: const Icon(Icons.remove_red_eye_outlined),
                      title: const Text('View Profile'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push(
                            "/profile/${chatroom.users[receiverAtIndex].id}");
                      },
                    )),
                Visibility(
                    visible: true,
                    child: ListTile(
                      leading: const Icon(Icons.report_outlined),
                      title: const Text('Report Chats'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReportActivity(
                                id: chatroom.id,
                                reportOn: "chatRoom",
                              )),
                        );
                      },
                    )),
                Visibility(
                    visible: !isBlocked,
                    child: ListTile(
                      leading: const Icon(Icons.block_outlined),
                      title: const Text('Block Person'),
                      onTap: () {
                        Navigator.pop(context);
                        updateChatRoom();
                      },
                    )),
                Visibility(
                    visible: isBlocked,
                    child: ListTile(
                      leading: const Icon(Icons.public_outlined),
                      title: const Text('Unblock Person'),
                      onTap: () {
                        Navigator.pop(context);
                        updateChatRoom();
                      },
                    )),
              ],
            ),
          );
        });
  }
}

