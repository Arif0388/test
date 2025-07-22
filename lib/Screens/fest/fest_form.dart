import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:learningx_flutter_app/api/common/image_cropper.dart';
import 'package:learningx_flutter_app/api/model/fest_model.dart';
import 'package:learningx_flutter_app/api/model/uploaded_file_model.dart';
import 'package:learningx_flutter_app/api/provider/fest_provider.dart';
import 'package:learningx_flutter_app/api/provider/upload_file_provider.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';

class FestFormActivity extends ConsumerStatefulWidget {
  final Fest? fest;
  final String collegeId;
  const FestFormActivity({super.key, this.fest, required this.collegeId});

  @override
  ConsumerState<FestFormActivity> createState() => _FestFormState();
}

class _FestFormState extends ConsumerState<FestFormActivity> {
  File? _image;
  XFile? _selectedFile;
  String festImg =
      "https://learningx-s3.s3.ap-south-1.amazonaws.com/image_2_1.png";
  String startDate = DateFormat('dd MMM yyyy').format(DateTime.now());
  String endDate = DateFormat('dd MMM yyyy').format(DateTime.now());
  String startIsoDate = DateTime.now().toUtc().toIso8601String();
  String endIsoDate = DateTime.now().toUtc().toIso8601String();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController linkedInController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    if (widget.fest != null) {
      setState(() {
        nameController.text = widget.fest!.festName;
        websiteController.text = widget.fest!.website;
        emailController.text = widget.fest!.email;
        linkedInController.text = widget.fest!.linkedIn;
        instagramController.text = widget.fest!.instagram;
        descriptionController.text = widget.fest!.description;
        festImg = widget.fest!.festImg;
        startDate = Utils.getDateString(widget.fest!.startedAtDate);
        endDate = Utils.getDateString(widget.fest!.endAtDate);
        startIsoDate = widget.fest!.startDate;
        endIsoDate = widget.fest!.endDate;
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    websiteController.dispose();
    emailController.dispose();
    linkedInController.dispose();
    instagramController.dispose();
    descriptionController.dispose();
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

  void calenderBtnClicked(bool isStartDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          startDate = DateFormat('dd MMM yyyy').format(pickedDate);
          startIsoDate = pickedDate.toUtc().toIso8601String();
        } else {
          endDate = DateFormat('dd MMM yyyy').format(pickedDate);
          endIsoDate = pickedDate.toUtc().toIso8601String();
        }
      });
    }
  }

  void nextBtnClicked() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
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
      data['festImg'] = results[0].location;
    }
    data['festName'] = nameController.text;
    data['website'] = websiteController.text;
    data['email'] = emailController.text;
    data['linkedIn'] = linkedInController.text;
    data['instagram'] = instagramController.text;
    data['description'] = descriptionController.text;
    data['startDate'] = startIsoDate;
    data['endDate'] = endIsoDate;
    if (widget.fest != null) {
      data['_id'] = widget.fest!.id;
      await ref
          .read(selectedFestProvider(widget.fest!.id).notifier)
          .updateFestApi(context, data);
    } else {
      data['college'] = widget.collegeId;
      await createFestApi(context, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.fest != null ? "Edit Fest" : 'Create Fest Page'),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _image == null
                  ? Image.network(festImg)
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
                'Fest Name* -',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Fest Name',
                  hintStyle: TextStyle(fontSize: 15),
                ),
                keyboardType: TextInputType.text,
                maxLength: 50,
              ),
              const Text(
                'Website Link -',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
              TextFormField(
                controller: websiteController,
                decoration: const InputDecoration(
                  hintText: 'Website Link',
                  hintStyle: TextStyle(fontSize: 15),
                ),
                keyboardType: TextInputType.url,
                maxLength: 100,
              ),
              const Text(
                'Email Address* -',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'Email Address',
                  hintStyle: TextStyle(fontSize: 15),
                ),
                keyboardType: TextInputType.emailAddress,
                maxLength: 100,
              ),
              const Text(
                'LinkedIn Link -',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
              TextFormField(
                controller: linkedInController,
                decoration: const InputDecoration(
                  hintText: 'LinkedIn Link',
                  hintStyle: TextStyle(fontSize: 15),
                ),
                keyboardType: TextInputType.url,
                maxLength: 100,
              ),
              const Text(
                'Instagram Link -',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
              TextFormField(
                controller: instagramController,
                decoration: const InputDecoration(
                  hintText: 'Instagram Link',
                  hintStyle: TextStyle(fontSize: 15),
                ),
                keyboardType: TextInputType.url,
                maxLength: 100,
              ),
              const Text(
                'Tell people about your Fest*',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: 'Description',
                  hintStyle: const TextStyle(fontSize: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                maxLength: 300,
                minLines: 2,
              ),
              const Text(
                'Start Date*',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
              Row(
                children: [
                  Text(
                    startDate,
                    style: const TextStyle(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () {
                      calenderBtnClicked(true);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'End Date*',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
              Row(
                children: [
                  Text(
                    endDate,
                    style: const TextStyle(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () {
                      calenderBtnClicked(false);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
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
    );
  }
}
