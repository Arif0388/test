import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/api/model/event_model.dart';

class EventAwardItemCard extends StatelessWidget {
  final Reward reward;
  const EventAwardItemCard({super.key, required this.reward});

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
              reward.rank,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            if (reward.otherDetails.isNotEmpty)
              Text(
                reward.otherDetails,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                const Icon(
                  Icons.center_focus_strong,
                  size: 24,
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  '₹ ${reward.money}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
