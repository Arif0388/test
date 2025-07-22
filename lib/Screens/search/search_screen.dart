import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Screens/search/search_history_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchActivity extends StatefulWidget {
  const SearchActivity({super.key});

  @override
  State<SearchActivity> createState() => _SearchActivityState();
}

class _SearchActivityState extends State<SearchActivity> {
  List<String> histories = [];
  List<String> filteredString = [];

  @override
  void initState() {
    _loadCurrentUser();
    super.initState();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      histories = prefs.getStringList("search-history") ?? [];
      filteredString = prefs.getStringList("search-history") ?? [];
    });
  }

  void handleOnRemove(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      histories.remove(query);
      filteredString.remove(query);
    });
    await prefs.setStringList('search-history', histories);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        elevation: 0,
        toolbarHeight: 60,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search',
            prefixIcon: const Icon(Icons.search),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.white,
            filled: true,
          ),
          onChanged: (value) {
            setState(() {
              filteredString = histories
                  .where((item) =>
                      item.toLowerCase().contains(value.toLowerCase()))
                  .toList();
            });
          },
          onSubmitted: (String query) async {
            if (!histories.contains(query)) {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              if (histories.length < 20) {
                setState(() {
                  histories.add(query);
                  filteredString.add(query);
                });
              } else {
                setState(() {
                  histories.removeAt(0);
                  histories.add(query);
                  filteredString.removeAt(0);
                  filteredString.add(query);
                });
              }
              await prefs.setStringList('search-history', histories);
            }
            context.push("/search?query=$query");
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent searches',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.builder(
                itemCount: filteredString.length,
                itemBuilder: (context, index) {
                  return HistoryWidget(
                      query: filteredString[filteredString.length - index - 1],
                      onRemoved: handleOnRemove);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
