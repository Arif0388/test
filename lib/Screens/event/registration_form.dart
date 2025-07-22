import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/event/event_member_form.dart';
import 'package:learningx_flutter_app/api/model/event_model.dart';
import 'package:learningx_flutter_app/api/model/event_team_model.dart';
import 'package:learningx_flutter_app/api/provider/event_provider.dart';
import 'package:learningx_flutter_app/api/provider/extra_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventRegisterForm extends ConsumerStatefulWidget {
  final Event event;
  final void Function(EventTeam) onRegistration;
  const EventRegisterForm(
      {super.key, required this.event, required this.onRegistration});

  @override
  ConsumerState<EventRegisterForm> createState() => _EventRegisterState();
}

class _EventRegisterState extends ConsumerState<EventRegisterForm> {
  final TextEditingController nameController = TextEditingController();
  int teamSize = 1;
  List<TextEditingController> memberNameControllers = [];
  List<TextEditingController> emailControllers = [];
  List<TextEditingController> phoneControllers = [];
  List<TextEditingController> collegeControllers = [];
  List<TextEditingController> descriptionControllers = [];
  String _collegeId = "";

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    setState(() {
      teamSize = widget.event.minSizeTeam;
    });
    // Initialize controllers based on team size
    for (int i = 0; i < teamSize; i++) {
      memberNameControllers.add(TextEditingController());
      emailControllers.add(TextEditingController());
      phoneControllers.add(TextEditingController());
      collegeControllers.add(TextEditingController());
      descriptionControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    for (var controller in memberNameControllers) {
      controller.dispose();
    }
    for (var controller in emailControllers) {
      controller.dispose();
    }
    for (var controller in phoneControllers) {
      controller.dispose();
    }
    for (var controller in collegeControllers) {
      controller.dispose();
    }
    for (var controller in descriptionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _collegeId = prefs.getString("college") ?? "";
    });
  }

  void addMemberClicked() {
    if (teamSize < widget.event.maxSizeTeam) {
      setState(() {
        teamSize += 1;
        memberNameControllers.add(TextEditingController());
        emailControllers.add(TextEditingController());
        phoneControllers.add(TextEditingController());
        collegeControllers.add(TextEditingController());
        descriptionControllers.add(TextEditingController());
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member added!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Max team size is ${widget.event.maxSizeTeam}.'),
        ),
      );
    }
  }

  void nextBtnClicked() async {
    for (int i = 0; i < teamSize; i++) {
      if ((nameController.text.isEmpty &&
              widget.event.participation == "team") ||
          memberNameControllers[i].text.isEmpty ||
          emailControllers[i].text.isEmpty ||
          phoneControllers[i].text.isEmpty ||
          collegeControllers[i].text.isEmpty ||
          descriptionControllers[i].text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("* field required!")),
        );
        return;
      }
    }
    Map<String, dynamic> teamData = HashMap();
    teamData['teamName'] = nameController.text;
    teamData['event'] = widget.event.id;
    // Collect member details
    List<Map<String, dynamic>> members = [];
    for (int i = 0; i < teamSize; i++) {
      members.add({
        'memberName': memberNameControllers[i].text,
        'email': emailControllers[i].text,
        'phone': phoneControllers[i].text,
        'college': collegeControllers[i].text,
        'otherDetails': descriptionControllers[i].text,
      });
    }
    teamData['members'] = members;
    EventTeam newTeam = await registerEventApi(context, teamData);
    await logUserActivityApi(context, {
      'activityType': "registeredEvent",
      'college': _collegeId == "" ? null : _collegeId,
      'platform': kIsWeb ? "mWeb" : Platform.operatingSystem
    });
    widget.onRegistration(newTeam);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Register Event"),
            const Spacer(),
            if (widget.event.participation == "team")
              ElevatedButton(
                onPressed: addMemberClicked,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Add members',
                  style: TextStyle(
                    fontSize: 12.0,
                    textBaseline: TextBaseline.alphabetic,
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.event.participation == "team")
                      const Padding(
                        padding: EdgeInsets.only(left: 4.0),
                        child: Text(
                          'Team Name (must be unique)* -',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Color.fromARGB(255, 0, 149,
                                255), // Use the actual activeColor here
                          ),
                        ),
                      ),
                    if (widget.event.participation == "team")
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: 'Team Name',
                          contentPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        ),
                        textInputAction: TextInputAction.done,
                        maxLength: 50,
                      ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: teamSize,
                      itemBuilder: (BuildContext context, int index) {
                        return EventMemberFormCard(
                          memberNameController: memberNameControllers[index],
                          emailController: emailControllers[index],
                          phoneController: phoneControllers[index],
                          collegeController: collegeControllers[index],
                          descriptionController: descriptionControllers[index],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: nextBtnClicked,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
