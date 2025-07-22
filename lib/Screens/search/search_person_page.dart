import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/api/model/user_modal.dart';
import 'package:learningx_flutter_app/api/provider/user_provider.dart';

class PersonScreen extends ConsumerWidget {
  final String query;
  const PersonScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userProvider(query));

    return Scaffold(
      body: Center(
        child: userAsyncValue.when(
          data: (users) {
            if (users.isEmpty) {
              return const Text('No result found');
            } else {
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  User user = users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 20.0,
                      backgroundImage: NetworkImage(
                          user.userImg), // Replace with your image asset
                    ),
                    title: Text(user.displayName),
                    subtitle: Text(
                      user.userNameId,
                      maxLines: 1,
                    ),
                    onTap: () => {context.push("/profile/${user.id}")},
                  );
                },
              );
            }
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Failed to fetch clubs: $error'),
        ),
      ),
    );
  }
}
