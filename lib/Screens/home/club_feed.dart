import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/club/blue_club_item.dart';
import 'package:learningx_flutter_app/Screens/club/club_item.dart';
import 'package:learningx_flutter_app/Screens/home/campus_ambassador_card.dart';
import 'package:learningx_flutter_app/Screens/home/empty_club_feed.dart';
import 'package:learningx_flutter_app/api/model/club_model.dart';
import 'package:learningx_flutter_app/api/provider/club_feed_provider.dart';
import 'package:learningx_flutter_app/api/provider/club_provider.dart';
import 'package:learningx_flutter_app/api/provider/college_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClubsScreen extends ConsumerStatefulWidget {
  const ClubsScreen({
    super.key,
  });

  @override
  ConsumerState<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends ConsumerState<ClubsScreen> {
  String? _collegeId;
  bool _isLoading = true;
  bool _isLoadingClubs = true;
  bool isCollegeAdmin = false;
  var _currentUserId = "";
  int _selectedFragmentIndex = 0;

  var filterQuery = "";

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadCurrentUser();
    setState(() => _isLoading = false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(yourClubFeedProvider.notifier).loadCachedClubs();
      setState(() {
        _isLoadingClubs = false; // Cached clubs loaded
      });

      await ref.read(yourClubFeedProvider.notifier).fetchClubItems();
      await ref
          .read(selectedCollegeProvider(_collegeId!).notifier)
          .fetchCollege(_collegeId!);
    });
    final collegeData = ref.watch(selectedCollegeProvider(_collegeId!));
    if (collegeData.admin.any((item) => item.id == _currentUserId)) {
      filterQuery = "?college=$_collegeId";
    } else {
      filterQuery = "?college=$_collegeId&college_status[\$ne]=rejected";
    }
  }

  Future<void> _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString("id") ?? "";
      _collegeId = prefs.getString("college") ?? "";
    });
  }

  Future<void> refresh() async {
    await ref.read(yourClubFeedProvider.notifier).fetchClubItems();
  }

  Future<void> _refreshFilter(String query) async {
    await ref.refresh(clubProvider(query).future);
  }

  void subscribeToFCM(List<ClubItem> yourClubs) async {
    var firebaseMessaging = FirebaseMessaging.instance;
    for (final club in yourClubs) {
      if (Platform.isMacOS || Platform.isIOS) {
        String? apnsToken = await firebaseMessaging.getAPNSToken();
        if (apnsToken != null) {
          await firebaseMessaging.subscribeToTopic(club.id);
        }
      } else {
        await firebaseMessaging.subscribeToTopic(club.id);
      }
    }
  }

  void _onFragmentChanged(int index) {
    setState(() {
      _selectedFragmentIndex = index;
    });
    _refreshFilter(filterQuery);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _isLoadingClubs) {
      return const Center(child: CircularProgressIndicator());
    }

    final yourClubs = ref.watch(yourClubFeedProvider);
    final clubAsyncValue = ref.watch(clubProvider(filterQuery));
    final collegeData = ref.watch(selectedCollegeProvider(_collegeId!));

    setState(() {
      isCollegeAdmin =
          collegeData.admin.any((item) => item.id == _currentUserId);
    });

    if (!kIsWeb) {
      subscribeToFCM(yourClubs);
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refresh,
        child: yourClubs.isEmpty
            ? const EmptyClubFeed()
            : CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                      child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Expanded(child: _buildFragmentButtons('Joined', 0)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildFragmentButtons('All', 1)),
                        const SizedBox(width: 16),
                      ],
                    ),
                  )),
                  if (_selectedFragmentIndex == 0)
                    SliverList(
                      key: const PageStorageKey<String>('clubFeedList'),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return ClubItemWidget(
                            key: ValueKey(yourClubs[index].id),
                            club: yourClubs[index],
                          );
                        },
                        childCount: yourClubs.length,
                      ),
                    ),
                  if (_selectedFragmentIndex != 0)
                    SliverToBoxAdapter(
                      child: clubAsyncValue.when(
                        data: (data) {
                          if (data.isNotEmpty) {
                            return Column(
                              children: data.map((clubItem) {
                                return BlueClubItemWidget(
                                  club: clubItem,
                                  key: ValueKey(clubItem.id),
                                );
                              }).toList(),
                            );
                          } else {
                            return const SizedBox.shrink();
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
                      collegeData.admin.any((item) =>
                          item.id == dotenv.env['LEARNINGX_ADMIN_ID']))
                    const SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                            child: Text(
                              "Become Campus Ambassador",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          CampusAmbassadorCard(),
                        ],
                      ),
                    ),
                ],
              ),
      ),

      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: const Color.fromARGB(255, 56, 114, 220),
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => ClubForm1Activity(
      //           collegeId: isCollegeAdmin ? _collegeId : null,
      //         ),
      //       ),
      //     );
      //   },
      //   child: const Icon(Icons.abc_rounded, color: Colors.white),
      // ),

    );
  }

  Widget _buildFragmentButtons(String text, int index) {
    bool isActive = _selectedFragmentIndex == index;

    return isActive
        ? ElevatedButton(
            onPressed: () {
              _onFragmentChanged(index);
            },
            style: ButtonStyle(
              textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 13)),
              backgroundColor: WidgetStateProperty.all(
                  Colors.blue), // Active button background color
              foregroundColor: WidgetStateProperty.all(
                  Colors.white), // Active button text color
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            child: Text(text),
          )
        : OutlinedButton(
            onPressed: () {
              _onFragmentChanged(index);
            },
            style: ButtonStyle(
              textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 13)),
              foregroundColor: WidgetStateProperty.all(
                  Colors.black), // Inactive button text color
              side: WidgetStateProperty.all(const BorderSide(
                  color: Colors.white)), // Inactive button border color
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            child: Text(text),
          );
  }

}
