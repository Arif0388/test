import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/api/model/college_model.dart';
import 'package:learningx_flutter_app/api/provider/college_provider.dart';

class CollegeSearchScreen extends ConsumerWidget {
  final String query;
  const CollegeSearchScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collegeAsyncValue = ref.watch(collegeProvider(query));

    return Scaffold(
      body: Center(
        child: collegeAsyncValue.when(
          data: (colleges) {
            if (colleges.isEmpty) {
              return const Text('No result found');
            } else {
              return ListView.builder(
                itemCount: colleges.length,
                itemBuilder: (context, index) {
                  College college = colleges[index];
                  return ListTile(
                    leading: Image.network(college.collegeImg),
                    title: Text(college.collegeName),
                    subtitle: Text(
                      college.city.address,
                      maxLines: 1,
                    ),
                    onTap: () => {context.push("/college/${college.id}")},
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
