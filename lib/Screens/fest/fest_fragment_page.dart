import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/fest/fest_form.dart';
import 'package:learningx_flutter_app/Screens/fest/fest_item.dart';
import 'package:learningx_flutter_app/api/model/fest_model.dart';
import 'package:learningx_flutter_app/api/provider/fest_provider.dart';

class FestFragmentPage extends ConsumerStatefulWidget {
  final String id;
  final bool isVisible;
  final bool isHomePage;
  const FestFragmentPage(
      {super.key,
      required this.id,
      required this.isVisible,
      required this.isHomePage});
  @override
  ConsumerState<FestFragmentPage> createState() => _FestFragmentState();
}

class _FestFragmentState extends ConsumerState<FestFragmentPage> {
  var query = "";
  @override
  void initState() {
    super.initState();
    if (!widget.isHomePage) {
      query = "?college=${widget.id}";
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _refresh() async {
    await ref.refresh(festProvider(query).future);
  }

  @override
  Widget build(BuildContext context) {
    final festAsyncValue = ref.watch(festProvider(query));

    return Scaffold(
      body: RefreshIndicator(
          onRefresh: _refresh, // Swipe down triggers the refresh
          child: Center(
              child: festAsyncValue.when(
            data: (data) {
              if (data.isEmpty) {
                return const Center(child: Text('No fest found'));
              } else {
                return ListView.builder(
                  key: const PageStorageKey<String>('festList'),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    Fest fest = data[index];
                    return FestItemCard(fest: fest);
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
              child: Center(child: Text('Failed to fetch fest')),
            ),
          ))),
      floatingActionButton: Visibility(
          visible: widget.isVisible,
          child: FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 56, 114, 220),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FestFormActivity(
                    collegeId: widget.id,
                  ),
                ),
              );
            },
            child: const Icon(Icons.add, color: Colors.white),
          )),
    );
  }
}
