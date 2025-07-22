import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/club/channel/bottom_sheet_manage_channel_item.dart';
import 'package:learningx_flutter_app/Screens/club/channel/channel_form.dart';
import 'package:learningx_flutter_app/Screens/club/form/club_form2.dart';
import 'package:learningx_flutter_app/api/model/channel_model.dart';
import 'package:learningx_flutter_app/api/model/club_model.dart';
import 'package:learningx_flutter_app/api/provider/channel_provider.dart';

class SetUpChannelsPage extends ConsumerStatefulWidget {
  final ClubItem clubItem;
  const SetUpChannelsPage({super.key, required this.clubItem});
  @override
  ConsumerState<SetUpChannelsPage> createState() => _SetUpChannelsPageState();
}

class _SetUpChannelsPageState extends ConsumerState<SetUpChannelsPage> {
  void handleDeleteChannel(String id) async {
    await ref
        .read(channelProvider(widget.clubItem.id).notifier)
        .deleteChannelApi(context, id);
  }

  @override
  Widget build(BuildContext context) {
    final channels = ref.watch(channelProvider(widget.clubItem.id));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Setup Channels"),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: ListView.builder(
            itemCount: channels.length, // Replace with your actual item count
            itemBuilder: (context, index) {
              ChannelWithClub channel = channels[index];
              return Stack(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 8),
                    leading: Icon(
                      channel.privacy == "private"
                          ? Icons.lock_outline
                          : channel.permission == "private"
                              ? Icons.barcode_reader
                              : Icons.tag,
                      size: 24,
                    ),
                    title: Text(channel.name),
                  ),
                  Positioned(
                    right: 8.0,
                    bottom: 8.0,
                    child: IconButton(
                      icon: const Icon(Icons.more_horiz_outlined, size: 24),
                      onPressed: () {
                        final BottomSheetManageChannelItem
                            sheetManageChannelItem =
                            BottomSheetManageChannelItem();
                        sheetManageChannelItem.showBottomSheet(
                            context,
                            Channel(
                                id: channel.id,
                                name: channel.name,
                                privacy: channel.privacy,
                                permission: channel.permission,
                                club: channel.club.id,
                                admin: channel.admin,
                                members: channel.members,
                                unreadCount: channel.unreadCount),
                            widget.clubItem,
                            true,
                            handleDeleteChannel);
                      },
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChannelFormScreen(
                        clubId: widget.clubItem.id,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Colors.blue,
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  foregroundColor: Colors.blue,
                  side: const BorderSide(
                      color: Colors.blue), // Set the border color
                ),
                label: const Text(
                  'Add Channel',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(width: 8), // Adds spacing between the buttons
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ClubForm2Activity(
                              clubId: widget.clubItem.id,
                              isNewClub: true,
                            )),
                  );
                },
                icon: const Icon(
                  Icons.navigate_next,
                  color: Colors.white,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                label: const Text(
                  'Next',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
