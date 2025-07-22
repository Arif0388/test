import 'package:learningx_flutter_app/api/model/user_modal.dart';

class Member {
  final String id;
  final User user;
  final String club;
  final String? channel;
  final bool admin;
  final bool active;
  final String role;

  Member(
      {required this.id,
      required this.user,
      required this.club,
      this.channel,
      required this.admin,
      required this.active,
      required this.role});

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
        id: json['_id'],
        user: User.fromJson(json['user']),
        club: json['club'],
        channel: json['channel'],
        admin: json['admin'],
        active: json['active'],
        role: json['role']);
  }
}
