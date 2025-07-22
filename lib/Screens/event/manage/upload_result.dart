import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learningx_flutter_app/api/model/event_model.dart';
import 'package:learningx_flutter_app/api/model/uploaded_file_model.dart';
import 'package:learningx_flutter_app/api/provider/event_manage_provider.dart';
import 'package:learningx_flutter_app/api/provider/upload_file_provider.dart';

class EventResultForm extends ConsumerStatefulWidget {
  final String eventId;
  final List<Stage> stages;
  final List<Result> results;

  const EventResultForm(
      {Key? key,
      required this.eventId,
      required this.stages,
      required this.results})
      : super(key: key);

  @override
  ConsumerState<EventResultForm> createState() => _EventResultFormState();
}

class _EventResultFormState extends ConsumerState<EventResultForm> {
  final _formKey = GlobalKey<FormState>();
  int? selectedRound;
  File? _file;
  String filename = "";

  void handleFilePicker() async {
    final pickedFile = await ImagePicker().pickMedia();
    setState(() {
      _file = File(pickedFile!.path);
      filename = pickedFile.name;
    });
  }

  String generateRandomId(int length) {
    const characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length)),
      ),
    );
  }

  Future<void> handleSubmit() async {
    try {
      if (_file != null && selectedRound != null) {
        // Ensure widget.results is a List<Result>
        List<Result> currentResults = widget.results;

        // Upload file
        List<UploadedFileModel> results =
            await UploadFileProvider.uploadImage(filename, [_file!], false);

        if (results.isEmpty) {
          throw Exception("No files were uploaded successfully.");
        }

        // Append new Result
        currentResults.add(
          Result(
            id: generateRandomId(6),
            round: selectedRound!,
            file: results[0].location,
            filename: filename,
          ),
        );

        // Prepare data to send
        Map<String, dynamic> data = {
          '_id': widget.eventId,
          'msg': "uploads result of round $selectedRound.",
          'results': currentResults.map((result) => result.toJson()).toList(),
        };

        // Call the API
        await ref
            .read(eventManageProvider(widget.eventId).notifier)
            .updateEventApi(context, data);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Result uploaded successfully!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please select a round and upload a file.")),
        );
      }
    } catch (error) {
      print(error); // Debugging
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to upload result!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final roundsOption = widget.stages.map((stage) {
      return DropdownMenuItem<int>(
        value: stage.round,
        child: Text(stage.roundTitle),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Result of This Event"),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: "Result of which round",
                  border: OutlineInputBorder(),
                ),
                items: roundsOption,
                value: selectedRound,
                onChanged: (value) {
                  setState(() {
                    selectedRound = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Please select a round" : null,
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () {
                  handleFilePicker();
                },
                icon: const Icon(Icons.upload_file),
                label: Text(
                    _file == null ? "Select a file" : "Selected: $filename"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: handleSubmit,
                child: const Text("Post Result"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
