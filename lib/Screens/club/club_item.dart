import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Screens/club/bottom_sheet_club_item.dart';
import 'package:learningx_flutter_app/Screens/club/channel/channel_item.dart';
import 'package:learningx_flutter_app/api/model/channel_model.dart';
import 'package:learningx_flutter_app/api/model/club_model.dart';
import 'package:learningx_flutter_app/api/provider/club_feed_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClubItemWidget extends ConsumerStatefulWidget {
  final ClubItem club;
  const ClubItemWidget({super.key, required this.club});

  @override
  ConsumerState<ClubItemWidget> createState() => _ClubItemWidgetState();
}

class _ClubItemWidgetState extends ConsumerState<ClubItemWidget> {
  bool showAllChannels = false;
  int channelSize = 0;
  String _currentUserId = "";
  bool isAdmin = false;

  @override
  void initState() {
    _loadCurrentUser();
    super.initState();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('id') ?? "";
      if (widget.club.admin.contains(_currentUserId)) {
        isAdmin = true;
      }
      for (int i = 0; i < widget.club.channels.length; i++) {
        if (widget.club.channels[i].members.contains(_currentUserId)) {
          channelSize += 1;
        }
      }
    });
  }

  void removeClub(String clubId) {
    ref.read(yourClubFeedProvider.notifier).deleteClub(clubId);
  }

  void handleAboutClub() {
    if (widget.club.category == "council") {
      context.push("/council/${widget.club.id}");
    } else {
      context.push("/club/about/${widget.club.id}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4.0, right: 4.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: GestureDetector(
                    onTap: handleAboutClub,
                    child: Image.network(
                      widget.club.clubImg,
                      width: 32.0,
                      height: 32.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                    onTap: handleAboutClub,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.club.clubName,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (widget.club.collegeStatus == "verified")
                            const Icon(
                              Icons.verified_outlined,
                              size: 15,
                              color: Colors.blue,
                            ),
                          if (widget.club.category == "council")
                            const Icon(
                              Icons.settings_input_antenna,
                              size: 20,
                              color: Colors.blue,
                            ),
                        ],
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: IconButton(
                  icon: const Icon(Icons.more_horiz),
                  padding: const EdgeInsets.all(4.0),
                  onPressed: () {
                    final BottomSheetClubItem sheetClubItem =
                        BottomSheetClubItem();
                    sheetClubItem.showBottomSheet(context, widget.club, isAdmin,
                        _currentUserId, removeClub);
                  },
                ),
              ),
            ],
          ),
          const Divider(
            color: Color.fromARGB(255, 238, 238, 238),
            height: 2,
          ),
          Container(
            padding: const EdgeInsets.only(top: 0),
            child: Column(
              children: <Widget>[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      (showAllChannels || channelSize <= 3) ? channelSize : 2,
                  itemBuilder: (context, index) {
                    Channel channel = widget.club.channels
                        .where((channel) =>
                            channel.members.contains(_currentUserId))
                        .toList()[index];
                    return ChannelItemWidget(
                      key: ValueKey(channel.id),
                      channel: channel,
                      clubItem: widget.club,
                    );
                  },
                ),
                Visibility(
                  visible: channelSize > 3 && !showAllChannels,
                  child: ListTile(
                    titleAlignment: ListTileTitleAlignment.center,
                    contentPadding: const EdgeInsets.only(left: 24),
                    title: const Text(
                      'See all channels',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.blue,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        showAllChannels = true;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
