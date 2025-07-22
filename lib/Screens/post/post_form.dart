import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learningx_flutter_app/api/common/image_cropper.dart';
import 'package:learningx_flutter_app/api/common/image_slider.dart';
import 'package:learningx_flutter_app/api/common/video_player.dart';
import 'package:learningx_flutter_app/api/model/club_model.dart';
import 'package:learningx_flutter_app/api/model/fest_model.dart';
import 'package:learningx_flutter_app/api/model/post_model.dart';
import 'package:learningx_flutter_app/api/model/uploaded_file_model.dart';
import 'package:learningx_flutter_app/api/provider/club_feed_provider.dart';
import 'package:learningx_flutter_app/api/provider/post_feed_provider.dart';
import 'package:learningx_flutter_app/api/provider/post_provider.dart';
import 'package:learningx_flutter_app/api/provider/upload_file_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class CreatePostPage extends ConsumerStatefulWidget {
  final Fest? fest;
  final Club? club;
  final Post? post;
  final bool toEdit;
  const CreatePostPage(
      {super.key, this.fest, this.club, this.post, required this.toEdit});

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final TextEditingController textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];
  List<XFile> _selectedFiles = [];
  File? _video;
  VideoPlayerController? _videoPlayerController;
  bool isImageSelected = false;
  bool isVideoSelected = false;
  var _currentUserName = "user_name";
  var _currentUserImg = "";
  var _currentUserId = "";
  String privacy = 'public';
  List<Map<String, String>> privacyOptions = [
    {"id": "public", "name": "Public"}
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    if (widget.post != null && widget.toEdit) {
      textController.text = widget.post!.text;
    }
  }

  @override
  void dispose() {
    textController.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('id') ?? "";
      if (widget.fest != null) {
        _currentUserName = widget.fest!.festName;
        _currentUserImg = widget.fest!.festImg;
      } else if (widget.club != null) {
        _currentUserName = widget.club!.clubName;
        _currentUserImg = widget.club!.clubImg;
      } else {
        _currentUserName = prefs.getString('displayName') ?? "";
        _currentUserImg = prefs.getString("userImg") ?? "";
      }
    });
  }

  Future<void> _pickImages() async {
    if (isVideoSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only select one type of media.')),
      );
      return;
    }
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.length <= 5) {
      setState(() {
        _images = pickedFiles.map((item) => File(item.path)).toList();
        _selectedFiles = pickedFiles;
        isImageSelected = true;
        isVideoSelected = false; // Reset video flag if images are selected
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only select up to 5 images.')),
      );
    }
  }

  Future<void> _pickVideo() async {
    if (isImageSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only select one type of media.')),
      );
      return;
    }

    final XFile? pickedVideo =
        await _picker.pickVideo(source: ImageSource.gallery);

    if (pickedVideo != null) {
      int fileSize;

      // Check if running on web or mobile
      if (kIsWeb) {
        // On web, use XFile's length method to get file size
        fileSize = await pickedVideo.length();
      } else {
        // On mobile, get file size using the File class
        final File videoFile = File(pickedVideo.path);
        fileSize = await videoFile.length();
      }

      if (fileSize <= 50 * 1024 * 1024) {
        // 50 MB limit
        setState(() {
          if (kIsWeb) {
            // On web, handle XFile for video playback
            _videoPlayerController =
                VideoPlayerController.networkUrl(Uri.parse(pickedVideo.path))
                  ..initialize().then((_) {
                    setState(() {});
                  });
          } else {
            // On mobile, handle File for video playback
            final File videoFile = File(pickedVideo.path);
            _videoPlayerController = VideoPlayerController.file(videoFile)
              ..initialize().then((_) {
                setState(() {});
              });
          }

          _video = File(pickedVideo.path);
          _selectedFiles = [pickedVideo];
          isVideoSelected = true;
          isImageSelected = false; // Reset image flag if video is selected
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video size must be less than 50 MB.')),
        );
      }
    }
  }

  void nextBtnClicked() async {
    if (textController.text.isNotEmpty ||
        _images.isNotEmpty ||
        _video != null) {
      Map<String, dynamic> data = HashMap();
      if (_images.isNotEmpty) {
        List<UploadedFileModel> results = await UploadFileProvider.uploadImage(
            _selectedFiles[0].name, _images, true);
        List<String> imageUrls = [];
        for (int i = 0; i < results.length; i++) {
          imageUrls.add(results[i].location);
        }
        data['images'] = imageUrls;
      }
      if (_video != null) {
        List<UploadedFileModel> results = await UploadFileProvider.uploadImage(
            _selectedFiles[0].name, [_video!], false);
        data['videofile'] = results[0].location;
      }
      if (widget.club != null) {
        data['club'] = widget.club!.id;
      } else if (widget.fest != null) {
        data['fest'] = widget.fest!.id;
      } else if (!widget.toEdit) {
        data['user'] = _currentUserId;
      }
      if (widget.post != null && !widget.toEdit) {
        data['sharedPost'] = widget.post!.id;
      }
      data['text'] = textController.text;
      if (privacy != "public") {
        data['privacy'] = privacy;
      }
      if (widget.post != null && widget.toEdit) {
        data['_id'] = widget.post!.id;
        updatePostContentApi(context, data);
      } else {
        final postFeedNotifier = ref.read(postFeedProvider.notifier);
        postFeedNotifier.addPost(context, data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final yourClubs = ref.watch(yourClubFeedProvider);
    if (privacyOptions.length == 1) {
      setState(() {
        for (var club in yourClubs) {
          privacyOptions.add({"id": club.id, "name": club.clubName});
        }
      });
    }

    var sharedPostUsername = "";
    var sharedPostUserImg =
        "https://learningx-s3.s3.ap-south-1.amazonaws.com/user.png";
    if (widget.post != null) {
      if (widget.post!.user != null) {
        sharedPostUsername = widget.post!.user!.displayName;
        sharedPostUserImg = widget.post!.user!.userImg;
      } else if (widget.post!.club != null) {
        sharedPostUsername = widget.post!.club!.clubName;
        sharedPostUserImg = widget.post!.club!.clubImg;
      } else if (widget.post!.fest != null) {
        sharedPostUsername = widget.post!.fest!.festName;
        sharedPostUserImg = widget.post!.fest!.festImg;
      }
    }
    if (widget.toEdit) {
      setState(() {
        _currentUserName = sharedPostUsername;
        _currentUserImg = sharedPostUserImg;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.toEdit
            ? "Edit Post"
            : widget.post != null
                ? "Share Post"
                : 'Create Post'),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
      ),
      body: Container(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(_currentUserImg),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_currentUserName,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                          const SizedBox(
                            height: 12,
                          ),
                          DropdownMenu<String>(
                            initialSelection: privacy,
                            label: const Text('Privacy'),
                            onSelected: (String? newValue) {
                              setState(() {
                                privacy = newValue!;
                              });
                            },
                            dropdownMenuEntries: privacyOptions
                                .map<DropdownMenuEntry<String>>(
                                    (Map<String, String> value) {
                              return DropdownMenuEntry<String>(
                                value: value['id']!,
                                label: value['name']!,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: textController,
                    minLines: 2,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: 'write something here...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.post != null)
                    Visibility(
                        visible:
                            widget.toEdit && widget.post!.images.length == 1,
                        child: Container(
                          margin: const EdgeInsets.only(top: 5),
                          width: MediaQuery.of(context).size.width - 10,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                widget.post!.images.isNotEmpty
                                    ? widget.post!.images.first
                                    : "https://learningx-s3.s3.ap-south-1.amazonaws.com/user.png",
                                fit: BoxFit.contain,
                                width: MediaQuery.of(context).size.height / 1.8,
                              ),
                            ),
                          ),
                        )),
                  if (widget.post != null)
                    Visibility(
                        visible:
                            widget.toEdit && widget.post!.images.length > 1,
                        child: Container(
                          margin: const EdgeInsets.only(top: 5),
                          width: MediaQuery.of(context).size.width - 10,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: ImageSlider(imgList: widget.post!.images)),
                        )),
                  if (widget.post != null)
                    Visibility(
                      visible: widget.toEdit && widget.post!.videofile != null,
                      child: VideoPlayerWidget(
                        url: widget.post!.videofile,
                      ),
                    ),
                  if (isImageSelected)
                    _images.isNotEmpty
                        ? Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _images.map((image) {
                              return Container(
                                width:
                                    (MediaQuery.of(context).size.width - 24) /
                                        2,
                                height:
                                    (MediaQuery.of(context).size.width - 24) /
                                        2,
                                color: Colors.grey,
                                child: Stack(
                                  children: [
                                    if (kIsWeb)
                                      Image.network(image.path,
                                          width: double.infinity,
                                          height: double.infinity,
                                          key: UniqueKey(),
                                          fit: _images.length == 1
                                              ? BoxFit.contain
                                              : BoxFit.cover),
                                    if (!kIsWeb)
                                      Image.file(image,
                                          width: double.infinity,
                                          height: double.infinity,
                                          key: UniqueKey(),
                                          fit: _images.length == 1
                                              ? BoxFit.contain
                                              : BoxFit.cover),
                                    Positioned(
                                      left: 0,
                                      child: GestureDetector(
                                        onTap: () async {
                                          var x = 1.0;
                                          if (_images.length == 1) {
                                            x = 0;
                                          }
                                          final croppedImage =
                                              await ImageCropperPage.cropImage(
                                                  context, image, x, 1);
                                          if (croppedImage != null) {
                                            setState(() {
                                              // Replace the current image in the list with the cropped one
                                              final imageIndex =
                                                  _images.indexOf(image);
                                              if (imageIndex != -1) {
                                                _images[imageIndex] =
                                                    croppedImage;
                                              }
                                            });
                                          }
                                        },
                                        child: const Icon(Icons.crop_outlined,
                                            color: Colors.blue),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _images.remove(image);
                                            if (_images.isEmpty) {
                                              isImageSelected = false;
                                            }
                                          });
                                        },
                                        child: const Icon(Icons.remove_circle,
                                            color: Colors.blue),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                        : const SizedBox()
                  else if (isVideoSelected)
                    if (_video != null)
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context)
                            .size
                            .height, // Aspect ratio 16:9
                        child: Stack(
                          children: [
                            VideoPlayer(_videoPlayerController!),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: GestureDetector(
                                onTap: () {
                                  _videoPlayerController?.dispose();
                                  setState(() {
                                    _video = null;
                                    _videoPlayerController = null;
                                    isVideoSelected = false;
                                  });
                                },
                                child: const Icon(Icons.remove_circle,
                                    color: Colors.blue, size: 30),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              bottom: 8,
                              child: IconButton(
                                icon: Icon(
                                  _videoPlayerController!.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  if (_videoPlayerController != null &&
                                      _videoPlayerController!
                                          .value.isInitialized) {
                                    setState(() {
                                      _videoPlayerController!.value.isPlaying
                                          ? _videoPlayerController!.pause()
                                          : _videoPlayerController!.play();
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox()
                  else
                    const SizedBox(),
                  const SizedBox(height: 8),
                  if (widget.post != null && !widget.toEdit)
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 8,
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      NetworkImage(sharedPostUserImg),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(sharedPostUsername,
                                        style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Visibility(
                                visible: widget.post!.text.isNotEmpty,
                                child: Text(
                                  widget.post!.text,
                                  style: const TextStyle(color: Colors.black),
                                )),
                            Visibility(
                                visible: widget.post!.images.length == 1,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  width: MediaQuery.of(context).size.width - 10,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        widget.post!.images.isNotEmpty
                                            ? widget.post!.images.first
                                            : "https://learningx-s3.s3.ap-south-1.amazonaws.com/user.png",
                                        fit: BoxFit.contain,
                                        width:
                                            MediaQuery.of(context).size.height /
                                                1.8,
                                      ),
                                    ),
                                  ),
                                )),
                            Visibility(
                                visible: widget.post!.images.length > 1,
                                child: Container(
                                  margin: const EdgeInsets.only(top: 5),
                                  width: MediaQuery.of(context).size.width - 10,
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                      padding: const EdgeInsets.all(1.0),
                                      child: ImageSlider(
                                          imgList: widget.post!.images)),
                                )),
                            Visibility(
                              visible: widget.post!.videofile != null,
                              child: VideoPlayerWidget(
                                url: widget.post!.videofile,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (widget.post == null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Add Photo'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickVideo,
                        icon: const Icon(
                          Icons.ondemand_video,
                        ),
                        label: const Text('Add Video'),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    nextBtnClicked();
                  },
                  child: const Text('Post'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
