
import 'dart:collection';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learningx_flutter_app/Screens/club/form/set_up_channels.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/common/image_cropper.dart';
import '../../../api/model/club_model.dart';
import '../../../api/model/uploaded_file_model.dart';
import '../../../api/provider/club_feed_provider.dart';
import '../../../api/provider/club_provider.dart';
import '../../../api/provider/upload_file_provider.dart';
import 'club_form2.dart';

class ClubForm1Activity extends ConsumerStatefulWidget {
  final String? clubId;
  final String? collegeId;
  final String? councilId;
  const ClubForm1Activity(
      {super.key, this.clubId, this.collegeId, this.councilId});

  @override
  ConsumerState<ClubForm1Activity> createState() => _ClubForm1State();
}

class _ClubForm1State extends ConsumerState<ClubForm1Activity> {
  final formKey = GlobalKey<FormState>();
   String? _selectedCategory = 'Arts & Culture';
  final List<String> _categories = [
    'Arts & Culture',
    'Management',
    'Science & Technology',
    'Sports',
    'Social'
  ];
  File? _image;
  XFile? _selectedFile;
  DateTime? startDate;
  DateTime? endDate;
  bool isOnline = false;
  String clubImg =
      "https://learningx-s3.s3.ap-south-1.amazonaws.com/CvW3AqVxR-image.png";
  var privacy = "private";
  bool isAdminChannelRequired = true;
  String _collegeId = "";

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();

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

