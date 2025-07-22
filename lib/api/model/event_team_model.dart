import 'package:learningx_flutter_app/api/model/user_modal.dart';

class EventTeam {
  final String id;
  final String event;
  final User creator;
  final int teamNumber;
  final String teamName;
  final String status;
  final List<TeamMember> members;
  final String createdAt;

  EventTeam(
      {required this.id,
      required this.event,
      required this.creator,
      required this.teamNumber,
      required this.teamName,
      required this.status,
      required this.members,
      required this.createdAt});

  EventTeam copyWith({String? status}) {
    return EventTeam(
        id: id,
        event: event,
        creator: creator,
        teamNumber: teamNumber,
        teamName: teamName,
        status: status ?? this.status,
        members: members,
        createdAt: createdAt);
  }

  factory EventTeam.fromJson(Map<String, dynamic> json) {
    return EventTeam(
        id: json['_id'],
        event: json['event'],
        creator: User.fromJson(json['creator']),
        teamNumber: json['teamNumber'],
        teamName: json['teamName'],
        status: json['status'],
        members: List<TeamMember>.from(
            json['members'].map((itemJson) => TeamMember.fromJson(itemJson))),
        createdAt: json['createdAt']);
  }

  DateTime get createdAtDate => DateTime.parse(createdAt);
}

class TeamMember {
  final String id;
  final String memberName;
  final String email;
  final String phone;
  final String college;
  final String otherDetails;

  TeamMember({
    required this.id,
    required this.memberName,
    required this.email,
    required this.phone,
    required this.college,
    required this.otherDetails,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['_id'],
      memberName: json['memberName'],
      email: json['email'],
      phone: json['phone'],
      college: json['college'],
      otherDetails: json['otherDetails'],
    );
  }
}
