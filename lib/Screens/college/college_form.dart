import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learningx_flutter_app/Screens/auth/signup_form2.dart';
import 'package:learningx_flutter_app/api/common/image_cropper.dart';
import 'package:learningx_flutter_app/api/model/college_model.dart';
import 'package:learningx_flutter_app/api/model/uploaded_file_model.dart';
import 'package:learningx_flutter_app/api/provider/college_provider.dart';
import 'package:learningx_flutter_app/api/provider/upload_file_provider.dart';
import 'package:learningx_flutter_app/api/provider/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollegeFormActivity extends ConsumerStatefulWidget {
  final Map<String, dynamic>? signupData;
  final College? college;
  const CollegeFormActivity({super.key, this.signupData, this.college});

  @override
  ConsumerState<CollegeFormActivity> createState() => _CollegeFormState();
}

class _CollegeFormState extends ConsumerState<CollegeFormActivity> {
  File? _image;
  XFile? _selectedFile;
  String collegeImg =
      "https://learningx-s3.s3.ap-south-1.amazonaws.com/image_2_1.png";
  var _currentUserId = "";
  var _currentFirstname = "user";
  var _currentLastname = "_name";

  final TextEditingController nameController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController linkedInController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    if (widget.college != null) {
      setState(() {
        nameController.text = widget.college!.collegeName;
        websiteController.text = widget.college!.website;
        emailController.text = widget.college!.email;
        linkedInController.text = widget.college!.linkedIn;
        instagramController.text = widget.college!.instagram;
        locationController.text = widget.college!.city.address;
        descriptionController.text = widget.college!.description;
        collegeImg = widget.college!.collegeImg;
      });
    }
    _loadCurrentUser();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    websiteController.dispose();
    emailController.dispose();
    linkedInController.dispose();
    instagramController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString("id") ?? "";
      _currentFirstname = prefs.getString("firstname") ?? "";
      _currentLastname = prefs.getString("lastname") ?? "";
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

  void nextBtnClicked() async {
    if (nameController.text.isEmpty ||
        websiteController.text.isEmpty ||
        locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("* field required!")),
      );
      return;
    }
    Map<String, dynamic> data = HashMap();
    if (_image != null) {
      List<UploadedFileModel> results = await UploadFileProvider.uploadImage(
          _selectedFile!.name, [_image!], true);
      data['collegeImg'] = results[0].location;
    }
    data['collegeName'] = nameController.text;
    data['website'] = websiteController.text;
    data['email'] = emailController.text;
    data['linkedIn'] = linkedInController.text;
    data['instagram'] = instagramController.text;
    data['description'] = descriptionController.text;
    data['city'] = City(address: locationController.text).toJson();
    if (widget.college != null) {
      data['_id'] = widget.college!.id;
      await ref
          .read(selectedCollegeProvider(widget.college!.id).notifier)
          .updateCollegeApi(context, data);
    } else {
      College college = await createCollegeApi(context, data);
      if (widget.signupData!.containsKey('signup')) {
        (widget.signupData!)['college'] = college.id;
        (widget.signupData!)['emailDomain'] = college.emailDomain;
        (widget.signupData!)['collegeName'] = college.collegeName;
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SignUpForm2Screen(
                    data: widget.signupData!,
                  )),
        );
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('college', college.id);
        Map<String, dynamic> map = HashMap();
        map["_id"] = _currentUserId;
        map["firstname"] = _currentFirstname;
        map["lastname"] = _currentLastname;
        map['college'] = college.id;
        await updateUserApi(context, map);
        //Navigator.pop(context);
        // context.push("/college/${college.id}");
        context.push("/home");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.college != null ? "Edit Page" : 'Create Campus Page'),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.college == null)
                const Text(
                  '* After submission, this page will be under review by Club-Chat. You may be contacted by Club-Chat, and the approval process may take up to 48 hours.',
                  style: TextStyle(color: Colors.blue, fontSize: 12),
                ),
              const SizedBox(height: 8),
              _image == null
                  ? Image.network(collegeImg)
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
                'Campus Name* -',
                style: TextStyle(color: Colors.blue),
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Campus Name',
                  hintStyle: TextStyle(fontSize: 15),
                ),
                keyboardType: TextInputType.text,
                maxLength: 50,
              ),
              const Text(
                'Website Link* -',
                style: TextStyle(color: Colors.blue),
              ),
              TextFormField(
                controller: websiteController,
                decoration: const InputDecoration(
                  hintText: 'Website Link',
                  hintStyle: TextStyle(fontSize: 15),
                ),
                keyboardType: TextInputType.text,
                maxLength: 50,
              ),
              if (widget.college != null)
                const Text(
                  'Email address* -',
                  style: TextStyle(color: Colors.blue),
                ),
              if (widget.college != null)
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email address',
                    hintStyle: TextStyle(fontSize: 15),
                  ),
                  keyboardType: TextInputType.text,
                  maxLength: 50,
                ),
              if (widget.college != null)
                const Text(
                  'LinkedIn Link -',
                  style: TextStyle(color: Colors.blue),
                ),
              if (widget.college != null)
                TextFormField(
                  controller: linkedInController,
                  decoration: const InputDecoration(
                    hintText: 'LinkedIn Link',
                    hintStyle: TextStyle(fontSize: 15),
                  ),
                  keyboardType: TextInputType.text,
                  maxLength: 50,
                ),
              if (widget.college != null)
                const Text(
                  'Instagram link -',
                  style: TextStyle(color: Colors.blue),
                ),
              if (widget.college != null)
                TextFormField(
                  controller: instagramController,
                  decoration: const InputDecoration(
                    hintText: 'Instagram link',
                    hintStyle: TextStyle(fontSize: 15),
                  ),
                  keyboardType: TextInputType.text,
                  maxLength: 50,
                ),
              const Text(
                'Campus Location* -',
                style: TextStyle(color: Colors.blue),
              ),
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  hintText: 'Campus Location',
                  hintStyle: TextStyle(fontSize: 15),
                ),
                keyboardType: TextInputType.text,
                maxLength: 50,
              ),
              const Text(
                'Tell people about your Campus',
                style: TextStyle(color: Colors.blue),
              ),
              const SizedBox(
                height: 8,
              ),
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
                maxLength: 500,
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
