import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/club/channel/add_member_to_channel.dart';
import 'package:learningx_flutter_app/Screens/club/member/member_item.dart';
import 'package:learningx_flutter_app/api/model/channel_model.dart';
import 'package:learningx_flutter_app/api/model/member_model.dart';
import 'package:learningx_flutter_app/api/provider/channel_member_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChannelMemberActivity extends ConsumerStatefulWidget {
  final Channel channel;
  final String clubName;
  const ChannelMemberActivity(
      {super.key, required this.channel, required this.clubName});

  @override
  ConsumerState<ChannelMemberActivity> createState() =>
      _ChannelMemberActivityState();
}

class _ChannelMemberActivityState extends ConsumerState<ChannelMemberActivity>
    with SingleTickerProviderStateMixin {
  String _currentUserId = "";
  bool isAdmin = false;

  @override
  void initState() {
    _loadCurrentUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
    super.initState();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString("id") ?? "";
      isAdmin = widget.channel.admin.contains(_currentUserId);
    });
  }

  Future<void> _refresh() async {
    final memberNotifier = ref
        .read(channelMemberProvider("${widget.channel.id}/members").notifier);
    if (memberNotifier.isLoading) {
      return; // Already fetching or fetched
    }
    await memberNotifier.fetchMembers("${widget.channel.id}/members");
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> appBarActions = [
      IconButton(
        icon: const Icon(Icons.person_add_outlined),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddMemberPage(
                      channel: widget.channel,
                    )),
          );
        },
      ),
      const SizedBox(
        width: 8,
      ),
    ];

    List<Member> allMembers =
        ref.watch(channelMemberProvider("${widget.channel.id}/members"));
    List<Member> admins = allMembers.where((member) => member.admin).toList();
    List<Member> members = allMembers.where((member) => !member.admin).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Channel members'),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        actions: appBarActions,
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(),
        child: CustomScrollView(
          key: const PageStorageKey<String>('channelMemberList'),
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
                        "Channel Admin",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      )),
                  ...admins.map((member) {
                    return MemberItemWidget(
                      key: ValueKey(member.id),
                      member: member,
                      isClub: false,
                      isAdmin: isAdmin,
                      handleRefresh: _refresh,
                    );
                  }).toList(),
                  const Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 16.0),
                      child: Text(
                        "Channel Members",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      )),
                  ...members.map((member) {
                    return MemberItemWidget(
                      key: ValueKey(member.id),
                      member: member,
                      isClub: false,
                      isAdmin: isAdmin,
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
