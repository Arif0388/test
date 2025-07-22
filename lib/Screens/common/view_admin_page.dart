import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/common/person_item.dart';
import 'package:learningx_flutter_app/api/model/user_modal.dart';

class ViewAdminPage extends ConsumerStatefulWidget {
  final List<User> admin;
  const ViewAdminPage({super.key, required this.admin});
  @override
  ConsumerState<ViewAdminPage> createState() => _ViewAdminState();
}

class _ViewAdminState extends ConsumerState<ViewAdminPage> {
  void handleManageAdmin(user, toAdd) {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Admin"),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
      ),
      body: ListView.builder(
        itemCount: widget.admin.length,
        itemBuilder: (context, index) {
          User user = widget.admin[index];
          return PersonItemWidget(
            user: user,
            isAdmin: false,
            isUserAdmin: false,
            manageAdmin: handleManageAdmin,
          );
        },
      ),
    );
  }
}
