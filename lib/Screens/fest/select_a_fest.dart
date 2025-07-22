import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/event/form/event_form_page.dart';
import 'package:learningx_flutter_app/api/model/fest_model.dart';
import 'package:learningx_flutter_app/api/provider/fest_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectAFest extends ConsumerStatefulWidget {
  const SelectAFest({super.key});
  @override
  ConsumerState<SelectAFest> createState() => _SelectAFestState();
}

class _SelectAFestState extends ConsumerState<SelectAFest> {
  String _currentUserId = "";
  String _collegeId = "";

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
    final festsAsyncValue =
        ref.watch(festProvider("?admin=$_currentUserId&college=$_collegeId"));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        title: const Text("Select a Fest"),
      ),
      body: festsAsyncValue.when(
        data: (data) {
          return data.isEmpty
              ? const Center(
                  child: Text("You must be admin of atleast one Fest"))
              : ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    Fest festItem = data[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          festItem.festImg,
                          width: 100.0,
                          height: 50.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(festItem.festName),
                      subtitle: Text(festItem.college.collegeName),
                      onTap: () => {
                        Navigator.pop(context),
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EventFormPage(formData: {
                                    "collegeId": _collegeId,
                                    "festId": festItem.id
                                  })),
                        )
                      },
                    );
                  },
                );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            const Center(child: Text('Failed to fetch fests')),
      ),
    );
  }
}
