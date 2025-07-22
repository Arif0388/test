import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:learningx_flutter_app/api/common/image_cropper.dart';
import 'package:learningx_flutter_app/api/model/college_model.dart';
import 'package:learningx_flutter_app/api/model/fest_model.dart';
import 'package:learningx_flutter_app/api/model/uploaded_file_model.dart';
import 'package:learningx_flutter_app/api/provider/event_manage_provider.dart';
import 'package:learningx_flutter_app/api/provider/fest_provider.dart';
import 'package:learningx_flutter_app/api/provider/upload_file_provider.dart';

class BasicDetails extends ConsumerStatefulWidget {
  final Map<String, String> formData;
  final Function(Map<String, dynamic>) onSave;

  const BasicDetails({Key? key, required this.formData, required this.onSave})
      : super(key: key);

  @override
  ConsumerState<BasicDetails> createState() => BasicDetailsState();
}

class BasicDetailsState extends ConsumerState<BasicDetails> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
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
  String? _eventType;
  bool isOffline = false;
  String? _selectedFest;
  List<Fest> fests = [];

  @override
  void initState() {
    if (widget.formData.containsKey('eventId')) {
      _initialize(widget.formData['eventId']!);
    }
    super.initState();
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
      _eventType = eventData.eventType;
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

  Future<bool> saveDetails() async {
    if (_formKey.currentState?.validate() ?? false) {
      String imgdata = eventImg;
      if (_image != null) {
        List<UploadedFileModel> results = await UploadFileProvider.uploadImage(
            _selectedFile!.name, [_image!], true);
        imgdata = results[0].location;
      }
      widget.onSave({
        'eventTitle': _eventNameController.text,
        'eventImg': imgdata,
        if (widget.formData.containsKey("clubId"))
          'club': widget.formData['clubId'],
        if (widget.formData.containsKey("collegeId"))
          'college': widget.formData['collegeId'],
        if (widget.formData.containsKey("festId"))
          'festival': widget.formData['festId'],
        if (fests.isNotEmpty && !widget.formData.containsKey('eventId'))
          'festival': _selectedFest,
        if (widget.formData.containsKey("clubId") &&
            widget.formData.containsKey("collegeId") &&
            widget.formData['collegeId'] == dotenv.env['NIET_COLLEGE_ID'])
          'verified': false,
        'eventType': _eventType,
        'eventStartDate': startIsoDate,
        'eventEndDate': endIsoDate,
        'location': isOffline ? "offline" : "online",
        'eventLink': _linkController.text,
        'venue': City(address: _locationController.text).toJson(),
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final String? collegeId = widget.formData['collegeId'];
    AsyncValue<List<Fest>> festAsyncValue =
        collegeId != null && !widget.formData.containsKey('festId')
            ? ref.watch(festProvider("?college=$collegeId"))
            : const AsyncValue.data([]);

    festAsyncValue.whenData((value) {
      print(value);
      setState(() {
        fests = value;
      });
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
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
                  'Change Image',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Event Name', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            TextFormField(
              controller: _eventNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an event name';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            if (fests.isNotEmpty && !widget.formData.containsKey('eventId'))
              const Text('Festival Name (Optional)',
                  style: TextStyle(fontSize: 14)),
            if (fests.isNotEmpty && !widget.formData.containsKey('eventId'))
              const SizedBox(height: 4),
            if (fests.isNotEmpty && !widget.formData.containsKey('eventId'))
              DropdownButtonFormField<String>(
                value: _selectedFest,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: fests
                    .map((item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(item.festName),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFest = value;
                  });
                },
              ),
            const SizedBox(height: 8),
            const Text('Event Type', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: _eventType,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: ['Contest Event', 'Non-Contest Event']
                  .map((label) => DropdownMenuItem(
                        value: label == "Contest Event"
                            ? "contest"
                            : "entertainment",
                        child: Text(label),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _eventType = value;
                });
              },
              validator: (value) =>
                  value == null ? 'Please select an event type' : null,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Event Start Date* -',
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
                  'Event End Date* -',
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
            Row(
              children: [
                const Text('Location: '),
                Radio<bool>(
                  value: false,
                  groupValue: isOffline,
                  onChanged: onRadioButtonClicked,
                ),
                const Text('Online'),
                Radio<bool>(
                  value: true,
                  groupValue: isOffline,
                  onChanged: onRadioButtonClicked,
                ),
                const Text('Offline'),
              ],
            ),
            const SizedBox(height: 8),
            if (isOffline)
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location Venue',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              )
            else
              TextFormField(
                controller: _linkController,
                decoration: InputDecoration(
                  labelText: 'Event Link',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
