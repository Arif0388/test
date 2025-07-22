import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/Screens/club/member/active_member_page.dart';
import 'package:learningx_flutter_app/Screens/club/member/requested_member_page.dart';

class ClubMemberActivity extends StatefulWidget {
  final String id;
  final bool isAdmin;

  const ClubMemberActivity({
    super.key,
    required this.id,
    required this.isAdmin,
  });

  @override
  State<ClubMemberActivity> createState() => _ClubMemberActivityState();
}

class _ClubMemberActivityState extends State<ClubMemberActivity>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    if (widget.isAdmin) {
      _tabController = TabController(length: 2, vsync: this);
    }
  }

  @override
  void dispose() {
    if (widget.isAdmin) {
      _tabController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Club members'),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        elevation: 0,
      ),
      body: widget.isAdmin
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Members'),
                    Tab(text: 'Requested'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ActiveMemberPage(
                        id: widget.id,
                        isAdmin: widget.isAdmin,
                      ),
                      RequestedMemberPage(
                        id: widget.id,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ActiveMemberPage(
              id: widget.id,
              isAdmin: widget.isAdmin,
            ),
    );
  }
}
