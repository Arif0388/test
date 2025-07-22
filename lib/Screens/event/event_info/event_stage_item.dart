import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/api/model/event_model.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';

class EventStageItemCard extends StatelessWidget {
  final Stage stage;
  final bool showLink;
  const EventStageItemCard(
      {super.key, required this.stage, required this.showLink});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(
          color: Colors.blue,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${stage.round}. ${stage.roundTitle}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              stage.description,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            if (stage.link != "" && showLink)
              Row(
                children: [
                  const Icon(
                    Icons.link,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    stage.link,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.black,
                ),
                const SizedBox(width: 8),
                Flexible(
                    child: Text(
                  '${Utils.formatDate(stage.startedAtDate)} - ${Utils.formatDate(stage.endedAtDate)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
