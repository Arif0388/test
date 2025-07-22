import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/api/model/channel_model.dart';
import 'package:learningx_flutter_app/api/model/club_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChannelItemWidget extends StatefulWidget {
  final Channel channel;
  final ClubItem clubItem;
  const ChannelItemWidget(
      {super.key, required this.channel, required this.clubItem});
  @override
  State<ChannelItemWidget> createState() => _ChannelItemWidgetState();
}

class _ChannelItemWidgetState extends State<ChannelItemWidget> {
  String _currentUserId = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUser();
    });
  }

  void handleUnreadCount() {
    if (mounted) {
      setState(() {
        widget.channel.unreadCount = 0;
      });
    }
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _currentUserId = prefs.getString("id") ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget icon = const Icon(
      Icons.tag_outlined,
      size: 24,
    );
    if (widget.channel.privacy == "private") {
      icon = const Icon(
        Icons.lock_outline,
        size: 24,
      );
    } else if (widget.channel.permission == "private") {
      icon = Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Image.asset(
            'assets/images/announcement.png',
            width: 18,
            height: 18,
          ));
    }
    return Container(
      margin: EdgeInsets.zero,
      child: Stack(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.only(left: 20),
            leading: icon,
            title: Text(widget.channel.name),
            onTap: () {
              if (widget.channel.members.contains(_currentUserId)) {
                handleUnreadCount();
                context.push(
                    "/club/${widget.clubItem.id}/discussion/${widget.channel.id}",
                    extra: {
                      'channel': widget.channel,
                      'clubItem': widget.clubItem,
                    });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('You are not member of this channel!'),
                ));
              }
            },
            onLongPress: () {},
          ),
          if (widget.channel.unreadCount > 0)
            Positioned(
              right: 8.0,
              top: 12.0,
              child: Container(
                margin: const EdgeInsets.all(4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 18,
                ),
                child: Text(
                  '${widget.channel.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
