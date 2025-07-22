import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Screens/common/report_form.dart';
import 'package:learningx_flutter_app/api/common/confirm_popup.dart';
import 'package:learningx_flutter_app/api/model/member_model.dart';
import 'package:learningx_flutter_app/api/provider/channel_member_provider.dart';

class BottomSheetChannelMemberItem {
  void showBottomSheet(BuildContext context, Member member, bool isAdmin,
      bool isCurrentMember, void Function() handleRefresh) {
    final TextEditingController roleController = TextEditingController();
    AlertDialog alert = AlertDialog(
      title: const Text("Change Member Role"),
      content: TextField(
        controller: roleController,
        decoration: InputDecoration(
          label: const Text('Member Role*'),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        maxLength: 50,
      ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("Save"),
          onPressed: () async {
            Navigator.of(context).pop();
            Map<String, dynamic> map = HashMap();
            map['channel'] = member.channel;
            map["_id"] = member.id;
            map["role"] = roleController.text;
            await updateChannelMemberApi(context, map);
            handleRefresh();
          },
        )
      ],
    );
    Future<void> removeMember() async {
      Map<String, dynamic> map = HashMap();
      map['channel'] = member.channel;
      map['_id'] = member.user.id;
      await deleteChannelMemberApi(context, map);
      handleRefresh();
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
                    visible: !isCurrentMember,
                    child: ListTile(
                      leading: const Icon(Icons.remove_red_eye_outlined),
                      title: const Text('View Profile'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push("/profile/${member.user.id}");
                      },
                    )),
                Visibility(
                    visible: isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.change_circle_outlined),
                      title: const Text('Change Role'),
                      onTap: () {
                        Navigator.pop(context);
                        roleController.text = member.role;
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return alert;
                          },
                        );
                      },
                    )),
                Visibility(
                    visible: member.active && !member.admin && isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.person_add),
                      title: const Text('Make Admin'),
                      onTap: () async {
                        Navigator.pop(context);
                        Map<String, dynamic> map = HashMap();
                        map['channel'] = member.channel;
                        map['admin'] = true;
                        map["_id"] = member.id;
                        map["role"] = "Admin";
                        await updateChannelMemberApi(context, map);
                        handleRefresh();
                      },
                    )),
                Visibility(
                    visible: member.admin && isAdmin && !isCurrentMember,
                    child: ListTile(
                      leading: const Icon(Icons.person_remove),
                      title: const Text('Remove from admin'),
                      onTap: () async {
                        Navigator.pop(context);
                        Map<String, dynamic> map = HashMap();
                        map['channel'] = member.channel;
                        map['admin'] = false;
                        map["_id"] = member.id;
                        map["role"] = "Member";
                        await updateChannelMemberApi(context, map);
                        handleRefresh();
                      },
                    )),
                Visibility(
                    visible: member.active && !member.admin && isAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.person_remove),
                      title: const Text('Remove from Channel'),
                      onTap: () async {
                        Navigator.pop(context);
                        await confirmPopup(
                            context, removeMember, "Remove member");
                      },
                    )),
                Visibility(
                    visible: !isCurrentMember,
                    child: ListTile(
                      leading: const Icon(Icons.report_outlined),
                      title: const Text('Report Member'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReportActivity(
                                    id: member.id,
                                    reportOn: "channelMemebr",
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
