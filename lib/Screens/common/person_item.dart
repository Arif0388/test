import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/Screens/common/bottom_sheet_admin.dart';
import 'package:learningx_flutter_app/api/model/user_modal.dart';

class PersonItemWidget extends StatelessWidget {
  final User user;
  final bool isAdmin;
  final bool isUserAdmin;
  final void Function(User, bool)? manageAdmin;
  const PersonItemWidget(
      {super.key,
      required this.user,
      required this.isAdmin,
      required this.isUserAdmin,
      this.manageAdmin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0),
      child: GestureDetector(
          onTap: () {},
          child: Card(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(left: 4, right: 20, top: 4),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                          user.userImg), // Replace with your image asset
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.userNameId,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      BottomSheetAdminItem adminItem = BottomSheetAdminItem();
                      adminItem.showBottomSheet(
                          context, user, isAdmin, isUserAdmin, manageAdmin!);
                    },
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
