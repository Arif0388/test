import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Screens/council/council_item.dart';
import 'package:learningx_flutter_app/api/model/council_model.dart';
import 'package:learningx_flutter_app/api/provider/council_provider.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});
  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  @override
  Widget build(BuildContext context) {
    final communitiesAsyncValue = ref.watch(councilProvider(""));

    return Scaffold(
        body: CustomScrollView(
      slivers: <Widget>[
        // Header Section
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                color: Colors.white,
                child: GestureDetector(
                  onTap: () {
                    context.push("/search");
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white, // Background color
                      borderRadius:
                          BorderRadius.circular(8.0), // Rounded corners
                      border: Border.all(color: Colors.blue), // Border color
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "search...",
                            style: TextStyle(
                              fontSize: 18,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(
                color: Color.fromARGB(255, 238, 238, 238),
                height: 4,
              ),
              _buildCategoryCard(Icons.public,
                  "Official Communities: Open for all", "Managed by Officials"),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "Communities you can join",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
            ],
          ),
        ),

        // Main List Section
        communitiesAsyncValue.when(
          data: (data) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  CouncilItem councilItem = data[index];
                  return CouncilItemWidget(
                    council: councilItem,
                    key: ValueKey(councilItem.id),
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
            child: Center(child: Text('Failed to fetch clubs')),
          ),
        ),
      ],
    ));
  }

  Widget _buildCategoryCard(IconData icon, String title, String subtitle) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      height: 80, // Set the desired height of the card
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 211, 232, 255),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, size: 24, color: Colors.black),
          ),
          const SizedBox(width: 16), // Space between icon and text
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 15,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4), // Small gap between text lines
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
