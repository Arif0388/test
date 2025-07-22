// ignore_for_file: library_prefixes

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/api/model/channel_model.dart';
import 'package:learningx_flutter_app/api/provider/discussion_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CreatePollScreen extends StatefulWidget {
  final Channel channel;
  final IO.Socket? socket;
  const CreatePollScreen({super.key, required this.channel, this.socket});

  @override
  State<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController questionController = TextEditingController();
  final List<TextEditingController> optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  bool allowMultipleAnswers = false;
  bool isAnonymous = false;
  var _currentUserId = "";
  var lastSeenBy = [];

  @override
  void initState() {
    super.initState();
    // Schedule initialization after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    await _loadCurrentUser();
    // _connectToWebSocket();
  }

  @override
  void dispose() {
    questionController.dispose();
    //optionControllers.dispose();
    super.dispose();
  }

  // Load counter value from SharedPreferences
  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('id') ?? "";
      lastSeenBy.add(_currentUserId);
    });
  }

  void addOption() {
    setState(() {
      optionControllers.add(TextEditingController());
    });
  }

  void removeOption(int index) {
    setState(() {
      optionControllers.removeAt(index);
    });
  }

  void submitPoll() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Collect poll data
      String question = questionController.text;
      List<String> options = optionControllers.map((e) => e.text).toList();

      Map<String, dynamic> map = HashMap();
      map['channel'] = widget.channel.id;
      map['club'] = widget.channel.club;
      map['room'] = widget.channel.id;
      map['seenBy'] = lastSeenBy;
      map['filetype'] = "poll";
      map['poll'] = {
        "question": question,
        "options": options,
        "allowMultipleAnswers": allowMultipleAnswers,
        "isAnonymous": isAnonymous
      };
      String chatId = await sendDiscussion(map);
      if (widget.socket != null) {
        map['_id'] = chatId;
        widget.socket!.emit('chatMessage', map);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Poll'),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        elevation: 0,
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Question',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                TextFormField(
                  controller: questionController,
                  decoration: const InputDecoration(
                    hintText: 'Ask question',
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an question';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      'Allow multiple answers',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    Switch(
                      value: allowMultipleAnswers,
                      onChanged: (value) {
                        setState(() {
                          allowMultipleAnswers = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Poll Anonymous',
                      style: TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    Switch(
                      value: isAnonymous,
                      onChanged: (value) {
                        setState(() {
                          isAnonymous = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Options',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: optionControllers.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: optionControllers[index],
                              decoration: const InputDecoration(
                                hintText: '+ Add',
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 8),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Options must not be empty';
                                }
                                return null;
                              },
                            ),
                          ),
                          if (optionControllers.length > 2)
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              onPressed: () => removeOption(index),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                if (optionControllers.length < 12)
                  ElevatedButton(
                    onPressed: addOption,
                    child: const Text('+ Add'),
                  ),
              ],
            ),
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: submitPoll,
        backgroundColor: const Color.fromARGB(255, 56, 114, 220),
        child: const Icon(
          Icons.send,
          color: Colors.white,
        ),
      ),
    );
  }
}
