import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/club/member/member_item.dart';
import 'package:learningx_flutter_app/api/model/member_model.dart';
import 'package:learningx_flutter_app/api/provider/club_member_provider.dart';

class AdminMemberPage extends ConsumerStatefulWidget {
  final String id;
  const AdminMemberPage({super.key, required this.id});

  @override
  ConsumerState<AdminMemberPage> createState() => _AdminMemberState();
}

class _AdminMemberState extends ConsumerState<AdminMemberPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _refresh() async {
    final memberNotifier = ref
        .read(clubMemberProvider("${widget.id}/members?admin=true").notifier);
    if (memberNotifier.isLoading) {
      //  already fetching or fetched, no need to refresh
      return;
    }
    // not fetched, refresh
    await memberNotifier.fetchMembers("${widget.id}/members?admin=true");
  }

  void handleRemoveMember(String id) async {
    ref
        .read(clubMemberProvider("${widget.id}/members?admin=true").notifier)
        .removeMember(id);
  }

  @override
  Widget build(BuildContext context) {
    List<Member> members =
        ref.watch(clubMemberProvider("${widget.id}/members?admin=true"));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Club Admin'),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        elevation: 0,
      ),
      body: RefreshIndicator(
          onRefresh: () => _refresh(),
          child: Center(
              child: ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              Member member = members[index];
              return MemberItemWidget(
                member: member,
                isClub: true,
                isAdmin: false,
                handleRefresh: _refresh,
              );
            },
          ))),
    );
  }
}
