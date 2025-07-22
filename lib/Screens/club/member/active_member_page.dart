import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/club/member/member_item.dart';
import 'package:learningx_flutter_app/api/model/member_model.dart';
import 'package:learningx_flutter_app/api/provider/club_member_provider.dart';

class ActiveMemberPage extends ConsumerStatefulWidget {
  final String id;
  final bool isAdmin;
  const ActiveMemberPage({super.key, required this.id, required this.isAdmin});
  @override
  ConsumerState<ActiveMemberPage> createState() => _ActiveMemberState();
}

class _ActiveMemberState extends ConsumerState<ActiveMemberPage> {
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
        .read(clubMemberProvider("${widget.id}/members?active=true").notifier);
    if (memberNotifier.isLoading) {
      //  already fetching or fetched, no need to refresh
      return;
    }
    // not fetched, refresh
    await memberNotifier.fetchMembers("${widget.id}/members?active=true");
  }

  @override
  Widget build(BuildContext context) {
    List<Member> allMembers =
        ref.watch(clubMemberProvider("${widget.id}/members?active=true"));
    List<Member> admins = allMembers.where((member) => member.admin).toList();
    List<Member> members = allMembers.where((member) => !member.admin).toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _refresh(),
        child: CustomScrollView(
          key: const PageStorageKey<String>('clubMemberList'),
          slivers: <Widget>[
            const SliverToBoxAdapter(
              child: SizedBox(height: 8),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                      child: Text(
                        "Club Admin",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      )),
                  ...admins.map((member) {
                    return MemberItemWidget(
                      key: ValueKey(member.id),
                      member: member,
                      isClub: true,
                      isAdmin: widget.isAdmin,
                      handleRefresh: _refresh,
                    );
                  }).toList(),
                  const Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                      child: Text(
                        "Club Members",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      )),
                  ...members.map((member) {
                    return MemberItemWidget(
                      key: ValueKey(member.id),
                      member: member,
                      isClub: true,
                      isAdmin: widget.isAdmin,
                      handleRefresh: _refresh,
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
