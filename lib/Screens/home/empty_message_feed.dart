import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/api/model/user_modal.dart';
import 'package:learningx_flutter_app/api/provider/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmptyMessageFeed extends ConsumerStatefulWidget {
  const EmptyMessageFeed({super.key});
  @override
  ConsumerState<EmptyMessageFeed> createState() => _EmptyMessageFeedState();
}

class _EmptyMessageFeedState extends ConsumerState<EmptyMessageFeed> {
  String _currentUserId = "";
  String _collegeId = "";
  var mainListCount = 0;
  @override
  void initState() {
    _loadCurrentUser();
    super.initState();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString("id") ?? "";
      _collegeId = prefs.getString("college") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAsyncValue = ref
        .watch(userProvider("?_id[\$ne]=$_currentUserId&college=$_collegeId"));
    final secondOptionAsyncValue = ref.watch(
        userProvider("?_id[\$ne]=$_currentUserId&college[\$ne]=$_collegeId"));

    return Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: <Widget>[
            // Header Section
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Image.asset(
                      "assets/images/new_chat.jpeg",
                      width: 150,
                    )),
                    const Center(
                      child: Text(
                        "Chat with your fellow college mate",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "People you may know",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            // Main List Section
            userAsyncValue.when(
              data: (data) {
                setState(() {
                  mainListCount = data.length;
                });
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      User user = data[index];
                      return ListTile(
                        key: ValueKey(user.id),
                        leading: CircleAvatar(
                          radius: 20.0,
                          backgroundImage: NetworkImage(user.userImg),
                        ),
                        title: Text(user.displayName),
                        subtitle: Text(user.userNameId),
                        onTap: () => {context.push("/profile/${user.id}")},
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
                child: Center(child: Text('Failed to fetch users')),
              ),
            ),

            // Second List Section
            if (mainListCount < 10)
              secondOptionAsyncValue.when(
                data: (data) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        User user = data[index];
                        return ListTile(
                          key: ValueKey(user.id),
                          leading: CircleAvatar(
                            radius: 20.0,
                            backgroundImage: NetworkImage(user.userImg),
                          ),
                          title: Text(user.displayName),
                          subtitle: Text(user.userNameId),
                          onTap: () => {context.push("/profile/${user.id}")},
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
                  child: Center(child: Text('Failed to fetch users')),
                ),
              ),
          ],
        ));
  }
}
