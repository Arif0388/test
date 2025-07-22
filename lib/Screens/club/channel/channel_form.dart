import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/api/model/channel_model.dart';
import 'package:learningx_flutter_app/api/provider/channel_provider.dart';

class ChannelFormScreen extends ConsumerStatefulWidget {
  final String clubId;
  final Channel? channel;
  const ChannelFormScreen({super.key, required this.clubId, this.channel});

  @override
  ConsumerState<ChannelFormScreen> createState() => _ChannelFormState();
}

class _ChannelFormState extends ConsumerState<ChannelFormScreen> {
  String privacy = "standard";
  String permission = "public";
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    if (widget.channel != null) {
      setState(() {
        nameController.text = widget.channel!.name;
        privacy = widget.channel!.privacy;
        permission = widget.channel!.permission;
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void onPrivacyRadioClicked(String? value) {
    setState(() {
      privacy = value ?? "standard";
    });
  }

  void onPermissionRadioClicked(String? value) {
    setState(() {
      permission = value ?? "public";
    });
  }

  void nextBtnClicked() async {
    if (nameController.text.isNotEmpty) {
      Map<String, dynamic> data = HashMap();
      data['name'] = nameController.text;
      data['privacy'] = privacy;
      data['permission'] = permission;
      data['club'] = widget.clubId;
      if (widget.channel != null) {
        data['_id'] = widget.channel!.id;
        await ref
            .read(channelProvider(widget.channel!.club).notifier)
            .updateChannel(context, data);
      } else {
        await ref
            .read(channelProvider(widget.clubId).notifier)
            .createChannel(context, data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.channel != null ? "Edit Channel" : 'Add channel',
        ),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Channel Name* -',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue, // Replace with your active color
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'Channel Name',
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      isDense: true,
                    ),
                    textCapitalization: TextCapitalization.words,
                    maxLength: 50,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Privacy*',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue, // Replace with your active color
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'standard',
                        groupValue: privacy,
                        onChanged: (value) {
                          onPrivacyRadioClicked(value);
                        },
                        activeColor:
                            Colors.blue, // Replace with your active color
                      ),
                      const Text('Standard'),
                      const SizedBox(width: 16),
                      Radio<String>(
                        value: 'private',
                        groupValue: privacy,
                        onChanged: (value) {
                          onPrivacyRadioClicked(value);
                        },
                        activeColor:
                            Colors.blue, // Replace with your active color
                      ),
                      const Text('Private'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '* Standard - Accessible to every on the club (default)',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '* Private - Accessible only to a specific group of people within the club',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Channel permissions to write messages',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue, // Replace with your active color
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'private',
                        groupValue: permission,
                        onChanged: (value) {
                          onPermissionRadioClicked(value);
                        },
                        activeColor:
                            Colors.blue, // Replace with your active color
                      ),
                      const Text('Only Admin'),
                      const SizedBox(width: 16),
                      Radio<String>(
                        value: 'public',
                        groupValue: permission,
                        onChanged: (value) {
                          onPermissionRadioClicked(value);
                        },
                        activeColor:
                            Colors.blue, // Replace with your active color
                      ),
                      const Text('All members'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 0.5,
                  height: 40,
                  color: Colors.black54,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        nextBtnClicked();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Next'),
                    ),
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
