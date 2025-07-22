import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/common/person_item.dart';
import 'package:learningx_flutter_app/api/model/event_model.dart';
import 'package:learningx_flutter_app/api/model/user_modal.dart';
import 'package:learningx_flutter_app/api/provider/event_provider.dart';
import 'package:learningx_flutter_app/api/provider/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManageEventAdmin extends ConsumerStatefulWidget {
  final Event event;
  const ManageEventAdmin({super.key, required this.event});
  @override
  ConsumerState<ManageEventAdmin> createState() => _ManageEventAdminState();
}

class _ManageEventAdminState extends ConsumerState<ManageEventAdmin> {
  final TextEditingController textEditingController = TextEditingController();
  List<User> admin = [];
  List<User> _filteredItems = [];
  String _searchQuery = "";
  String _currentUserId = "";

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    setState(() {
      admin = widget.event.admin;
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('id') ?? "";
    });
  }

  void _filterItems(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void handleRefreshPage(user, toAdd) {
    setState(() {
      _searchQuery = "";
      textEditingController.text = "";
    });
    if (toAdd) {
      setState(() {
        admin = [...admin, user];
      });
    } else {
      setState(() {
        admin = admin.where((item) => item.id != user.id).toList();
      });
    }
  }

  Future<void> handleManageAdmin(User user, bool toAdd) async {
    handleRefreshPage(user, toAdd);
    Map<String, dynamic> map = HashMap();
    if (toAdd) {
      widget.event.admin.add(user);
    } else {
      widget.event.admin.removeWhere((admin) => admin.id == user.id);
    }
    map['admin'] = widget.event.admin;
    map['_id'] = widget.event.id;
    updateEventApi(context, map);
  }

  @override
  Widget build(BuildContext context) {
    final userAsyncValue = ref.watch(userProvider(_searchQuery.isNotEmpty
        ? "?displayName[\$regex]=.*$_searchQuery.*&displayName[\$options]=i"
        : ""));
    userAsyncValue.whenData((data) {
      setState(() {
        _filteredItems = data;
      });
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Admin"),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                contentPadding: const EdgeInsets.all(8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                _filterItems(value);
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount:
                    _searchQuery.isEmpty ? admin.length : _filteredItems.length,
                itemBuilder: (context, index) {
                  if (_searchQuery.isEmpty) {
                    User user = admin[index];
                    return PersonItemWidget(
                      user: user,
                      isAdmin: widget.event.admin
                          .any((item) => item.id == _currentUserId),
                      isUserAdmin:
                          widget.event.admin.any((item) => item.id == user.id),
                      manageAdmin: handleManageAdmin,
                    );
                  } else {
                    User user = _filteredItems[index];
                    return PersonItemWidget(
                      user: user,
                      isAdmin: widget.event.admin
                          .any((item) => item.id == _currentUserId),
                      isUserAdmin:
                          widget.event.admin.any((item) => item.id == user.id),
                      manageAdmin: handleManageAdmin,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
