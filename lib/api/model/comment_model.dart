import 'package:learningx_flutter_app/api/model/user_modal.dart';

class PostComment {
  final String id;
  final User user;
  final String post;
  final String? parentCommentId;
  final String comment;
  final String createdAt;

  PostComment(
      {required this.id,
      required this.user,
      required this.post,
      this.parentCommentId,
      required this.comment,
      required this.createdAt});

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['_id'],
      user: User.fromJson(json['user']),
      post: json['post'],
      parentCommentId: json['parentCommentId'],
      comment: json['comment'],
      createdAt: json['createdAt']
    );
  }
  DateTime get createdAtDate => DateTime.parse(createdAt);
}
