import 'package:learningx_flutter_app/api/model/populated_model.dart';
import 'package:learningx_flutter_app/api/model/user_modal.dart';

class NotificationModel {
  final String id;
  final User? userBy;
  final PopulatedPost? post;
  final PopulatedClub? club;
  final PopulatedEvent? event;
  final String msg;
  final String createdAt;

  NotificationModel(
      {required this.id,
      this.userBy,
      this.post,
      this.club,
      this.event,
      required this.msg,
      required this.createdAt});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      userBy: json['userBy'] != null ? User.fromJson(json['userBy']) : null,
      post: json['post'] != null ? PopulatedPost.fromJson(json['post']) : null,
      club: json['club'] != null ? PopulatedClub.fromJson(json['club']) : null,
      event:
          json['event'] != null ? PopulatedEvent.fromJson(json['event']) : null,
      msg: json['msg'],
      createdAt: json['createdAt']
    );
  }

  DateTime get createdAtDate => DateTime.parse(createdAt);
}
