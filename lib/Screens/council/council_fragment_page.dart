import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/council/council_item.dart';
import 'package:learningx_flutter_app/api/model/council_model.dart';
import 'package:learningx_flutter_app/api/provider/council_provider.dart';

class CouncilFragmentPage extends ConsumerStatefulWidget {
  final String query;
  const CouncilFragmentPage({super.key, required this.query});
  @override
  ConsumerState<CouncilFragmentPage> createState() =>
      _CouncilFragmentPageState();
}

class _CouncilFragmentPageState extends ConsumerState<CouncilFragmentPage> {
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
    await ref.refresh(councilProvider(widget.query).future);
  }

  @override
  Widget build(BuildContext context) {
    final councilAsyncValue = ref.watch(councilProvider(widget.query));

    return RefreshIndicator(
        onRefresh: _refresh, // Swipe down triggers the refresh
        child: Center(
            child: councilAsyncValue.when(
          data: (data) {
            if (data.isEmpty) {
              return const Center(child: Text('No council found'));
            } else {
              return ListView.builder(
                key: const PageStorageKey<String>('councilList'),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  CouncilItem council = data[index];
                  return CouncilItemWidget(council: council);
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
            child: Center(child: Text('Failed to fetch council')),
          ),
        )));
  }
}
