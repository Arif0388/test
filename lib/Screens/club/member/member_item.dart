import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/Screens/club/member/bottom_sheet_channel_member.dart';
import 'package:learningx_flutter_app/Screens/club/member/bottom_sheet_club_member.dart';
import 'package:learningx_flutter_app/api/model/member_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemberItemWidget extends StatefulWidget {
  final Member member;
  final bool isClub;
  final bool isAdmin;
  final String? channel;
  final void Function() handleRefresh;
  const MemberItemWidget(
      {super.key,
      required this.member,
      required this.isClub,
      required this.isAdmin,
      this.channel,
      required this.handleRefresh});

  @override
  State<MemberItemWidget> createState() => _MemberItemWidgetState();
}

class _MemberItemWidgetState extends State<MemberItemWidget> {
  String _currentUserId = "";
  bool isCurrentMember = false;

  @override
  void initState() {
    _loadCurrentUser();
    super.initState();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString("id") ?? "";
      isCurrentMember = widget.member.user.id == _currentUserId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(0),
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture
                Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blueAccent, width: 2),
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.member.user.userImg),
                  ),
                ),
                // Member Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.member.user.displayName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.member.user.userNameId,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Member Role Highlighted
                      if (widget.member.admin)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: widget.member.admin
                                ? Colors.blueAccent
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.member.admin
                                ? widget.member.role.toUpperCase()
                                : "Member",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: widget.member.admin
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Action Button
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    if (widget.isClub) {
                      BottomSheetClubMemberItem clubMemberItem =
                          BottomSheetClubMemberItem();
                      clubMemberItem.showBottomSheet(context, widget.member,
                          widget.isAdmin, isCurrentMember, widget.channel, widget.handleRefresh);
                    } else {
                      BottomSheetChannelMemberItem channelMemberItem =
                          BottomSheetChannelMemberItem();
                      channelMemberItem.showBottomSheet(context, widget.member,
                          widget.isAdmin, isCurrentMember, widget.handleRefresh);
                    }
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
