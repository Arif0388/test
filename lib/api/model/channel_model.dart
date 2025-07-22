import 'package:learningx_flutter_app/api/model/populated_model.dart';

class Channel {
  final String id;
  final String name;
  final String privacy;
  final String permission;
  final String club;
  final List<String> admin;
  final List<String> members;
  late int unreadCount;

  Channel(
      {required this.id,
      required this.name,
      required this.privacy,
      required this.permission,
      required this.club,
      required this.admin,
      required this.members,
      required this.unreadCount});

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
        id: json['_id'],
        name: json['name'],
        privacy: json['privacy'],
        permission: json['permission'],
        club: json['club'],
        admin: List<String>.from(json['admin']),
        members: List<String>.from(json['members']),
        unreadCount: json['unreadCount'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'privacy': privacy,
      'permission': permission,
      'club': club,
      'admin': admin,
      'members': members,
      'unreadCount': unreadCount,
    };
  }
}

class ChannelWithClub {
  final String id;
  final String name;
  final String privacy;
  final String permission;
  final PopulatedClub club;
  final List<String> admin;
  final List<String> members;
  late int unreadCount;

  ChannelWithClub(
      {required this.id,
      required this.name,
      required this.privacy,
      required this.permission,
      required this.club,
      required this.admin,
      required this.members,
      required this.unreadCount});

  factory ChannelWithClub.fromJson(Map<String, dynamic> json) {
    return ChannelWithClub(
        id: json['_id'],
        name: json['name'],
        privacy: json['privacy'],
        permission: json['permission'],
        club: PopulatedClub.fromJson(json['club']),
        admin: List<String>.from(json['admin']),
        members: List<String>.from(json['members']),
        unreadCount: 0);
  }
}
