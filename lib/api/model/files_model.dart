import 'package:learningx_flutter_app/api/model/channel_model.dart';
import 'package:learningx_flutter_app/api/model/user_modal.dart';

class Files {
  final String id;
  final User user;
  final String club;
  final Channel channel;
  final String filesLink;
  final String filetype;
  final String filename;
  final String filesize;
  final String realFiletype;
  final String createdAt;

  Files(
      {required this.id,
      required this.user,
      required this.club,
      required this.channel,
      required this.filesLink,
      required this.filetype,
      required this.filename,
      required this.filesize,
      required this.realFiletype,
      required this.createdAt});

  factory Files.fromJson(Map<String, dynamic> json) {
    return Files(
      id: json['_id'],
      user: User.fromJson(json['user']),
      club: json['club'],
      channel: Channel.fromJson(json['channel']),
      filesLink: json['filesLink'],
      filetype: json['filetype'],
      filename: json['filename'],
      filesize: json['filesize'],
      realFiletype: json['realFiletype'],
      createdAt: json['createdAt']
    );
  }
  DateTime get createdAtDate => DateTime.parse(createdAt);
}
