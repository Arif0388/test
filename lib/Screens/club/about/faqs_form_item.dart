import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuestionAnswerWidget extends ConsumerStatefulWidget {
  final int index;
  final TextEditingController questionController;
  final TextEditingController answerController;

  const QuestionAnswerWidget({
    super.key,
    required this.index,
    required this.questionController,
    required this.answerController,
  });

  @override
  ConsumerState<QuestionAnswerWidget> createState() =>
      _QuestionAnswerWidgetState();
}

class _QuestionAnswerWidgetState extends ConsumerState<QuestionAnswerWidget> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${widget.index + 1}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.blue, // Change color as needed
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: widget.questionController,
            maxLines: 2,
            minLines: 1,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your question',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Answer ${widget.index + 1}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.blue, // Change color as needed
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: widget.answerController,
            maxLines: 3,
            minLines: 1,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your answer',
            ),
          ),
        ],
      ),
    );
  }
}
