import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/club/blue_club_item.dart';
import 'package:learningx_flutter_app/Screens/club/form/club_form1.dart';
import 'package:learningx_flutter_app/api/model/club_model.dart';
import 'package:learningx_flutter_app/api/provider/club_provider.dart';

class AddClubToCouncil extends ConsumerStatefulWidget {
  final String collegeId;
  final String councilId;
  const AddClubToCouncil(
      {super.key, required this.collegeId, required this.councilId});

  @override
  ConsumerState<AddClubToCouncil> createState() => _AddClubToCouncilState();
}

class _AddClubToCouncilState extends ConsumerState<AddClubToCouncil> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _refresh() async {
    await ref.refresh(clubProvider(
            "?college=${widget.collegeId}&college_status[\$ne]=rejected&council[\$exists]=false")
        .future);
  }

  @override
  Widget build(BuildContext context) {
    final clubAsyncValue = ref.watch(clubProvider(
        "?college=${widget.collegeId}&college_status[\$ne]=rejected&council[\$exists]=false"));

    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Club to Council'),
          backgroundColor: const Color.fromARGB(255, 211, 232, 255),
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
          elevation: 0,
        ),
        body: RefreshIndicator(
            onRefresh: _refresh, // Swipe down triggers the refresh
            child: Center(
                child: clubAsyncValue.when(
              data: (data) {
                if (data.isEmpty) {
                  return const Center(child: Text('No club found'));
                } else {
                  return ListView.builder(
                    key: const PageStorageKey<String>('clubList'),
                    itemCount: data.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildAddClubCard(Icons.group_add_outlined,
                                      "Create new club"),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "Add Campus Club",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ]));
                      } else {
                        ClubItem clubItem = data[index - 1];
                        return BlueClubItemWidget(
                          club: clubItem,
                          key: ValueKey(clubItem.id),
                        );
                      }
                    },
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
            ))));
  }

  Widget _buildAddClubCard(IconData icon, String title) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ClubForm1Activity(
                    collegeId: widget.collegeId, councilId: widget.councilId)),
          );
        },
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
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
        ));
  }
}
