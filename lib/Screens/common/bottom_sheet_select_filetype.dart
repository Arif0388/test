// ignore_for_file: use_build_context_synchronously, library_prefixes

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learningx_flutter_app/Screens/club/discussion/group_discussion_form.dart';
import 'package:learningx_flutter_app/Screens/common/preview_file_page.dart';
import 'package:learningx_flutter_app/Screens/club/discussion/poll/poll_form.dart';
import 'package:learningx_flutter_app/Style/custom_style.dart';
import 'package:learningx_flutter_app/api/model/channel_model.dart';
import 'package:learningx_flutter_app/api/model/chat_room_model.dart';
import 'package:learningx_flutter_app/api/model/discussion_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SelectFiletypeBottomSheet {
  final picker = ImagePicker();

  Future<dynamic> goToPreviewPage(
      BuildContext context,
      String roomId,
      String? clubId,
      String? parentChatId,
      String filetype,
      String where,
      XFile? xFile,
      IO.Socket? socket) {
    return Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PreviewFilePage(
                roomId: roomId,
                clubId: clubId,
                parentChatId: parentChatId,
                filetype: filetype,
                where: where,
                xFile: xFile,
                socket: socket,
              )),
    );
  }

  void showBottomSheet(
      BuildContext context,
      String sheetOn,
      Discussion? parentChat,
      Channel? channel,
      ChatRoom? chatRoom,
      IO.Socket? socket) {
    String roomId = "";
    String? clubId;
    String? parentChatId;
    if (parentChat != null) {
      roomId = parentChat.channel;
      clubId = parentChat.club;
      parentChatId = parentChat.id;
    } else if (channel != null && parentChat == null) {
      roomId = channel.id;
      clubId = channel.club;
      parentChatId = null;
    } else if (chatRoom != null) {
      roomId = chatRoom.id;
      clubId = null;
      parentChatId = null;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Share Content',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Maximum 3 items in a row
                ),
                itemCount: _getFileOptions(sheetOn, context, roomId, clubId,
                        parentChatId, channel, socket)
                    .length,
                itemBuilder: (context, index) {
                  final option = _getFileOptions(sheetOn, context, roomId,
                      clubId, parentChatId, channel, socket)[index];
                  return _buildFileOption(
                    context,
                    icon: option['icon'] as IconData,
                    label: option['label'] as String,
                    color: option['color'] as Color,
                    onTap: option['onTap'] as VoidCallback,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getFileOptions(
      String sheetOn,
      BuildContext context,
      String roomId,
      String? clubId,
      String? parentChat,
      Channel? channel,
      IO.Socket? socket) {
    return [
      if (sheetOn == "discussion")
        {
          'icon': Icons.groups_3_outlined,
          'label': 'Discussion',
          'color': Colors.deepOrange,
          'onTap': () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DiscussionFormActivity(
                        channel: channel!,
                        socket: socket,
                      )),
            );
          },
        },
      {
        'icon': Icons.image,
        'label': 'Image',
        'color': Colors.blue,
        'onTap': () async {
          final pickedFile =
              await picker.pickImage(source: ImageSource.gallery);
          Navigator.pop(context);
          goToPreviewPage(context, roomId, clubId, parentChat, "image", sheetOn,
              pickedFile, socket);
        },
      },
      {
        'icon': Icons.insert_drive_file,
        'label': 'Document',
        'color': Colors.green,
        'onTap': () async {
          final pickedFile = await picker.pickMedia();
          Navigator.pop(context);
          goToPreviewPage(context, roomId, clubId, parentChat, "file", sheetOn,
              pickedFile, socket);
        },
      },
      {
        'icon': Icons.video_library,
        'label': 'Video',
        'color': Colors.teal,
        'onTap': () async {
          final pickedFile =
              await picker.pickVideo(source: ImageSource.gallery);
          Navigator.pop(context);
          goToPreviewPage(context, roomId, clubId, parentChat, "video", sheetOn,
              pickedFile, socket);
        },
      },
      if (sheetOn == "file")
        {
          'icon': Icons.link_outlined,
          'label': 'Link',
          'color': Colors.deepOrange,
          'onTap': () {
            Navigator.pop(context);
            goToPreviewPage(context, roomId, clubId, parentChat, "link",
                sheetOn, null, null);
          },
        },
      if (sheetOn == "discussion")
        {
          'icon': Icons.poll_outlined,
          'label': 'Poll',
          'color': Colors.pinkAccent,
          'onTap': () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreatePollScreen(
                        channel: channel!,
                        socket: socket,
                      )),
            );
          },
        },
    ];
  }

  Widget _buildFileOption(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
