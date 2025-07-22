import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/club/blue_club_item.dart';
import 'package:learningx_flutter_app/Screens/club/form/club_form1.dart';
import 'package:learningx_flutter_app/api/model/club_model.dart';
import 'package:learningx_flutter_app/api/provider/club_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClubFragmentPage extends ConsumerStatefulWidget {
  final String query;
  final Widget page;
  final bool? isVisible;
  final bool? isCollegeAdmin;
  const ClubFragmentPage(
      {super.key,
      required this.query,
      required this.page,
      this.isVisible,
      this.isCollegeAdmin});
  @override
  ConsumerState<ClubFragmentPage> createState() => _ClubFragmentState();
}

class _ClubFragmentState extends ConsumerState<ClubFragmentPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  String _collegeId = "";
  String _currentUserId = "";
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _collegeId = prefs.getString('college') ?? "";
      _currentUserId = prefs.getString("id") ?? "";
    });
  }

  Future<void> _refresh() async {
    await ref.refresh(clubProvider(widget.query).future);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Call super.build for AutomaticKeepAlive

    final clubAsyncValue = ref.watch(clubProvider(widget.query));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh, // Swipe down triggers the refresh
        child: CustomScrollView(
          key: const PageStorageKey<String>('clubList'),
          slivers: <Widget>[
            SliverToBoxAdapter(child: widget.page),
            clubAsyncValue.when(
              data: (data) {
                if (data.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'No clubs available',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  );
                } else {
                  data.sort((a, b) {
                    bool aHasUser = a.members.contains(_currentUserId);
                    bool bHasUser = b.members.contains(_currentUserId);

                    if (aHasUser && !bHasUser) {
                      return -1; // `a` comes first
                    } else if (!aHasUser && bHasUser) {
                      return 1; // `b` comes first
                    }
                    return a.clubName
                        .compareTo(b.clubName); // Sort alphabetically otherwise
                  });

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
                }
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => const SliverToBoxAdapter(
                child: Center(child: Text('Failed to fetch clubs')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Visibility(
          visible: widget.isVisible ?? false,
          child: FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 56, 114, 220),
            onPressed: () {
              bool isAdmin = widget.isCollegeAdmin ?? false;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClubForm1Activity(
                    collegeId: isAdmin ? _collegeId : null,
                  ),
                ),
              );
            },
            child: const Icon(Icons.add, color: Colors.white),
          )),
    );
  }
}
