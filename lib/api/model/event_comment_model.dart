import 'package:learningx_flutter_app/api/model/user_modal.dart';

class EventComment {
  final String id;
  final User user;
  final String event;
  final String? parentCommentId;
  final String comment;
  final int? repliedCount;
  final String createdAt;

  EventComment(
      {required this.id,
      required this.user,
      required this.event,
      this.parentCommentId,
      required this.comment,
      this.repliedCount,
      required this.createdAt});

  factory EventComment.fromJson(Map<String, dynamic> json) {
    return EventComment(
        id: json['_id'],
        user: User.fromJson(json['user']),
        event: json['event'],
        parentCommentId: json['parentCommentId'],
        comment: json['comment'],
        repliedCount: json['repliedCount'] ?? 0,
        createdAt: json['createdAt']);
  }
  DateTime get createdAtDate => DateTime.parse(createdAt);
}
