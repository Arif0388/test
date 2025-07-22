import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/club/blue_club_item.dart';
import 'package:learningx_flutter_app/api/model/club_model.dart';
import 'package:learningx_flutter_app/api/provider/club_provider.dart';

class LearningxClubFeed extends ConsumerStatefulWidget {
  const LearningxClubFeed({super.key});
  @override
  ConsumerState<LearningxClubFeed> createState() => _LearningxClubFeedState();
}

class _LearningxClubFeedState extends ConsumerState<LearningxClubFeed> {
  @override
  Widget build(BuildContext context) {
    final clubAsyncValue = ref.watch(clubProvider("?learningXClub=true"));

    return Scaffold(
        appBar: AppBar(
          title: const Text('Clubchat Clubs'),
          backgroundColor: const Color.fromARGB(255, 211, 232, 255),
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
          elevation: 0,
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            // Header Section
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryCard(Icons.public,
                      "Clubchat Club: Open for all", "Managed by Clubchat"),
                  const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Club you can join",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                ],
              ),
            ),

            // Main List Section
            clubAsyncValue.when(
              data: (data) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      ClubItem clubItem = data[index];
                      return BlueClubItemWidget(
                        club: clubItem,
                        key: ValueKey(clubItem.id),
                      );
                    },
                    childCount: data.length,
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => const SliverToBoxAdapter(
                child: Center(child: Text('Failed to fetch clubs')),
              ),
            ),
          ],
        ));
  }

  Widget _buildCategoryCard(IconData icon, String title, String subtitle) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      height: 80, // Set the desired height of the card
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 211, 232, 255),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, size: 24, color: Colors.black),
          ),
          const SizedBox(width: 16), // Space between icon and text
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 15,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4), // Small gap between text lines
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
