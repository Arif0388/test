import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/club/blue_club_item.dart';
import 'package:learningx_flutter_app/Screens/club/form/club_form1.dart';
import 'package:learningx_flutter_app/Screens/home/campus_ambassador_card.dart';
import 'package:learningx_flutter_app/api/provider/club_provider.dart';
import 'package:learningx_flutter_app/api/provider/college_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmptyClubFeed extends ConsumerStatefulWidget {
  const EmptyClubFeed({super.key});
  @override
  ConsumerState<EmptyClubFeed> createState() => _EmptyClubFeedState();
}

class _EmptyClubFeedState extends ConsumerState<EmptyClubFeed> {
  String _collegeId = "";

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _collegeId = prefs.getString("college") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final clubAsyncValue = ref.watch(clubProvider("?college=$_collegeId&college_status[\$ne]=rejected"));
    final collegeData = ref.watch(selectedCollegeProvider(_collegeId));

    return Scaffold(
        body: CustomScrollView(
      slivers: <Widget>[
        // Header Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Do more in Teams" Section
                // const Text(
                //   "Do more in Clubchat",
                //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                // ),
                // const SizedBox(height: 10),
                // Row(
                //   children: [
                //     Expanded(
                //       child: SizedBox(
                //         height: 80,
                //         child:
                //             _buildActionButton(Icons.groups, "Join Club", "3"),
                //       ),
                //     ),
                //     const SizedBox(width: 10),
                //     Expanded(
                //       child: SizedBox(
                //         height: 80, // Ensure consistent height
                //         child: _buildActionButton(
                //             Icons.calendar_today, "Schedule", "1"),
                //       ),
                //     ),
                //     const SizedBox(width: 10), // Spacing between buttons
                //     Expanded(
                //       child: SizedBox(
                //         height: 80,
                //         child: _buildActionButton(
                //             Icons.chat_bubble, "Start chat", "2"),
                //       ),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 20),
                const Text(
                  "Create your own club",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ClubForm1Activity()),
                      );
                    },
                    child: _buildCategoryCard(Icons.add, "Create a Club")),
              ],
            ),
          ),
        ),

        // Main List Section
        SliverToBoxAdapter(
          child: clubAsyncValue.when(
            data: (data) {
              if (data.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 16.0),
                        child: Text(
                          "Join your campus club",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        )),
                    ...data.map((clubItem) {
                      return BlueClubItemWidget(
                        club: clubItem,
                        key: ValueKey(clubItem.id),
                      );
                    }).toList(),
                  ],
                );
              } else {
                return const SizedBox(
                  height: 0,
                );
              }
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: Text('Failed to fetch clubs')),
            ),
          ),
        ),
        if (collegeData.admin.length == 1 &&
            collegeData.admin
                .any((item) => item.id == dotenv.env['LEARNINGX_ADMIN_ID']))
          const SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  child: Text(
                    "Become Campus Ambassador",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                CampusAmbassadorCard(),
              ],
            ),
          ),
      ],
    ));
  }

  // Widget _buildActionButton(IconData icon, String label, String index) {
  //   return GestureDetector(
  //       onTap: () {
  //         context.push("/home/$index");
  //       },
  //       child: Container(
  //         decoration: BoxDecoration(
  //           color: Colors.grey[300],
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         padding: const EdgeInsets.all(8), // Padding inside the button
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Icon(icon, size: 24, color: Colors.black),
  //             const SizedBox(height: 5),
  //             Text(
  //               label,
  //               style: const TextStyle(fontSize: 14, color: Colors.black),
  //             ),
  //           ],
  //         ),
  //       ));
  // }

  Widget _buildCategoryCard(IconData icon, String title) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        height: 80, // Set the desired height of the card
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(icon, size: 24, color: Colors.black),
            ),
            const SizedBox(width: 16), // Space between icon and text
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
