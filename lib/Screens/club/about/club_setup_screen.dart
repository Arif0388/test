import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/Screens/club/form/club_form1.dart';
import 'package:learningx_flutter_app/Screens/club/form/club_form3.dart';
import 'package:learningx_flutter_app/Screens/common/qr_creator.dart';
import 'package:learningx_flutter_app/api/model/club_model.dart';

class ClubSetupScreen extends StatelessWidget {
  final Club club;
  const ClubSetupScreen({Key? key, required this.club}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: const Icon(
                        Icons.lightbulb,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set up your club',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Only visible to admin',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildOptionCard(
                  context: context,
                  icon: Icons.group,
                  color: Colors.purple,
                  label: 'Invite members',
                  page: QrCreator(
                    appBarText: "Invite friends",
                    sharedText:
                        "to join our club !\n\n https://clubchat.live/club/about/${club.id}",
                    url: "https://clubchat.live/club/about/${club.id}",
                    imageUrl: club.clubImg,
                  )),
              const SizedBox(height: 8),
              _buildOptionCard(
                  context: context,
                  icon: Icons.brush,
                  color: Colors.orange,
                  label: 'Personalise club',
                  page: ClubForm1Activity(
                    clubId: club.id,
                  )),
              const SizedBox(height: 8),
              _buildOptionCard(
                  context: context,
                  icon: Icons.chat_bubble_outline,
                  color: Colors.green,
                  label: 'Add some FAQs',
                  page: ClubForm3Screen(
                    clubId: club.id,
                  )),
            ],
          )),
    );
  }

  Widget _buildOptionCard(
      {required BuildContext context,
      required IconData icon,
      required Color color,
      required String label,
      required Widget page}) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 4,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
