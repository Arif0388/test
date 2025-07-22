import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/Screens/club/member/member_item.dart';
import 'package:learningx_flutter_app/api/model/channel_model.dart';
import 'package:learningx_flutter_app/api/model/member_model.dart';
import 'package:learningx_flutter_app/api/provider/channel_member_provider.dart';
import 'package:learningx_flutter_app/api/provider/channel_provider.dart';

class AddMemberPage extends StatefulWidget {
  final Channel channel;
  const AddMemberPage({super.key, required this.channel});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  var members = [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  _loadMembers() async {
    final fetchedChannel = await fetchSingleChannelApi(widget.channel.id);
    final Map<String, dynamic> map = {
      '_id': widget.channel.club,
      'channelMembers': fetchedChannel.members,
    };
    var data = await fetchMembersToAddToChannelsApi(map);
    setState(() {
      members = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add members'),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        elevation: 0,
      ),
      body: Center(
          child: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          Member member = members[index];
          return MemberItemWidget(
            member: member,
            isClub: true,
            isAdmin: true,
            channel: widget.channel.id,
            handleRefresh: _loadMembers,
          );
        },
      )),
    );
  }
}
