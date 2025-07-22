import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:learningx_flutter_app/Screens/club/session/session_form.dart';
import 'package:learningx_flutter_app/Screens/club/session/session_item.dart';
import 'package:learningx_flutter_app/api/model/channel_model.dart';
import 'package:learningx_flutter_app/api/model/session_model.dart';
import 'package:learningx_flutter_app/api/provider/session_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionPageScreen extends ConsumerStatefulWidget {
  final Channel channel;
  const SessionPageScreen({super.key, required this.channel});

  @override
  ConsumerState<SessionPageScreen> createState() => _SessionPageScreenState();
}

class _SessionPageScreenState extends ConsumerState<SessionPageScreen> {
  String _currentUserId = "";

  @override
  void initState() {
    _loadCurrentUser();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString("id") ?? "";
    });
  }

  Future<void> _refresh() async {
    final sessionNotifier =
        ref.read(sessionProvider("${widget.channel.id}/session").notifier);
    if (sessionNotifier.isLoading) {
      //  already fetching or fetched, no need to refresh
      return;
    }
    // not fetched, refresh
    await sessionNotifier.fetchSessions("${widget.channel.id}/session");
  }

  @override
  Widget build(BuildContext context) {
    final sessions = ref.watch(sessionProvider("${widget.channel.id}/session"));
    List<Session> pastSessions = [];
    List<Session> upcomingSessions = [];
    DateTime currentDateTime = DateTime.now();
    String isoDateTimeString =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(currentDateTime);

    DateTime isoDateTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        .parse(isoDateTimeString, true)
        .toLocal();

    for (Session session in sessions) {
      DateTime sessionStartTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
          .parse(session.startTime, true)
          .toLocal();

      if (sessionStartTime.isBefore(isoDateTime)) {
        pastSessions.add(session);
      } else {
        upcomingSessions.add(session);
      }
    }

    return Scaffold(
        body: RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              slivers: <Widget>[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(left: 16, top: 16),
                    child: Text(
                      'Upcoming session',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                upcomingSessions.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'No upcoming session',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            Session session = upcomingSessions[index];
                            return SessionItemWidget(
                              session: session,
                              isAdmin:
                                  widget.channel.admin.contains(_currentUserId),
                            );
                          },
                          childCount: upcomingSessions.length,
                        ),
                      ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(left: 16, bottom: 8),
                    child: Text(
                      'Past session',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                pastSessions.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'No past session',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            Session session = pastSessions[index];
                            return SessionItemWidget(
                              session: session,
                              isAdmin:
                                  widget.channel.admin.contains(_currentUserId),
                            );
                          },
                          childCount: pastSessions.length,
                        ),
                      ),
              ],
            )),
        floatingActionButton: Visibility(
          visible: widget.channel.admin.contains(_currentUserId),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SessionFormActivity(
                          channel: widget.channel,
                        )),
              );
            },
            child: const Icon(Icons.add),
          ),
        ));
  }
}
