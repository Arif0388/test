import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/api/common/confirm_popup.dart';
import 'package:learningx_flutter_app/api/model/user_modal.dart';

class BottomSheetAdminItem {
  void showBottomSheet(BuildContext context, User user, bool isAdmin,
      bool isUserAdmin, void Function(User, bool) manageAdmin) {
    Future<void> removeAdmin() async {
      manageAdmin(user, false);
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
                    visible: true,
                    child: ListTile(
                      leading: const Icon(Icons.remove_red_eye_outlined),
                      title: const Text('View Profile'),
                      onTap: () {
                        Navigator.pop(context);
                        context.push("/profile/${user.id}");
                      },
                    )),
                Visibility(
                    visible: isAdmin && isUserAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text('Remove from admin'),
                      onTap: () async {
                        Navigator.pop(context);
                        await confirmPopup(
                            context, removeAdmin, "Remove Admin");
                      },
                    )),
                Visibility(
                    visible: isAdmin && !isUserAdmin,
                    child: ListTile(
                      leading: const Icon(Icons.person_add_outlined),
                      title: const Text('Add as Admin'),
                      onTap: () async {
                        Navigator.pop(context);
                        manageAdmin(user, true);
                      },
                    )),
              ],
            ),
          );
        });
  }
}
