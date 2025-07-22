import 'package:learningx_flutter_app/api/model/user_modal.dart';

class Discussion {
  final String id;
  final User sender;
  final String club;
  final String channel;
  final String? parentChatId;
  final String? title;
  final String chat;
  final int repliedCount;
  final String? file;
  final String filetype;
  final String filename;
  final String filesize;
  final String realFiletype;
  final Poll? poll;
  final String createdAt;

  Discussion(
      {required this.id,
      required this.sender,
      required this.club,
      required this.channel,
      this.parentChatId,
      this.title,
      required this.chat,
      required this.repliedCount,
      this.file,
      required this.filetype,
      required this.filename,
      required this.filesize,
      required this.realFiletype,
      this.poll,
      required this.createdAt});

  factory Discussion.fromJson(Map<String, dynamic> json) {
    return Discussion(
        id: json['_id'],
        sender: User.fromJson(json['sender']),
        club: json['club'],
        channel: json['channel'],
        parentChatId: json['parentChatId'],
        title: json['title'],
        chat: json['chat'],
        repliedCount: json['repliedCount'],
        file: json['file'],
        filetype: json['filetype'],
        filename: json['filename'],
        filesize: json['filesize'],
        realFiletype: json['realFiletype'],
        poll: json['poll'] != null ? Poll.fromJson(json['poll']) : null,
        createdAt: json['createdAt']);
  }
  DateTime get createdAtDate => DateTime.parse(createdAt);
}

class Poll {
  final String question;
  final List<String> options;
  final List<Vote>? votes;
  final bool isAnonymous;
  final bool allowMultipleAnswers;

  Poll(
      {required this.question,
      required this.options,
      this.votes,
      required this.isAnonymous,
      required this.allowMultipleAnswers});

  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      question: json['question'],
      options: List<String>.from(json['options']),
      votes: json['votes'] != null
          ? List<Vote>.from(
              json['votes'].map((itemJson) => Vote.fromJson(itemJson)))
          : [],
      isAnonymous: json['isAnonymous'],
      allowMultipleAnswers: json['allowMultipleAnswers'],
    );
  }
}

class Vote {
  final String id;
  final User voter;
  final List<int> options;
  final String createdAt;

  Vote(
      {required this.id,
      required this.voter,
      required this.options,
      required this.createdAt});

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
        id: json['_id'],
        voter: User.fromJson(json['voter']),
        options: json['options'] != null ? List<int>.from(json['options']) : [],
        createdAt: json['createdAt']);
  }
  DateTime get createdAtDate => DateTime.parse(createdAt);
}
