// ignore_for_file: library_prefixes

import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learningx_flutter_app/api/model/channel_model.dart';
import 'package:learningx_flutter_app/api/model/uploaded_file_model.dart';
import 'package:learningx_flutter_app/api/provider/discussion_provider.dart';
import 'package:learningx_flutter_app/api/provider/upload_file_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class DiscussionFormActivity extends ConsumerStatefulWidget {
  final Channel channel;
  final IO.Socket? socket;
  const DiscussionFormActivity({super.key, required this.channel, this.socket});

  @override
  ConsumerState<DiscussionFormActivity> createState() => _DiscussionFormState();
}

class _DiscussionFormState extends ConsumerState<DiscussionFormActivity> {
  File? _file;
  XFile? _selectedFile;
  bool isImage = false;
  bool isVideo = false;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController subTitleController = TextEditingController();
  VideoPlayerController? _videoPlayerController;
  var _currentUserId = "";
  var lastSeenBy = [];

  @override
  void initState() {
    super.initState();
    markReadChats(widget.channel.id);
    // Schedule initialization after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    await _loadCurrentUser();
    // _connectToWebSocket();
  }

  @override
  void dispose() {
    titleController.dispose();
    subTitleController.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  // Load counter value from SharedPreferences
  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('id') ?? "";
      lastSeenBy.add(_currentUserId);
    });
  }

  void addImageBtnClicked() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _file = File(pickedFile!.path);
      _selectedFile = pickedFile;
      isImage = true;
      isVideo = false;
    });
  }

  Future<void> addVideoBtnClicked() async {
    setState(() {
      _file = null;
    });
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      int fileSize;

      // Check if running on web or mobile
      if (kIsWeb) {
        // On web, use XFile's length method to get file size
        fileSize = await pickedFile.length();
      } else {
        // On mobile, get file size using the File class
        final File videoFile = File(pickedFile.path);
        fileSize = await videoFile.length();
      }

      if (fileSize <= 50 * 1024 * 1024) {
        // 50 MB limit
        setState(() {
          _file = File(pickedFile.path);
          _selectedFile = pickedFile;
          if (kIsWeb) {
            // On web, handle XFile for video playback
            _videoPlayerController =
                VideoPlayerController.networkUrl(Uri.parse(pickedFile.path))
                  ..initialize().then((_) {
                    setState(() {});
                  });
          } else {
            // On mobile, handle File for video playback
            final File videoFile = File(pickedFile.path);
            _videoPlayerController = VideoPlayerController.file(videoFile)
              ..initialize().then((_) {
                setState(() {});
              });
          }
          isImage = false;
          isVideo = true; // Reset image flag if video is selected
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video size must be less than 50 MB.')),
        );
      }
    }
  }

  void handlePostBtn() async {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("* field required!")),
      );
      return;
    }
    Map<String, dynamic> map = HashMap();
    if (_file != null) {
      List<UploadedFileModel> results = await UploadFileProvider.uploadImage(
          _selectedFile!.name, [_file!], isImage);
      map['file'] = results[0].location;
      if (isImage) {
        map['filetype'] = "image";
      } else {
        map['filetype'] = "video";
      }
    } else {
      map['filetype'] = "text";
    }
    map['title'] = titleController.text;
    map['chat'] = subTitleController.text;
    map['channel'] = widget.channel.id;
    map['club'] = widget.channel.club;
    map['room'] = widget.channel.id;
    map['seenBy'] = lastSeenBy;
    String chatId = await sendDiscussion(map);
    if (widget.socket != null) {
      map['_id'] = chatId;
      widget.socket!.emit('chatMessage', map);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create discussion'),
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
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'What do you want to discuss about?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                minLines: 2,
                maxLines: null,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: subTitleController,
                decoration: InputDecoration(
                  hintText: 'Your discussion subtitle (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                minLines: 3,
                maxLines: null,
              ),
              const SizedBox(height: 8),
              Visibility(
                visible: isImage,
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: _file == null
                        ? Container()
                        : kIsWeb
                            ? Image.network(
                                _file!.path,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                _file!,
                                fit: BoxFit.cover,
                              )),
              ),
              const SizedBox(height: 8),
              Visibility(
                visible: isVideo,
                child: Center(
                  child: _videoPlayerController != null &&
                          _videoPlayerController!.value.isInitialized
                      ? AspectRatio(
                          aspectRatio:
                              _videoPlayerController!.value.aspectRatio,
                          child: VideoPlayer(_videoPlayerController!),
                        )
                      : Container(),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      floatingActionButton: Visibility(
          visible: isVideo,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                if (_videoPlayerController != null) {
                  _videoPlayerController!.value.isPlaying
                      ? _videoPlayerController!.pause()
                      : _videoPlayerController!.play();
                }
              });
            },
            child: Icon(
              _videoPlayerController != null &&
                      _videoPlayerController!.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
            ),
          )),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      addImageBtnClicked();
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(const Color.fromARGB(255, 112, 172, 235)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library),
                        SizedBox(width: 8),
                        Text('Add Photo'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Add some space between the buttons
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      addVideoBtnClicked();
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(const Color.fromARGB(255, 112, 172, 235)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.video_call),
                        SizedBox(width: 8),
                        Text('Add Video'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  handlePostBtn();
                },
                child: const Text('Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
