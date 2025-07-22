import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learningx_flutter_app/api/common/image_cropper.dart';
import 'package:learningx_flutter_app/api/model/council_model.dart';
import 'package:learningx_flutter_app/api/model/uploaded_file_model.dart';
import 'package:learningx_flutter_app/api/provider/club_provider.dart';
import 'package:learningx_flutter_app/api/provider/council_provider.dart';
import 'package:learningx_flutter_app/api/provider/upload_file_provider.dart';

class CouncilForm extends ConsumerStatefulWidget {
  final Council? council;
  final String collegeId;
  const CouncilForm({super.key, this.council, required this.collegeId});

  @override
  ConsumerState<CouncilForm> createState() => _CouncilFormState();
}

class _CouncilFormState extends ConsumerState<CouncilForm> {
  File? _image;
  XFile? _selectedFile;
  String councilImg =
      "https://learningx-s3.s3.ap-south-1.amazonaws.com/image_2_1.png";

  final TextEditingController nameController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController linkedInController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    if (widget.council != null) {
      setState(() {
        nameController.text = widget.council!.councilName;
        websiteController.text = widget.council!.website;
        emailController.text = widget.council!.email;
        linkedInController.text = widget.council!.linkedIn;
        instagramController.text = widget.council!.instagram;
        descriptionController.text = widget.council!.description;
        councilImg = widget.council!.councilImg;
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
      data['councilImg'] = results[0].location;
      data['clubImg'] = results[0].location;
    }
    data['councilName'] = nameController.text;
    data['clubName'] = nameController.text;
    data['website'] = websiteController.text;
    data['email'] = emailController.text;
    data['linkedIn'] = linkedInController.text;
    data['instagram'] = instagramController.text;
    data['description'] = descriptionController.text;
    if (widget.council != null) {
      data['_id'] = widget.council!.id;
      await updateClubApi(context, data);
      await ref
          .read(selectedCouncilProvider(widget.council!.id).notifier)
          .updateCouncilApi(context, data);
    } else {
      data['college'] = widget.collegeId;
      await createCouncilApi(context, data);
    }
    Navigator.pop(context); // Close the update form
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.council != null
            ? "Edit Council Page"
            : 'Create Council Page'),
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
                  ? Image.network(councilImg)
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
                'Council Name* -',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Council Name',
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
                'Tell people about your Council*',
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
