import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

class CampusAmbassadorCard extends StatelessWidget {
  const CampusAmbassadorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Ensures it wraps content
          children: [
            const Row(
              children: [
                Icon(Icons.contact_phone),
                SizedBox(width: 8),
                Text(
                  'Contact us',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.person_2),
                const SizedBox(width: 8),
                const Text(
                  '@clubchat.live',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    context
                        .push("/profile/${dotenv.env['LEARNINGX_ADMIN_ID']}");
                  }, // Implement edit functionality here
                  icon: const Icon(Icons.mail_outline),
                ),
              ],
            ),
            const Text('DM us to'),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.school),
                SizedBox(width: 8),
                Text('Become Campus Ambassador'),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.chat),
                SizedBox(width: 8),
                Text('Share info, concerns, or feedback'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
