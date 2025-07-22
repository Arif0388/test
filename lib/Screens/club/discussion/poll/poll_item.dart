import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Screens/club/discussion/poll/poll_result.dart';
import 'package:learningx_flutter_app/Screens/common/bottom_sheet_chat_item.dart';
import 'package:learningx_flutter_app/Style/custom_style.dart';
import 'package:learningx_flutter_app/api/model/discussion_model.dart';
import 'package:learningx_flutter_app/api/model/user_modal.dart';
import 'package:learningx_flutter_app/api/provider/discussion_provider.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PollScreenItem extends ConsumerStatefulWidget {
  final Discussion chat;
  final int memberCount;
  final bool showDate;
  final bool isAllowedToDelete;
  final bool isCurrentUser;
  final void Function(String) onDeleteChat;

  const PollScreenItem({
    super.key,
    required this.chat,
    required this.memberCount,
    required this.showDate,
    required this.isAllowedToDelete,
    required this.isCurrentUser,
    required this.onDeleteChat,
  });

  @override
  ConsumerState<PollScreenItem> createState() => _PollScreenItemState();
}

class _PollScreenItemState extends ConsumerState<PollScreenItem> {
  // State to track selected options
  var _currentUserId = "";
  List<int> selectedOptions = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return; // Check if the widget is still in the tree
    setState(() {
      _currentUserId = prefs.getString('id') ?? "";
    });
    _checkUserVote();
  }

  _checkUserVote() {
    if (widget.chat.poll != null) {
      // Find the vote for the current user or provide an empty vote if not found
      Vote? userVote = widget.chat.poll!.votes?.firstWhere(
        (vote) => vote.voter.id == _currentUserId,
        orElse: () => Vote(
          id: '',
          voter: User(
              id: _currentUserId,
              username: '',
              firstname: '',
              lastname: '',
              displayName: '',
              userImg: '',
              userNameId: '',
              googleId: '',
              verified: false),
          options: [],
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      if (userVote != null && userVote.options.isNotEmpty) {
        // User has voted, populate the selectedOptions list
        setState(() {
          selectedOptions = userVote.options;
        });
      }
    }
  }

  void _onOptionSelected(int index) async {
    setState(() {
      if (widget.chat.poll!.allowMultipleAnswers) {
        // Toggle selection for multiple answers
        if (selectedOptions.contains(index)) {
          selectedOptions.remove(index);
        } else {
          selectedOptions.add(index);
        }
      } else {
        // Single answer: Replace with the current selection
        selectedOptions = [index];
      }
    });

    // After state update, create the map and send the data
    Map<String, dynamic> map = {
      '_id': widget.chat.id,
      'channel': widget.chat.channel,
      'options': List.from(selectedOptions), // Ensure a proper copy of the list
    };

    Discussion updatedChat = await castVoteInPoll(map);
    updateDiscussion(updatedChat);
  }

  void updateDiscussion(chat) {
    ref
        .read(discussionProvider(
                "${widget.chat.channel}/discussions?parentChatId[\$exists]=false")
            .notifier)
        .updateChat(chat);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        final BottomSheetChatItem sheetChatItem = BottomSheetChatItem();
        sheetChatItem.showBottomSheet(
          context,
          widget.chat,
          widget.onDeleteChat,
          widget.isAllowedToDelete,
        );
      },
      child: Column(
        children: [
          // Chat Date Row
          if (widget.showDate)
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                Utils.getDateString(widget.chat.createdAtDate),
                style: const TextStyle(
                  color: Color(0xFF272728),
                  fontSize: 14.0,
                ),
              ),
            ),

          // Main Chat Content
          Align(
            alignment: widget.isCurrentUser
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85,
              ),
              child: Row(
                mainAxisAlignment: widget.isCurrentUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.isCurrentUser)
                    GestureDetector(
                      onTap: () =>
                          context.push("/profile/${widget.chat.sender.id}"),
                      child: CircleAvatar(
                        radius: 16.0,
                        backgroundImage: widget.chat.sender.userImg != ""
                            ? NetworkImage(widget.chat.sender.userImg)
                            : null,
                        backgroundColor: Colors.grey[300], // Placeholder color
                      ),
                    ),
                  const SizedBox(width: 8),

                  // Message Container
                  Flexible(
                      child: GestureDetector(
                    onLongPress: () {
                      final BottomSheetChatItem sheetChatItem =
                          BottomSheetChatItem();
                      sheetChatItem.showBottomSheet(context, widget.chat,
                          widget.onDeleteChat, widget.isCurrentUser);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.isCurrentUser
                            ? AppColors.messageBubbleBlue
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _buildMessageContent(context),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String optionText,
    required int votes,
    required int totalVotes,
    required int index,
  }) {
    final percentage = (votes / totalVotes * 100).round();
    return Column(
      children: [
        Row(
          children: [
            // Radio or Checkbox based on allowMultipleAnswers
            widget.chat.poll!.allowMultipleAnswers
                ? Checkbox(
                    value: selectedOptions.contains(index),
                    onChanged: (value) => _onOptionSelected(index),
                  )
                : Radio<int>(
                    value: index,
                    groupValue:
                        selectedOptions.isEmpty ? null : selectedOptions.first,
                    onChanged: (value) => _onOptionSelected(index),
                  ),
            Expanded(
              child: Text(
                optionText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.group),
                const SizedBox(width: 8),
                Text(
                  '$votes',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: votes / totalVotes,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(
                  widget.isCurrentUser ? Colors.teal[200]! : Colors.grey[400]!,
                ),
                minHeight: 24,
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Text(
                  '$percentage%',
                  style: TextStyle(
                    color: percentage > 50 ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Prevent infinite height
      children: [
        if (!widget.isCurrentUser)
          Text(
            widget.chat.sender.displayName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
              color: AppColors.primaryBlue,
            ),
          ),
        const SizedBox(height: 4.0),
        Text(
          widget.chat.poll!.question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.chat.poll!.allowMultipleAnswers
              ? 'Select one or more'
              : 'Select one',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        ...widget.chat.poll!.options.asMap().entries.map(
          (entry) {
            int index = entry.key;
            String optionText = entry.value;

            // Count votes for this specific option
            int votesForOption = widget.chat.poll!.votes!
                .where((vote) => vote.options.contains(index))
                .length;

            return _buildOption(
              optionText: optionText,
              votes: votesForOption,
              totalVotes: widget.chat.poll!.votes!.isEmpty
                  ? 1
                  : widget.chat.poll!.votes!.length,
              index: index,
            );
          },
        ).toList(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Distribute widgets evenly
          children: [
            Text(
              Utils.getTimeString(widget.chat.createdAtDate),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            if (!widget.chat.poll!.isAnonymous)
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PollVotesScreen(
                          poll: widget.chat.poll!,
                          memberCount: widget.memberCount,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'View votes',
                    style: TextStyle(color: Color(0xFF4285F4), fontSize: 16),
                  ),
                ),
              ),
            if (widget.chat.poll!.isAnonymous)
              const Text(
                "Anonymous poll",
                style: TextStyle(color: Colors.blue, fontSize: 12),
              ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
