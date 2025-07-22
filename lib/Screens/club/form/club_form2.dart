import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/club/form/club_form3.dart';
import 'package:learningx_flutter_app/api/model/club_model.dart';
import 'package:learningx_flutter_app/api/provider/club_provider.dart';

class ClubForm2Activity extends ConsumerStatefulWidget {
  final String clubId;
  final bool isNewClub;
  const ClubForm2Activity(
      {super.key, required this.clubId, required this.isNewClub});

  @override
  ConsumerState<ClubForm2Activity> createState() => _FestFormState();
}

class _FestFormState extends ConsumerState<ClubForm2Activity> {
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController linkedInController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController learning1Controller = TextEditingController();
  final TextEditingController learning2Controller = TextEditingController();
  final TextEditingController learning3Controller = TextEditingController();
  final TextEditingController learning4Controller = TextEditingController();
  final TextEditingController learning5Controller = TextEditingController();
  final TextEditingController learning6Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    linkedInController.dispose();
    instagramController.dispose();
    websiteController.dispose();
    learning1Controller.dispose();
    learning2Controller.dispose();
    learning3Controller.dispose();
    learning4Controller.dispose();
    learning5Controller.dispose();
    learning6Controller.dispose();
    super.dispose();
  }

  void nextBtnClicked() async {
    List<Learning> learnings = [];
    learnings.add(Learning(learning: learning1Controller.text));
    learnings.add(Learning(learning: learning2Controller.text));
    learnings.add(Learning(learning: learning3Controller.text));
    learnings.add(Learning(learning: learning4Controller.text));
    learnings.add(Learning(learning: learning5Controller.text));
    learnings.add(Learning(learning: learning6Controller.text));
    Map<String, dynamic> data = HashMap();
    data['linkedIn'] = linkedInController.text;
    data['instagram'] = instagramController.text;
    data['website'] = websiteController.text;
    data['learnings'] = learnings.map((learning) => learning.toJson()).toList();
    data['_id'] = widget.clubId;
    await ref
        .read(selectedClubProvider(widget.clubId).notifier)
        .updateClubApi(context, data);
    Navigator.pop(context);
    if (!widget.isNewClub) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ClubForm3Screen(
                  clubId: widget.clubId,
                )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final clubData = ref.watch(selectedClubProvider(widget.clubId));
    setState(() {
      linkedInController.text = clubData.linkedIn;
      instagramController.text = clubData.instagram;
      websiteController.text = clubData.website;
      if (clubData.learnings.isNotEmpty) {
        learning1Controller.text = clubData.learnings[0].learning;
      }
      if (clubData.learnings.length > 1) {
        learning2Controller.text = clubData.learnings[1].learning;
      }
      if (clubData.learnings.length > 2) {
        learning3Controller.text = clubData.learnings[2].learning;
      }
      if (clubData.learnings.length > 3) {
        learning4Controller.text = clubData.learnings[3].learning;
      }
      if (clubData.learnings.length > 4) {
        learning5Controller.text = clubData.learnings[4].learning;
      }
      if (clubData.learnings.length > 5) {
        learning6Controller.text = clubData.learnings[5].learning;
      }
    });
    return Scaffold(
        appBar: AppBar(
          title: const Text('Description of Club'),
          backgroundColor: const Color.fromARGB(255, 211, 232, 255),
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Social Link',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: websiteController,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        label: const Text('Website link'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: linkedInController,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        label: const Text('linkedIn link'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: instagramController,
                      keyboardType: TextInputType.url,
                      decoration: InputDecoration(
                        label: const Text('Instagram link'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'What will people learn from club ? (*minimum 3 learnings)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                    TextFormField(
                      controller: learning1Controller,
                      decoration: const InputDecoration(
                        hintText: '1.',
                      ),
                    ),
                    TextFormField(
                      controller: learning2Controller,
                      decoration: const InputDecoration(
                        hintText: '2.',
                      ),
                    ),
                    TextFormField(
                      controller: learning3Controller,
                      decoration: const InputDecoration(
                        hintText: '3.',
                      ),
                    ),
                    TextFormField(
                      controller: learning4Controller,
                      decoration: const InputDecoration(
                        hintText: '4.',
                      ),
                    ),
                    TextFormField(
                      controller: learning5Controller,
                      decoration: const InputDecoration(
                        hintText: '5.',
                      ),
                    ),
                    TextFormField(
                      controller: learning6Controller,
                      decoration: const InputDecoration(
                        hintText: '6.',
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    if (!widget.isNewClub) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ClubForm3Screen(
                                  clubId: widget.clubId,
                                )),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.skip_next,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  label: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: nextBtnClicked,
                  icon: const Icon(
                    Icons.navigate_next,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  label: const Text(
                    'Next',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
