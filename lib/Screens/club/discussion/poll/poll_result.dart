import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/api/model/discussion_model.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';

class PollVotesScreen extends StatelessWidget {
  final Poll poll;
  final int memberCount;
  const PollVotesScreen(
      {super.key, required this.poll, required this.memberCount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poll Votes'),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              poll.question,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${poll.votes!.length} of $memberCount members voted',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            Divider(thickness: 1, color: Colors.grey[300]),
            Expanded(
              child: ListView.builder(
                itemCount: poll.options.length,
                itemBuilder: (context, index) {
                  List<Vote> votesForOption = poll.votes!
                      .where((vote) => vote.options.contains(index))
                      .toList();
                  return _buildVoteSection(poll.options[index], votesForOption);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteSection(String option, List<Vote> votes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              option,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${votes.length} votes',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const Icon(
              Icons.star,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...votes.map((vote) => _buildVoteTile(vote)).toList(),
        Divider(thickness: 1, color: Colors.grey[300]),
      ],
    );
  }

  Widget _buildVoteTile(Vote vote) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(vote.voter.userImg),
      ),
      title: Text(
        vote.voter.displayName,
        style: const TextStyle(fontSize: 16),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Utils.getTimeString(vote.createdAtDate),
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
