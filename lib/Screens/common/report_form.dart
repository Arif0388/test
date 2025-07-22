import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learningx_flutter_app/api/model/uploaded_file_model.dart';
import 'package:learningx_flutter_app/api/provider/extra_provider.dart';
import 'package:learningx_flutter_app/api/provider/upload_file_provider.dart';

class ReportActivity extends ConsumerStatefulWidget {
  final String id;
  final String reportOn;
  const ReportActivity({super.key, required this.id, required this.reportOn});

  @override
  ConsumerState<ReportActivity> createState() => _ReportActivityState();
}

class _ReportActivityState extends ConsumerState<ReportActivity> {
  File? _file;
  String filename = "";

  final TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  void addImageBtnClicked() async {
    final pickedFile = await ImagePicker().pickMedia();
    setState(() {
      _file = File(pickedFile!.path);
      filename = pickedFile.name;
    });
  }

  void nextBtnClicked() async {
    if (descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("* field required!")),
      );
      return;
    }
    Map<String, dynamic> data = HashMap();
    if (_file != null) {
      List<UploadedFileModel> results =
          await UploadFileProvider.uploadImage(filename, [_file!], false);
      data['file'] = results[0].location;
    }
    data['reportOn'] = widget.reportOn;
    data['reportedId'] = widget.id;
    data['report'] = descriptionController.text;
    await createReportApi(context, data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 8,
              ),
              const Text(
                'Write your report here*',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                minLines: 8,
                maxLines: null,
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: 'Please include as much information as possible...',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select a file to support your claim : (optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey[200],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        filename.isEmpty ? 'No file chosen' : filename,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        addImageBtnClicked();
                      },
                      child: const Text('Choose file'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    nextBtnClicked();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text('Submit'),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
