import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/club/member/member_item.dart';
import 'package:learningx_flutter_app/api/model/member_model.dart';
import 'package:learningx_flutter_app/api/provider/club_member_provider.dart';

class RequestedMemberPage extends ConsumerStatefulWidget {
  final String id;
  const RequestedMemberPage({super.key, required this.id});
  @override
  ConsumerState<RequestedMemberPage> createState() => _RequestedMemberState();
}

class _RequestedMemberState extends ConsumerState<RequestedMemberPage> {
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
        .read(clubMemberProvider("${widget.id}/members?active=false").notifier);
    if (memberNotifier.isLoading) {
      //  already fetching or fetched, no need to refresh
      return;
    }
    // not fetched, refresh
    await memberNotifier.fetchMembers("${widget.id}/members?active=false");
  }

  void handleRemoveMember(String id) async {
    ref
        .read(clubMemberProvider("${widget.id}/members?active=false").notifier)
        .removeMember(id);
  }

  @override
  Widget build(BuildContext context) {
    var members =
        ref.watch(clubMemberProvider("${widget.id}/members?active=false"));

    return Scaffold(
      body: Center(
          child: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          Member member = members[index];
          return MemberItemWidget(
            member: member,
            isClub: true,
            isAdmin: true,
            handleRefresh: _refresh,
          );
        },
      )),
    );
  }
}
