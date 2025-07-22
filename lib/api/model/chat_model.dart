import 'package:learningx_flutter_app/api/model/user_modal.dart';

class Chat {
  final String id;
  final User sender;
  final String chat;
  final String room;
  final String? file;
  final String filetype;
  final String filename;
  final String filesize;
  final String realFiletype;
  final String createdAt;

  Chat(
      {required this.id,
      required this.sender,
      required this.chat,
      required this.room,
      this.file,
      required this.filetype,
      required this.filename,
      required this.filesize,
      required this.realFiletype,
      required this.createdAt});

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['_id'],
      sender: User.fromJson(json['sender']),
      chat: json['chat'],
      room: json['room'],
      file: json['file'],
      filetype: json['filetype'],
      filename: json['filename'],
      filesize: json['filesize'],
      realFiletype: json['realFiletype'],
      createdAt: json['createdAt']
    );
  }

  DateTime get createdAtDate => DateTime.parse(createdAt);
}
