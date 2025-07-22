import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/Screens/club/club_fragment_page.dart';
import 'package:learningx_flutter_app/Screens/event/event_fragment_page.dart';
import 'package:learningx_flutter_app/Screens/search/search_college_page.dart';
import 'package:learningx_flutter_app/Screens/search/search_person_page.dart';

class SearchPageActivity extends StatefulWidget {
  final String query;
  const SearchPageActivity({super.key, required this.query});

  @override
  State<SearchPageActivity> createState() => _SearchableActivityState();
}

class _SearchableActivityState extends State<SearchPageActivity>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        ),
        title: Container(
          color: const Color.fromARGB(255, 211, 232, 255),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.query,
                      style: const TextStyle(
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
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.secondary,
            unselectedLabelColor: Colors.black,
            indicatorColor: Theme.of(context).colorScheme.secondary,
            tabs: const [
              Tab(text: 'Person'),
              Tab(text: 'Club'),
              Tab(text: 'Campus'),
              Tab(text: 'Event'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                PersonScreen(
                  query: "?\$text[\$search]=\"${widget.query}\"",
                ),
                ClubFragmentPage(
                  query: "?\$text[\$search]=\"${widget.query}\"",
                  page: const Divider(
                    color: Colors.black87,
                    height: 0,
                  ),
                ),
                CollegeSearchScreen(
                  query: "?\$text[\$search]=\"${widget.query}\"",
                ),
                EventFragmentPage(
                  query: "?stepsDone=6&\$text[\$search]=\"${widget.query}\"",
                  page: const Divider(
                    color: Colors.black87,
                    height: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