  Future<void> pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2025, 5, 12),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  // void nextBtnClicked() async {
  //   if (titleController.text.isEmpty || descriptionController.text.isEmpty || linkController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("* field is required!")),
  //     );
  //   } else {
  //     Map<String, dynamic> data = HashMap();
  //     if (_image != null) {
  //       List<UploadedFileModel> results = await UploadFileProvider.uploadImage(
  //           _selectedFile!.name, [_image!], true);
  //       data['clubImg'] = results[0].location;
  //     }
  //     data['clubName'] = titleController.text;
  //     data['clubLink'] = linkController.text;
  //     // data['email'] = emailController.text;
  //     data['description'] = descriptionController.text;
  //     data['category'] = _selectedCategory;
  //     data['privacy'] = privacy;
  //     if (privacy == "public") {
  //       data['college'] = _collegeId;
  //     } else {
  //       data['college'] = null;
  //     }
  //     if (widget.collegeId != null && privacy == "public") {
  //       data['college_status'] = "verified";
  //       data['college'] = widget.collegeId;
  //     }
  //     if (widget.councilId != null) {
  //       data['council'] = widget.councilId;
  //     }
  //     if (widget.clubId != null) {
  //       data['_id'] = widget.clubId;
  //       await ref
  //           .read(selectedClubProvider(widget.clubId!).notifier)
  //           .updateClubApi(context, data);
  //       Navigator.pop(context);
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => ClubForm2Activity(
  //               clubId: widget.clubId!,
  //               isNewClub: false,
  //             )),
  //       );
  //     } else {
  //       data['isAdminChannelRequired'] = isAdminChannelRequired;
  //       ClubItem newClub = await createClubApi(context, data);
  //       ref.read(yourClubFeedProvider.notifier).addClub(newClub);
  //       Navigator.pop(context);
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => SetUpChannelsPage(
  //               clubItem: newClub,
  //             )),
  //       );
  //     }
  //   }
  // }

  void nextBtnClicked() async {
    // Validate empty fields
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        linkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("* All fields are required!")),
      );
      return;
    }

    try {
      Map<String, dynamic> data = {};

      // Upload image if selected
      if (_image != null && _selectedFile != null) {
        List<UploadedFileModel> results = await UploadFileProvider.uploadImage(
          _selectedFile!.name,
          [_image!],
          true,
        );
        data['clubImg'] = results[0].location;
      }

      // Basic form data
      data['clubName'] = titleController.text.trim();
      data['clubLink'] = linkController.text.trim();
      data['description'] = descriptionController.text.trim();
      data['category'] = _selectedCategory;
      data['privacy'] = privacy;

      // College related logic
      if (privacy == "public") {
        data['college'] = widget.collegeId ?? _collegeId;
        if (widget.collegeId != null) {
          data['college_status'] = "verified";
        }
      } else {
        data['college'] = null;
      }

      // Council check
      if (widget.councilId != null) {
        data['council'] = widget.councilId;
      }

      // If editing existing club
      if (widget.clubId != null) {
        data['_id'] = widget.clubId;

        await ref
            .read(selectedClubProvider(widget.clubId!).notifier)
            .updateClubApi(context, data);

        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClubForm2Activity(
              clubId: widget.clubId!,
              isNewClub: false,
            ),
          ),
        );
      }
      // If creating new club
      else {
        data['isAdminChannelRequired'] = isAdminChannelRequired;

        ClubItem newClub = await createClubApi(context, data);
        ref.read(yourClubFeedProvider.notifier).addClub(newClub);

        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SetUpChannelsPage(clubItem: newClub),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error in nextBtnClicked: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong. Please try again.")),
      );
    }
  }


  void submitForm() {
    if (formKey.currentState!.validate()) {
      if (_selectedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please upload an image")),
        );
        return;
      }
      if (startDate == null || endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select start and end dates")),
        );
        return;
      }


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Workshop Created Successfully!")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    if (widget.clubId != null) {
      _initialize();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    linkController.dispose();
    // emailController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await ref
        .read(selectedClubProvider(widget.clubId!).notifier)
        .fetchClub(widget.clubId!);
    if (widget.clubId != null) {
      final clubData = ref.watch(selectedClubProvider(widget.clubId!));
      setState(() {
        titleController.text = clubData.clubName;
        // councilController.text = clubData.councilName;
        // emailController.text = clubData.email;
        descriptionController.text = clubData.description;
        privacy = clubData.privacy;
        _selectedCategory = clubData.category;
        clubImg = clubData.clubImg;
      });
    }
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _collegeId = prefs.getString('college') ?? "";
    });
  }


  void onPrivacyRadioClicked(String? value) {
    setState(() {
      privacy = value ?? "private";
    });
  }

  void onChannelRadioClicked(bool? isSelected) {
    setState(() {
      isAdminChannelRequired = isSelected ?? false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        title: Text("Create Club Workshop", style: GoogleFonts.poppins(fontWeight: FontWeight.w500,color:const Color(0xff3C393C))),
        leading: const BackButton(),
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: addImageBtnClicked,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue.shade200,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _selectedFile == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_upload_outlined,
                            size: 40, color: Color(0xff3B82F6)),
                        const SizedBox(height: 8),
                        Text("Drag file here to upload",style:GoogleFonts.poppins(fontWeight:FontWeight.w400,color:const Color(0xff3C393C)),),
                        Text("Max file size : 5mb",
                            style:GoogleFonts.poppins(fontWeight:FontWeight.w300,color:const Color(0xff3B82F6),fontSize:11.2)),
                        const SizedBox(height: 8),
                      ],
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _image!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              InkWell(
                focusColor:Colors.transparent,
                highlightColor:Colors.transparent,
                hoverColor: Colors.transparent,
                splashColor:Colors.transparent,
                onTap:addImageBtnClicked,
                child: Row(
                  mainAxisAlignment:MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.image_outlined,color:Color(0xff3B82F6),),
                    const SizedBox(width:5,),
                    Text("Change Image",
                        style:GoogleFonts.poppins(fontWeight: FontWeight.w600,color:const Color(0xff3B82F6),fontSize: 13.44)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Text('Workshop title',style:GoogleFonts.poppins(fontSize:16,fontWeight:FontWeight.w400,color:const Color(0xff828282))),
              ],),
              const SizedBox(height:10),
              TextFormField(
                controller: titleController,
                maxLength: 50,
                decoration: InputDecoration(
                  hintStyle:GoogleFonts.inter(fontSize:17,fontWeight:FontWeight.w500,color:const Color(0xffC3C3C3)),
                  hintText: 'Workshop',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height:5),
              Row(children: [
                Text('Description',style:GoogleFonts.poppins(fontSize:16,fontWeight:FontWeight.w400,color:const Color(0xff828282))),
              ],),
              const SizedBox(height:10),
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintStyle:GoogleFonts.roboto(fontSize:17,fontWeight:FontWeight.w500,color:const Color(0xffC3C3C3)),
                  hintText: 'Write here',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => pickDate(isStart: true),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelStyle:GoogleFonts.poppins(fontSize:17,fontWeight:FontWeight.w400,color:const Color(0xffC3C3C3)),
                            // labelText: 'Start Date',
                            border: const OutlineInputBorder(),
                            hintText: startDate == null
                                ? "Start Date"
                                : "${startDate!.day.toString().padLeft(2, '0')}.${startDate!.month.toString().padLeft(2, '0')}.${startDate!.year}",
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => pickDate(isStart: false),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelStyle:GoogleFonts.poppins(fontSize:17,fontWeight:FontWeight.w400,color:const Color(0xffC3C3C3)),
                            // labelText: 'End Date',
                            border: const OutlineInputBorder(),
                            hintText: endDate == null
                                ? "End Date"
                                : "${endDate!.day.toString().padLeft(2, '0')}.${endDate!.month.toString().padLeft(2, '0')}.${endDate!.year}",
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height:14),
              Row(
                children: [
                  Text("Mode", style: GoogleFonts.poppins(fontSize:15,color:const Color(0xff828282),fontWeight: FontWeight.w400)),
                ],
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  Radio(
                    activeColor:const Color(0xff3B82F6),
                    value: true,
                    groupValue: isOnline,
                    onChanged: (val) => setState(() => isOnline = val!),
                  ),
                  Text("Online",style:GoogleFonts.poppins(fontWeight:FontWeight.w500,fontSize:15)),
                  Radio(
                    activeColor:const Color(0xff3B82F6),
                    value: false,
                    groupValue: isOnline,
                    onChanged: (val) => setState(() => isOnline = val!),
                  ),
                  Text("Offline",style:GoogleFonts.poppins(fontWeight:FontWeight.w500,fontSize:15)),
                ],
              ),
              const SizedBox(height: 8),
              Row(children: [
                Text('Workshop Link',style:GoogleFonts.poppins(fontSize:16,fontWeight:FontWeight.w400,color:const Color(0xff828282))),
              ],),
              TextFormField(
                controller: linkController,
                decoration: InputDecoration(
                  hintStyle:GoogleFonts.roboto(fontSize:17,fontWeight:FontWeight.w400,color:const Color(0xffC3C3C3)),
                  prefixIcon: const Icon(Icons.language,color: Color(0xffC3C3C3)),
                  hintText: 'www.events.in',
                  border: const UnderlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Workshop link is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              InkWell(
                onTap:submitForm,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:nextBtnClicked,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007BFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Create Workshop',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
