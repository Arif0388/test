import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/Style/custom_style.dart';
import 'package:learningx_flutter_app/api/common/full_image_page.dart';
import 'package:learningx_flutter_app/api/common/open_file.dart';
import 'package:learningx_flutter_app/api/common/video_player.dart';
import 'package:learningx_flutter_app/api/model/chat_model.dart';
import 'package:learningx_flutter_app/api/utils/text_modification.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';
import 'package:universal_html/html.dart' as html;

class ChatItemWidget extends StatefulWidget {
  final Chat chat;
  final bool showDate;
  final bool isSelf;
  const ChatItemWidget(
      {super.key,
      required this.chat,
      required this.showDate,
      required this.isSelf});

  @override
  State<ChatItemWidget> createState() => _ChatItemWidgetState();
}

class _ChatItemWidgetState extends State<ChatItemWidget> {
  double _progress = 0;
  bool _isDownloading = false;

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _progress = 0;
    });

    await openFile(widget.chat.file!, (progress) {
      setState(() {
        _progress = progress;
      });
    });

    setState(() {
      _isDownloading = false;
    });
  }

  void openWebFile() {
    // ignore: unused_local_variable
    html.AnchorElement anchorElement =
        html.AnchorElement(href: widget.chat.file)
          ..setAttribute('download', '')
          ..click();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chat Date Row
        if (widget.showDate)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              Utils.getDateString(widget.chat.createdAtDate),
              style: const TextStyle(
                color: Color(0xFF272728),
                fontSize: 14.0,
              ),
            ),
          ),

        Align(
          alignment:
              widget.isSelf ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    widget.isSelf ? AppColors.messageBubbleBlue : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageContent(context),
                  const SizedBox(height: 4),
                  Text(
                    Utils.getTimeString(widget.chat.createdAtDate),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (widget.chat.filetype) {
      case "text":
      case "link":
        return TextModification.displayMessage(
          context,
          widget.chat.chat,
          widget.isSelf,
        );

      case "image":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.chat.chat.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  widget.chat.chat,
                  style: const TextStyle(
                    color: Colors.black87,
                  ),
                ),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullImagePage(
                        url: widget.chat.file!,
                        displayName: widget.chat.sender.displayName,
                      ),
                    ),
                  );
                },
                child: Image.network(
                  widget.chat.file ?? "",
                  height: 200.0,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text("Failed to load image"),
                    );
                  },
                ),
              ),
            ),
          ],
        );

      case "video":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.chat.chat.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  widget.chat.chat,
                  style: const TextStyle(
                    color: Colors.black87,
                  ),
                ),
              ),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                margin: const EdgeInsets.only(top: 4.0, bottom: 16),
                height: 250.0,
                child: VideoPlayerWidget(
                  url: widget.chat.file,
                ),
              ),
            ),
          ],
        );

      case "file":
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.insert_drive_file, color: Colors.grey),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.chat.filename,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${Utils.formatBytes(int.parse(widget.chat.filesize), 2)} • ${widget.chat.realFiletype}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: _isDownloading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: _progress / 100,
                        ),
                      )
                    : const Icon(Icons.download, size: 20),
                onPressed: () async {
                  if (kIsWeb) {
                    openWebFile();
                  } else {
                    if (!_isDownloading) {
                      await _startDownload();
                    }
                  }
                },
              ),
            ],
          ),
        );

      default:
        return const Text("Something went wrong!");
    }
  }
}
