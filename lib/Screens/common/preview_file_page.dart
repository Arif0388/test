// ignore_for_file: must_be_immutable, use_build_context_synchronously, library_prefixes

import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learningx_flutter_app/api/model/uploaded_file_model.dart';
import 'package:learningx_flutter_app/api/provider/chat_provider.dart';
import 'package:learningx_flutter_app/api/provider/discussion_provider.dart';
import 'package:learningx_flutter_app/api/provider/files_provider.dart';
import 'package:learningx_flutter_app/api/provider/upload_file_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class PreviewFilePage extends ConsumerStatefulWidget {
  final String roomId;
  final String? clubId;
  final String? parentChatId;
  final String filetype;
  final String where;
  late XFile? xFile;
  final IO.Socket? socket;
  PreviewFilePage(
      {super.key,
      required this.roomId,
      this.clubId,
      this.parentChatId,
      required this.filetype,
      required this.where,
      this.xFile,
      this.socket});

  @override
  ConsumerState<PreviewFilePage> createState() => _SendFileActivityState();
}

class _SendFileActivityState extends ConsumerState<PreviewFilePage> {
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String filename = 'No file chosen';
  bool isImageVisible = false;
  bool isVideoVisible = false;
  bool isLinkFieldVisible = false;
  bool isLoading = false;
  VideoPlayerController? _videoController;
  File? file;
  var _currentUserId = "";
  var lastSeenBy = [];

  @override
  void initState() {
    super.initState();
    if (widget.xFile != null) {
      file = File(widget.xFile!.path);
      filename = widget.xFile!.name;
      isImageVisible = widget.filetype == "image";
      isVideoVisible = widget.filetype == "video";

      if (isVideoVisible && file != null) {
        _videoController = VideoPlayerController.file(file!)
          ..initialize().then((_) {
            setState(() {});
          });
      }
    } else {
      isLinkFieldVisible = widget.filetype == "link";
      if (!isLinkFieldVisible) {
        Navigator.pop(context);
      }
      log('No file selected.');
    }
    // Schedule initialization after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    await _loadCurrentUser();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _linkController.dispose();
    _messageController.dispose();
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

  void chooseFileBtn() async {
    XFile? pickedFile;
    if (isImageVisible) {
      pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    } else if (isVideoVisible) {
      pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    } else {
      pickedFile = await ImagePicker().pickMedia();
    }

    if (pickedFile != null) {
      setState(() {
        file = File(pickedFile!.path);
        filename = pickedFile.name;

        if (isVideoVisible && file != null) {
          _videoController = VideoPlayerController.file(file!)
            ..initialize().then((_) {
              setState(() {});
            });
        }
      });
    }
  }

  void uploadFileBtn() async {
    if (widget.where == "file" && isLinkFieldVisible) {
      Map<String, dynamic> map = HashMap();
      map['channel'] = widget.roomId;
      map['club'] = widget.clubId;
      map['filetype'] = 'link';
      map['filesLink'] = _linkController.text;
      final fileNotifier = ref.read(filesProvider(widget.roomId).notifier);
      fileNotifier.addFile(context, map);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('link added!')),
      );
      Navigator.pop(context);
    } else if (file != null) {
      try {
        bool isImage = widget.filetype == "image";
        List<UploadedFileModel> files =
            await UploadFileProvider.uploadImage(filename, [file!], isImage);
        log(files[0].location);
        Map<String, dynamic> map = HashMap();
        map['filetype'] = widget.filetype;
        map['filename'] = files[0].originalname;
        map['realFiletype'] = files[0].mimetype;
        map['filesize'] = "${files[0].size}";
        map['file'] = files[0].location;
        map['filesLink'] = files[0].location;
        map['chat'] = _messageController.text;
        map['seenBy'] = lastSeenBy;
        if (widget.where == "chat") {
          map['room'] = widget.roomId;
          String chatId = await sendChat(map);
          map['_id'] = chatId;
          widget.socket!.emit('chatMessage', map);
        } else if (widget.where == "discussion") {
          map['channel'] = widget.roomId;
          map['club'] = widget.clubId;
          map['room'] = widget.roomId;
          String chatId = await sendDiscussion(map);
          map['_id'] = chatId;
          widget.socket!.emit('chatMessage', map);
        } else if (widget.where == "groupDiscussion") {
          map['channel'] = widget.roomId;
          map['club'] = widget.clubId;
          map['parentChatId'] = widget.parentChatId;
          map['room'] = widget.parentChatId;
          String chatId = await sendDiscussion(map);
          map['_id'] = chatId;
          widget.socket!.emit('chatMessage', map);
        } else if (widget.where == "file") {
          map['channel'] = widget.roomId;
          map['club'] = widget.clubId;
          final fileNotifier = ref.read(filesProvider(widget.roomId).notifier);
          fileNotifier.addFile(context, map);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('file uploaded!')),
        );
        Navigator.pop(context);
      } catch (e) {
        log('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload file: $e')),
        );
      } finally {
        // Optional: Hide loading indicator or re-enable the button
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(
            color: Colors.black, fontSize: 18), // Transparent violet color
        title: const Text('Select a file'),
      ),
      body: Column(
        children: [
          const Divider(color: Colors.black38, height: 1),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    if (!isLinkFieldVisible)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black26),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select a file :',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.black26),
                                    ),
                                    child: Text(filename),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: chooseFileBtn,
                                  style: ElevatedButton.styleFrom(),
                                  child: const Text('Choose file'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    Visibility(
                      visible: isLinkFieldVisible,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextField(
                          controller: _linkController,
                          decoration: InputDecoration(
                            hintText: 'write link here...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isImageVisible,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: file == null
                              ? Container()
                              : kIsWeb
                                  ? Image.network(
                                      file!.path,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      file!,
                                      fit: BoxFit.cover,
                                    )),
                    ),
                    Visibility(
                      visible: isVideoVisible,
                      child: Center(
                        child: _videoController != null &&
                                _videoController!.value.isInitialized
                            ? AspectRatio(
                                aspectRatio:
                                    _videoController!.value.aspectRatio,
                                child: VideoPlayer(_videoController!),
                              )
                            : Container(),
                      ),
                    ),
                    if (isLoading) const CircularProgressIndicator(),
                    if (!isLinkFieldVisible && widget.where != "file")
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextField(
                          controller: _messageController,
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: 'Add message here...',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Visibility(
          visible: isVideoVisible,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                if (_videoController != null) {
                  _videoController!.value.isPlaying
                      ? _videoController!.pause()
                      : _videoController!.play();
                }
              });
            },
            child: Icon(
              _videoController != null && _videoController!.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
            ),
          )),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: uploadFileBtn,
          child: const Text('Upload file'),
        ),
      ),
    );
  }
}
