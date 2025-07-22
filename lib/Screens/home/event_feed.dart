import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/club/select_a_club.dart';
import 'package:learningx_flutter_app/Screens/event/event_item.dart';
import 'package:learningx_flutter_app/Screens/event/select_a_page.dart';
import 'package:learningx_flutter_app/Screens/home/empty_event_feed.dart';
import 'package:learningx_flutter_app/api/model/event_model.dart';
import 'package:learningx_flutter_app/api/provider/college_provider.dart';
import 'package:learningx_flutter_app/api/provider/event_feed_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventsScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  var collegeId = "";
  var currentUserId = "";
  bool _isLoadingCollegeId = true;
  bool isExpanded = false;
  var isNietCollegeAdmin = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      collegeId = prefs.getString('college') ?? "";
      currentUserId = prefs.getString('id') ?? "";
      _isLoadingCollegeId = false;
    });

    if (!ref.read(eventFeedProvider(collegeId).notifier).isLoading) {
      ref.read(eventFeedProvider(collegeId).notifier).fetchEvents();
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(eventFeedProvider(collegeId).notifier).fetchEvents();
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 200 &&
        notification is ScrollUpdateNotification) {
      ref.read(eventFeedProvider(collegeId).notifier).fetchEvents();
    }
    return false; // Returning false allows the notification to continue bubbling up.
  }

  Future<void> _refresh() async {
    ref.read(eventFeedProvider(collegeId).notifier).refreshEventFeed();
  }

  void onRemove(String eventId) {
    ref.read(eventFeedProvider(collegeId).notifier).removeEvent(eventId);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingCollegeId) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final events = ref.watch(eventFeedProvider(collegeId));
    final isLoading = ref.watch(eventFeedProvider(collegeId)
        .notifier
        .select((state) => state.isLoading));
    final collegeData = ref.watch(selectedCollegeProvider(collegeId));

    if (collegeId == dotenv.env['NIET_COLLEGE_ID']) {
      setState(() {
        isNietCollegeAdmin =
            collegeData.admin.any((item) => item.id == currentUserId);
      });
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: CustomScrollView(
            key: const PageStorageKey<String>('eventFeedList'),
            slivers: [
              if (events.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == events.length) {
                        return isLoading
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            : const SizedBox.shrink();
                      }
                      EventItem event = events[index];
                      return EventItemCard(
                        key: ValueKey(event.id),
                        event: event,
                        onRemove: onRemove,
                        isNietCollegeAdmin: isNietCollegeAdmin,
                      );
                    },
                    childCount: events.length + (isLoading ? 1 : 0),
                  ),
                ),
              if (events.isEmpty && !isLoading)
                const SliverFillRemaining(
                    hasScrollBody: false, child: EmptyEventFeed()),
            ],
          ),
        ),
      ),
      // floatingActionButton: SpeedDial(
      //   animatedIcon: AnimatedIcons.add_event,
      //   animatedIconTheme:
      //       const IconThemeData(color: Colors.white), // White icon color
      //   backgroundColor: const Color.fromARGB(255, 56, 114, 220),
      //   overlayColor: Colors.black,
      //   overlayOpacity: 0.5,
      //   spacing: 16,
      //   elevation: 6.0, // Match FAB elevation
      //   shape: RoundedRectangleBorder(
      //     borderRadius:
      //         BorderRadius.circular(16.0), // Adjust border radius here
      //   ),
      //   children: [
      //     SpeedDialChild(
      //       child: const Icon(
      //         Icons.work_history,
      //         color: Color.fromARGB(255, 56, 114, 220),
      //       ),
      //       label: 'Club Workshop',
      //       onTap: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //               builder: (context) => const SelectAClub(
      //                     isWorkshop: true,
      //                   )),
      //         );
      //       },
      //     ),
      //     SpeedDialChild(
      //       child: const Icon(
      //         Icons.event_available,
      //         color: Color.fromARGB(255, 56, 114, 220),
      //       ),
      //       label: 'Host event',
      //       onTap: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (context) => const SelectAPage()),
      //         );
      //       },
      //     ),
      //   ],
      // ),
    );
  }
}
