// ignore_for_file: use_build_context_synchronously

import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:learningx_flutter_app/api/common/image_cropper.dart';
import 'package:learningx_flutter_app/api/model/college_model.dart';
import 'package:learningx_flutter_app/api/model/event_model.dart';
import 'package:learningx_flutter_app/api/model/uploaded_file_model.dart';
import 'package:learningx_flutter_app/api/provider/event_feed_provider.dart';
import 'package:learningx_flutter_app/api/provider/event_manage_provider.dart';
import 'package:learningx_flutter_app/api/provider/upload_file_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClubWorkshopForm extends ConsumerStatefulWidget {
  final Map<String, String> formData;
  const ClubWorkshopForm({super.key, required this.formData});

  @override
  ConsumerState<ClubWorkshopForm> createState() => _ClubWorkshopFormState();
}

class _ClubWorkshopFormState extends ConsumerState<ClubWorkshopForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  File? _image;
  XFile? _selectedFile;
  String eventImg =
      "https://learningx-s3.s3.ap-south-1.amazonaws.com/image_850_315.png";
  String startDate = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
  String startIsoDate = DateTime.now().toUtc().toIso8601String();
  String endDate = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
  String endIsoDate = DateTime.now().toUtc().toIso8601String();
  bool isOffline = false;
  bool isPublic = false;
  String _collegeId = "";

  @override
  void initState() {
    if (widget.formData.containsKey('eventId')) {
      _initialize(widget.formData['eventId']!);
    }
    _loadCurrentUser();
    super.initState();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _collegeId = prefs.getString("college") ?? "";
    });
  }

  Future<void> _initialize(String eventId) async {
    await ref
        .read(eventManageProvider(eventId).notifier)
        .fetchSelectedEvent(eventId);
    final eventData = ref.read(eventManageProvider(eventId));
    setState(() {
      _eventNameController.text = eventData.eventTitle;
      _locationController.text = eventData.venue.address;
      _linkController.text = eventData.eventLink;
      descriptionController.text = eventData.description;
      isOffline = eventData.location == "offline";
      eventImg = eventData.eventImg;
      startDate = DateFormat('dd/MM/yyyy HH:mm')
          .format(eventData.eventStartedAtDate.toLocal());
      startIsoDate = eventData.eventStartDate;
      endDate = DateFormat('dd/MM/yyyy HH:mm')
          .format(eventData.eventEndedAtDate.toLocal());
      endIsoDate = eventData.eventEndDate;
    });
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

  void calenderBtnClicked(bool isStartDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isStartDate) {
            startDate = DateFormat('dd/MM/yyyy HH:mm').format(pickedDateTime);
            startIsoDate = pickedDateTime.toUtc().toIso8601String();
          } else {
            endDate = DateFormat('dd/MM/yyyy HH:mm').format(pickedDateTime);
            endIsoDate = pickedDateTime.toUtc().toIso8601String();
          }
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
    if (_formKey.currentState?.validate() ?? false) {
      Map<String, dynamic> data = HashMap();
      String imgdata = eventImg;

      if (_image != null) {
        List<UploadedFileModel> results = await UploadFileProvider.uploadImage(
            _selectedFile!.name, [_image!], true);
        imgdata = results[0].location;
      }

      data['eventTitle'] = _eventNameController.text;
      data['eventImg'] = imgdata;

      if (widget.formData.containsKey("clubId")) {
        data['club'] = widget.formData['clubId'];
      }

      if (widget.formData.containsKey("collegeId") && isPublic) {
        data['college'] = widget.formData['collegeId'];
      }

      data['eventType'] = "workshop";
      if (widget.formData.containsKey("collegeId") &&
          widget.formData['collegeId'] == dotenv.env['NIET_COLLEGE_ID']) {
        data['verified'] = false;
      }
      data['description'] = descriptionController.text;
      data['eventStartDate'] = startIsoDate;
      data['eventEndDate'] = endIsoDate;
      data['location'] = isOffline ? "offline" : "online";
      data['eventLink'] = _linkController.text;
      data['venue'] = City(address: _locationController.text).toJson();
      data['takeRegistration'] = false;

      try {
        if (widget.formData.containsKey('eventId')) {
          data['_id'] = widget.formData['eventId'];
          await ref
              .read(eventManageProvider(widget.formData['eventId']!).notifier)
              .updateEventApi(context, data);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Workshop Updated!'),
            ));
          }
        } else {
          data['stepsDone'] = 6;
          data['visibility'] = isPublic ? "college" : "private";
          Event event = await createEventApi(context, data);
          ref
              .read(eventFeedProvider(_collegeId).notifier)
              .addEvent(EventItem.fromEvent(event));

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Workshop Created!'),
            ));
          }
        }
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to create workshop!'),
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        title: Text(widget.formData.containsKey('eventId')
            ? "Edit Workshop"
            : 'Create Club Workshop'),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _image == null
                    ? Image.network(eventImg)
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
                  'Workshop title* -',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
                TextFormField(
                  controller: _eventNameController,
                  decoration: const InputDecoration(
                    hintText: 'Workshop title',
                  ),
                  maxLength: 50,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an workshop title';
                    }
                    return null;
                  },
                ),
                const Text(
                  'Description*',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Description',
                  ),
                  minLines: 2,
                  maxLines: null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a event description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Start Date* -',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      startDate,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () {
                        calenderBtnClicked(true);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'End Date* -',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      endDate,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () {
                        calenderBtnClicked(false);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (widget.formData.containsKey("collegeId"))
                  const Text(
                    'Visibility*',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                if (widget.formData.containsKey("collegeId"))
                  const SizedBox(height: 8),
                if (widget.formData.containsKey("collegeId"))
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 60,
                          child: _buildActionButton(Icons.public, "Public",
                              "Only in Campus", isPublic),
                        ),
                      ),
                      const SizedBox(width: 10), // Spacing between buttons
                      Expanded(
                        child: SizedBox(
                          height: 60,
                          child: _buildActionButton(Icons.lock_outline,
                              "Private", "Only in Club", !isPublic),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Location :- '),
                    Row(
                      children: [
                        Radio<bool>(
                          value: false,
                          groupValue: isOffline,
                          onChanged: onRadioButtonClicked,
                        ),
                        const Text('Online'),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: isOffline,
                          onChanged: onRadioButtonClicked,
                        ),
                        const Text('Offline'),
                      ],
                    ),
                  ],
                ),
                if (!isOffline) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Workshop Link* -',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                  TextFormField(
                    controller: _linkController,
                    decoration: const InputDecoration(
                      hintText: 'Workshop Link',
                    ),
                    validator: (value) {
                      if (!isOffline && (value == null || value.isEmpty)) {
                        return 'Please enter an workshop link';
                      }
                      return null;
                    },
                  ),
                ],
                if (isOffline) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Workshop Venue* -',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      hintText: 'Workshop Venue',
                    ),
                    validator: (value) {
                      if (isOffline && (value == null || value.isEmpty)) {
                        return 'Please enter an workshop venue';
                      }
                      return null;
                    },
                  ),
                ],
              ],
            ),
          )),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            nextBtnClicked();
          },
          child: Text(widget.formData.containsKey('eventId')
              ? "Update Workshop"
              : 'Create Workshop'),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, String subtitle, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (label == "Public") {
            isPublic = true;
          } else {
            isPublic = false;
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
              child: Icon(icon, size: 24, color: Colors.black),
            ),
            const SizedBox(width: 16), // Space between icon and text
            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center vertically
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                        fontSize: 14, color: Color.fromARGB(255, 76, 103, 147)),
                  ),
                  const SizedBox(height: 4), // Small gap between text lines
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
