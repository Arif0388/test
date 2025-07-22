// ignore_for_file: use_build_context_synchronously

import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:learningx_flutter_app/api/common/image_cropper.dart';
import 'package:learningx_flutter_app/api/model/channel_model.dart';
import 'package:learningx_flutter_app/api/model/session_model.dart';
import 'package:learningx_flutter_app/api/model/uploaded_file_model.dart';
import 'package:learningx_flutter_app/api/provider/session_provider.dart';
import 'package:learningx_flutter_app/api/provider/upload_file_provider.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';

class SessionFormActivity extends ConsumerStatefulWidget {
  final Channel? channel;
  final Session? session;
  const SessionFormActivity({super.key, this.channel, this.session});

  @override
  ConsumerState<SessionFormActivity> createState() =>
      _SessionFormActivityState();
}

class _SessionFormActivityState extends ConsumerState<SessionFormActivity> {
  File? _image;
  XFile? _selectedFile;
  String sessionImg =
      "https://learningx-s3.s3.ap-south-1.amazonaws.com/image_2_1.png";
  String startDate = DateFormat('dd MMM yyyy HH:mm:ss').format(DateTime.now());
  String startIsoDate = DateTime.now().toUtc().toIso8601String();
  bool isOffline = false;

  final TextEditingController sessionTitleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController sessionLinkController = TextEditingController();
  final TextEditingController venueController = TextEditingController();

  @override
  void initState() {
    if (widget.session != null) {
      setState(() {
        sessionTitleController.text = widget.session!.title;
        descriptionController.text = widget.session!.description;
        durationController.text = "${widget.session!.duration}";
        sessionLinkController.text = widget.session!.sessionLink;
        venueController.text = widget.session!.venue;
        startDate = Utils.formatDate(widget.session!.startedAtDate);
        startIsoDate = widget.session!.startTime;
        isOffline = widget.session!.location == "offline";
        sessionImg = widget.session!.sessionImg;
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    sessionTitleController.dispose();
    descriptionController.dispose();
    durationController.dispose();
    sessionLinkController.dispose();
    venueController.dispose();
    super.dispose();
  }

  void addImageBtnClicked() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    File? image =
        await ImageCropperPage.cropImage(context, File(pickedFile!.path), 2, 1);
    setState(() {
      _image = image;
      _selectedFile = pickedFile;
    });
  }

  void calenderBtnClicked() async {
    // Show the date picker first
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // Show the time picker after a date has been selected
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        // Combine the picked date and time into a single DateTime object
        DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Format the combined DateTime object to ISO 8601 string
        setState(() {
          startDate = Utils.formatDate(pickedDateTime);
          startIsoDate = pickedDateTime.toUtc().toIso8601String();
        });
      }
    }
  }

  void onRadioButtonClicked(bool? isSelected) {
    setState(() {
      isOffline = isSelected ?? false;
    });
  }

  void nextBtnClicked() async {
    if (sessionTitleController.text.isEmpty ||
        durationController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("* field required!")),
      );
      return;
    }
    Map<String, dynamic> data = HashMap();
    if (_image != null) {
      List<UploadedFileModel> results = await UploadFileProvider.uploadImage(
          _selectedFile!.name, [_image!], true);
      data['sessionImg'] = results[0].location;
    }
    data['title'] = sessionTitleController.text;
    data['location'] = isOffline ? "offline" : "online";
    data['venue'] = venueController.text;
    data['sessionLink'] = sessionLinkController.text;
    data['description'] = descriptionController.text;
    data['startTime'] = startIsoDate;
    data['duration'] = int.tryParse(durationController.text) ?? 0;

    // Check if the session already exists for update
    if (widget.session != null) {
      data['club'] = widget.session!.club.id;
      data['channel'] = widget.session!.channel;
      data['_id'] = widget.session!.id;
      try {
        print('Session updated successfully');
        await ref
            .read(
                sessionProvider("${widget.session!.channel}/session").notifier)
            .updateSession(context, data);
      } catch (e) {
        print('Error updating session: $e');
      }
    } else {
      // Create new session
      if (widget.channel != null) {
        data['club'] = widget.channel!.club;
        data['channel'] = widget.channel!.id;
      } else {
        // Handle case where channel is null, e.g., assign default values or show an error
        print('Channel is null, cannot create session');
        return; // Exit the function if channel is null and session creation depends on it
      }

      try {
        await ref
            .read(sessionProvider("${widget.channel!.id}/session").notifier)
            .createSession(context, data);
        print('Session created successfully');
      } catch (e) {
        print('Error creating session: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        title: Text(widget.session != null ? "Edit Session" : 'Create session'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _image == null
                ? Image.network(sessionImg)
                : kIsWeb
                    ? Image.network(_image!.path)
                    : Image.file(_image!),
            Center(
              child: TextButton(
                onPressed: addImageBtnClicked,
                child: const Text(
                  'change image',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Session title* -',
              style: TextStyle(fontSize: 12, color: Colors.blue),
            ),
            TextField(
              controller: sessionTitleController,
              decoration: const InputDecoration(
                hintText: 'Session title',
              ),
              maxLength: 50,
            ),
            const Text(
              'Description*',
              style: TextStyle(fontSize: 12, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                hintText: 'Description',
              ),
              minLines: 2,
              maxLines: null,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Start Date & time*',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
                const SizedBox(width: 8),
                Text(
                  startDate,
                  style: const TextStyle(fontSize: 15, color: Colors.black),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: calenderBtnClicked,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Duration* (in minutes) -',
              style: TextStyle(fontSize: 12, color: Colors.blue),
            ),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(
                hintText: '60',
              ),
              keyboardType: TextInputType.number,
              maxLength: 50,
            ),
            const Text(
              'Visibility*',
              style: TextStyle(fontSize: 12, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child:
                        _buildActionButton(Icons.public, "Online", !isOffline),
                  ),
                ),
                const SizedBox(width: 10), // Spacing between buttons
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: _buildActionButton(
                        Icons.public_off, "Offline", isOffline),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!isOffline) ...[
              const SizedBox(height: 8),
              const Text(
                'Session Link* -',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
              TextField(
                controller: sessionLinkController,
                decoration: const InputDecoration(
                  hintText: 'Session Link',
                ),
                maxLength: 50,
              ),
            ],
            if (isOffline) ...[
              const SizedBox(height: 8),
              const Text(
                'Session Venue* -',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
              TextField(
                controller: venueController,
                decoration: const InputDecoration(
                  hintText: 'Session Venue',
                ),
                maxLength: 100,
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            nextBtnClicked();
          },
          child: Text(
              widget.session != null ? "Update session" : 'Create Session'),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (label == "Offline") {
            isOffline = true;
          } else {
            isOffline = false;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: isActive
              ? const Color.fromARGB(255, 244, 248, 253)
              : const Color.fromARGB(255, 238, 238, 238),
          border: Border.all(
              color: isActive
                  ? const Color.fromARGB(255, 49, 113, 222)
                  : Colors.black,
              width: 1.0), // Add border here
          borderRadius:
              BorderRadius.circular(12.0), // Rounded corners for the border
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white
                    : const Color.fromARGB(255, 244, 248, 253),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(icon, size: 20, color: Colors.black),
            ),
            const SizedBox(width: 16), // Space between icon and text
            Text(
              label,
              style: const TextStyle(
                  fontSize: 14, color: Color.fromARGB(255, 76, 103, 147)),
            ),
          ],
        ),
      ),
    );
  }
}
