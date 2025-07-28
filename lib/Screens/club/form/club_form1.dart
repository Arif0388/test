// import 'dart:collection';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:learningx_flutter_app/Screens/club/form/club_form2.dart';
// import 'package:learningx_flutter_app/Screens/club/form/set_up_channels.dart';
// import 'package:learningx_flutter_app/api/common/image_cropper.dart';
// import 'package:learningx_flutter_app/api/model/club_model.dart';
// import 'package:learningx_flutter_app/api/model/uploaded_file_model.dart';
// import 'package:learningx_flutter_app/api/provider/club_feed_provider.dart';
// import 'package:learningx_flutter_app/api/provider/club_provider.dart';
// import 'package:learningx_flutter_app/api/provider/upload_file_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ClubForm1Activity extends ConsumerStatefulWidget {
//   final String? clubId;
//   final String? collegeId;
//   final String? councilId;
//   const ClubForm1Activity(
//       {super.key, this.clubId, this.collegeId, this.councilId});
//
//   @override
//   ConsumerState<ClubForm1Activity> createState() => _ClubForm1State();
// }
//
// class _ClubForm1State extends ConsumerState<ClubForm1Activity> {
//   String? _selectedCategory = 'Arts & Culture';
//   final List<String> _categories = [
//     'Arts & Culture',
//     'Management',
//     'Science & Technology',
//     'Sports',
//     'Social'
//   ];
//   File? _image;
//   XFile? _selectedFile;
//   String clubImg =
//       "https://learningx-s3.s3.ap-south-1.amazonaws.com/CvW3AqVxR-image.png";
//   var privacy = "private";
//   bool isAdminChannelRequired = true;
//   String _collegeId = "";
//
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController councilController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCurrentUser();
//     if (widget.clubId != null) {
//       _initialize();
//     }
//   }
//
//   @override
//   void dispose() {
//     nameController.dispose();
//     councilController.dispose();
//     emailController.dispose();
//     descriptionController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _initialize() async {
//     await ref
//         .read(selectedClubProvider(widget.clubId!).notifier)
//         .fetchClub(widget.clubId!);
//     if (widget.clubId != null) {
//       final clubData = ref.watch(selectedClubProvider(widget.clubId!));
//       setState(() {
//         nameController.text = clubData.clubName;
//         councilController.text = clubData.councilName;
//         emailController.text = clubData.email;
//         descriptionController.text = clubData.description;
//         privacy = clubData.privacy;
//         _selectedCategory = clubData.category;
//         clubImg = clubData.clubImg;
//       });
//     }
//   }
//
//   _loadCurrentUser() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _collegeId = prefs.getString('college') ?? "";
//     });
//   }
//
//   void addImageBtnClicked() async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     File? image =
//         await ImageCropperPage.cropImage(context, File(pickedFile!.path), 1, 1);
//     setState(() {
//       _image = image;
//       _selectedFile = pickedFile;
//     });
//   }
//
//   void onPrivacyRadioClicked(String? value) {
//     setState(() {
//       privacy = value ?? "private";
//     });
//   }
//
//   void onChannelRadioClicked(bool? isSelected) {
//     setState(() {
//       isAdminChannelRequired = isSelected ?? false;
//     });
//   }
//
//   void nextBtnClicked() async {
//     if (nameController.text.isEmpty || emailController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("* field is required!")),
//       );
//     } else {
//       Map<String, dynamic> data = HashMap();
//       if (_image != null) {
//         List<UploadedFileModel> results = await UploadFileProvider.uploadImage(
//             _selectedFile!.name, [_image!], true);
//         data['clubImg'] = results[0].location;
//       }
//       data['clubName'] = nameController.text;
//       data['councilName'] = councilController.text;
//       data['email'] = emailController.text;
//       data['description'] = descriptionController.text;
//       data['category'] = _selectedCategory;
//       data['privacy'] = privacy;
//       if (privacy == "public") {
//         data['college'] = _collegeId;
//       } else {
//         data['college'] = null;
//       }
//       if (widget.collegeId != null && privacy == "public") {
//         data['college_status'] = "verified";
//         data['college'] = widget.collegeId;
//       }
//       if (widget.councilId != null) {
//         data['council'] = widget.councilId;
//       }
//       if (widget.clubId != null) {
//         data['_id'] = widget.clubId;
//         await ref
//             .read(selectedClubProvider(widget.clubId!).notifier)
//             .updateClubApi(context, data);
//         Navigator.pop(context);
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) => ClubForm2Activity(
//                     clubId: widget.clubId!,
//                     isNewClub: false,
//                   )),
//         );
//       } else {
//         data['isAdminChannelRequired'] = isAdminChannelRequired;
//         ClubItem newClub = await createClubApi(context, data);
//         ref.read(yourClubFeedProvider.notifier).addClub(newClub);
//         Navigator.pop(context);
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) => SetUpChannelsPage(
//                     clubItem: newClub,
//                   )),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.clubId != null ? "Edit Club" : 'Create Club'),
//         backgroundColor: const Color.fromARGB(255, 211, 232, 255),
//         titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _image == null
//                       ? Center(
//                           child: ClipRRect(
//                               borderRadius: BorderRadius.circular(8.0),
//                               child: Image.network(
//                                 clubImg,
//                                 width: 120,
//                               )))
//                       : kIsWeb
//                           ? Center(
//                               child: ClipRRect(
//                               borderRadius: BorderRadius.circular(8.0),
//                               child: Image.network(
//                                 _image!.path,
//                                 width: 120,
//                               ),
//                             ))
//                           : Center(
//                               child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(8.0),
//                                   child: Image.file(_image!, width: 120))),
//                   const SizedBox(height: 8),
//                   Center(
//                     child: TextButton(
//                       onPressed: addImageBtnClicked,
//                       child: const Text(
//                         'change image',
//                         style: TextStyle(color: Colors.blue),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: nameController,
//                     decoration: InputDecoration(
//                       label: const Text('Club Name'),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter a club name';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   DropdownButtonFormField<String>(
//                     value: _selectedCategory,
//                     decoration: InputDecoration(
//                       label: const Text('Club Category'),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     items: _categories
//                         .map((label) => DropdownMenuItem(
//                               value: label,
//                               child: Text(label),
//                             ))
//                         .toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedCategory = value;
//                       });
//                     },
//                     validator: (value) =>
//                         value == null ? 'Please select an Club Category' : null,
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: councilController,
//                     decoration: InputDecoration(
//                       label: const Text('Council Name (Optional)'),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: emailController,
//                     decoration: InputDecoration(
//                       label: const Text('Email Address'),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter an email address';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     minLines: 2,
//                     maxLines: null,
//                     controller: descriptionController,
//                     keyboardType: TextInputType.multiline,
//                     decoration: InputDecoration(
//                       label: const Text('Description (Optional)'),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   if (_collegeId.isNotEmpty &&
//                       _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         const Icon(
//                           Icons.account_balance_outlined,
//                           size: 20,
//                         ),
//                         const SizedBox(
//                           width: 8,
//                         ),
//                         const Text(
//                           'Public',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const Spacer(),
//                         Switch(
//                           value: privacy == "public", // Default toggle value
//                           onChanged: (value) {
//                             onPrivacyRadioClicked(value ? "public" : "private");
//                           },
//                           activeColor: Colors.blue,
//                           inactiveThumbColor: Colors.grey,
//                           inactiveTrackColor: Colors.grey[700],
//                         ),
//                       ],
//                     ),
//                   const SizedBox(height: 16),
//                   if (widget.collegeId == null &&
//                       _collegeId.isNotEmpty &&
//                       _collegeId != dotenv.env['OTHER_COLLEGE_ID'])
//                     const Text(
//                       'Turning on will make this club appear in campus page for verification. After Verification, it will be shown on Campus Page.',
//                       style: TextStyle(
//                         color: Colors.blue,
//                         fontSize: 14,
//                       ),
//                     ),
//                   if (widget.collegeId != null)
//                     const Text(
//                       'Turning on will make this club officially recognized and visible on the campus page.',
//                       style: TextStyle(
//                         color: Colors.blue,
//                         fontSize: 14,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Container(
//         margin: const EdgeInsets.all(16),
//         child: ElevatedButton.icon(
//           onPressed: nextBtnClicked,
//           icon: const Icon(
//             Icons.navigate_next,
//             color: Colors.white,
//           ),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.blue,
//             padding: const EdgeInsets.all(16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8.0),
//             ),
//           ),
//           label: const Text(
//             'Next',
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:collection';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learningx_flutter_app/Screens/club/form/set_up_channels.dart';

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
  final String _selectedCategory = 'Arts & Culture';
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

  void nextBtnClicked() async {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty || linkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("* field is required!")),
      );
    } else {
      Map<String, dynamic> data = HashMap();
      if (_image != null) {
        List<UploadedFileModel> results = await UploadFileProvider.uploadImage(
            _selectedFile!.name, [_image!], true);
        data['clubImg'] = results[0].location;
      }
      data['clubName'] = titleController.text;
      data['clubLink'] = linkController.text;
      // data['email'] = emailController.text;
      data['description'] = descriptionController.text;
      data['category'] = _selectedCategory;
      data['privacy'] = privacy;
      if (privacy == "public") {
        data['college'] = _collegeId;
      } else {
        data['college'] = null;
      }
      if (widget.collegeId != null && privacy == "public") {
        data['college_status'] = "verified";
        data['college'] = widget.collegeId;
      }
      if (widget.councilId != null) {
        data['council'] = widget.councilId;
      }
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
              )),
        );
      } else {
        data['isAdminChannelRequired'] = isAdminChannelRequired;
        ClubItem newClub = await createClubApi(context, data);
        ref.read(yourClubFeedProvider.notifier).addClub(newClub);
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SetUpChannelsPage(
                clubItem: newClub,
              )),
        );
      }
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color(0xffF9FAFB),
      appBar: AppBar(
        title: Text("Create Club Workshop", style: GoogleFonts.poppins(fontWeight: FontWeight.w500,color:const Color(0xff3C393C))),
        leading: const BackButton(),
        backgroundColor: Colors.white,
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
