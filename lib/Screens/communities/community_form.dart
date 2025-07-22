import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learningx_flutter_app/api/common/image_cropper.dart';
import 'package:learningx_flutter_app/api/model/community_model.dart';
import 'package:learningx_flutter_app/api/model/uploaded_file_model.dart';
import 'package:learningx_flutter_app/api/provider/club_provider.dart';
import 'package:learningx_flutter_app/api/provider/community_provider.dart';
import 'package:learningx_flutter_app/api/provider/upload_file_provider.dart';

class CommunityForm extends ConsumerStatefulWidget {
  final Community? community;
  const CommunityForm({super.key, this.community});

  @override
  ConsumerState<CommunityForm> createState() => _CommunityFormState();
}

class _CommunityFormState extends ConsumerState<CommunityForm> {
  File? _image;
  XFile? _selectedFile;
  String communityImg =
      "https://learningx-s3.s3.ap-south-1.amazonaws.com/image_2_1.png";

  final TextEditingController nameController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController linkedInController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    if (widget.community != null) {
      setState(() {
        nameController.text = widget.community!.title;
        websiteController.text = widget.community!.website;
        emailController.text = widget.community!.email;
        linkedInController.text = widget.community!.linkedIn;
        instagramController.text = widget.community!.instagram;
        descriptionController.text = widget.community!.description;
        communityImg = widget.community!.coverImg;
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
      data['communityImg'] = results[0].location;
      data['clubImg'] = results[0].location;
    }
    data['communityName'] = nameController.text;
    data['clubName'] = nameController.text;
    data['website'] = websiteController.text;
    data['email'] = emailController.text;
    data['linkedIn'] = linkedInController.text;
    data['instagram'] = instagramController.text;
    data['description'] = descriptionController.text;
    if (widget.community != null) {
      data['_id'] = widget.community!.id;
      await updateClubApi(context, data);
      await ref
          .read(selectedCommunityProvider(widget.community!.id).notifier)
          .updateCommunityApi(context, data);
    } else {
      await createCommunityApi(context, data);
    }
    Navigator.pop(context); // Close the update form
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.community != null
            ? "Edit Community Page"
            : 'Create Community Page'),
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
                  ? Image.network(communityImg)
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
                'Community Name* -',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Community Name',
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
                'Tell people about your Community*',
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
