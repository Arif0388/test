import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:learningx_flutter_app/api/common/image_cropper.dart';
import 'package:learningx_flutter_app/api/model/profile_model.dart';
import 'package:learningx_flutter_app/api/model/uploaded_file_model.dart';
import 'package:learningx_flutter_app/api/provider/profile_provider.dart';
import 'package:learningx_flutter_app/api/provider/upload_file_provider.dart';

class EditProfileActivity extends ConsumerStatefulWidget {
  final Profile profile;
  const EditProfileActivity({super.key, required this.profile});

  @override
  ConsumerState<EditProfileActivity> createState() =>
      _EditProfileActivityState();
}

class _EditProfileActivityState extends ConsumerState<EditProfileActivity> {
  String birtday = '01/01/1970';
  String gender = 'male';
  final List<String> genderOptions = ['male', 'female', 'other'];
  File? _image;
  XFile? _selectedFile;

  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();

  @override
  void initState() {
    setState(() {
      firstnameController.text = widget.profile.user.firstname;
      lastnameController.text = widget.profile.user.lastname;
      bioController.text = widget.profile.bio;
      locationController.text = widget.profile.currentLocation;
      websiteController.text = widget.profile.website;
      gender = widget.profile.gender;
      birtday = widget.profile.birthday;
    });
    super.initState();
  }

  @override
  void dispose() {
    websiteController.dispose();
    bioController.dispose();
    locationController.dispose();
    super.dispose();
  }

  void addImageBtnClicked() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    File? image =
        await ImageCropperPage.cropImage(context, File(pickedFile!.path), 1, 1);
    setState(() {
      _image = image;
      _selectedFile = pickedFile;
    });
  }

  void _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        birtday = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  void nextBtnClicked() async {
    if (firstnameController.text.isEmpty || lastnameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("* field required!")),
      );
      return;
    }
    Map<String, dynamic> data = HashMap();
    if (_image != null) {
      try {
        // Trigger file upload
        List<UploadedFileModel> results = await UploadFileProvider.uploadImage(
            _selectedFile!.name, [_image!], true);
        setState(() {
          data['userImg'] = results[0].location;
        });
        print('Upload successful: ${results[0].location}');
      } catch (e) {
        print('Upload failed: $e');
      }
    } else {
      print('No file selected');
    }
    print("clicked");
    data['firstname'] = firstnameController.text;
    data['lastname'] = lastnameController.text;
    data['website'] = websiteController.text;
    data['currentLocation'] = locationController.text;
    data['bio'] = bioController.text;
    data['gender'] = gender;
    data['birthday'] = birtday;
    data['_id'] = widget.profile.id;
    await ref
        .read(profileProvider(widget.profile.id).notifier)
        .updateProfileApi(context, data);
    await ref
        .read(profileProvider(widget.profile.id).notifier)
        .updateUserApi(context, data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () {
                nextBtnClicked();
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    const Color.fromARGB(255, 112, 172, 235)),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _image == null
                  ? Center(
                      child: Image.network(
                      widget.profile.user.userImg,
                      width: 120,
                    ))
                  : kIsWeb
                      ? Center(
                          child: Image.network(
                            _image!.path,
                            width: 120,
                          ),
                        )
                      : Center(child: Image.file(_image!, width: 120)),
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

              TextField(
                controller: firstnameController,
                decoration: InputDecoration(
                  label: const Text('First Name*'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLength: 25,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: lastnameController,
                decoration: InputDecoration(
                  label: const Text('Last Name*'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLength: 25,
              ),
              // const Text(
              //   'Phone number :- ',
              //   style: TextStyle(
              //     fontWeight: FontWeight.bold,
              //     fontSize: 13,
              //     color: Colors.black,
              //   ),
              // ),
              // const SizedBox(height: 8),
              // TextFormField(
              //   decoration: InputDecoration(
              //     hintText: 'Phone number',
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //   ),
              //   keyboardType: TextInputType.phone,
              //   maxLength: 10,
              //   maxLines: 1,
              //   // controller: _phoneController,
              // ),
              Row(
                children: [
                  const Text(
                    'Birthday :-',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    birtday,
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () {
                      _selectDate();
                    },
                    icon: const Icon(Icons.calendar_today),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownMenu<String>(
                initialSelection: gender,
                label: const Text('Gender'),
                onSelected: (String? newValue) {
                  setState(() {
                    gender = newValue!;
                  });
                },
                dropdownMenuEntries: genderOptions
                    .map<DropdownMenuEntry<String>>((String value) {
                  return DropdownMenuEntry<String>(
                    value: value,
                    label: value,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: bioController,
                decoration: InputDecoration(
                  label: const Text('Bio'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.multiline,
                maxLength: 160,
                maxLines: null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                  label: const Text('Current Living'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.text,
                maxLength: 50,
                maxLines: 1,
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  label: const Text('Website'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.url,
                maxLength: 100,
                maxLines: 1,
                controller: websiteController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
