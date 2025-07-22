import 'package:learningx_flutter_app/api/model/club_model.dart';
import 'package:learningx_flutter_app/api/model/populated_model.dart';
import 'package:learningx_flutter_app/api/model/user_modal.dart';

class Council {
  final String id;
  final List<User> admin;
  final String councilName;
  final String councilImg;
  final PopulatedCollege college;
  final ClubItem clubItem;
  final String description;
  final String email;
  final String website;
  final String instagram;
  final String linkedIn;
  final String createdAt;

  Council({
    required this.id,
    required this.admin,
    required this.councilName,
    required this.councilImg,
    required this.college,
    required this.clubItem,
    required this.description,
    required this.email,
    required this.website,
    required this.instagram,
    required this.linkedIn,
    required this.createdAt
  });

  factory Council.fromJson(Map<String, dynamic> json) {
    return Council(
      id: json['_id'],
      admin: List<User>.from(
          json['admin'].map((itemJson) => User.fromJson(itemJson))),
      councilName: json['councilName'],
      councilImg: json['councilImg'],
      college: PopulatedCollege.fromJson(json['college']),
      clubItem: ClubItem.fromJson(json['club']),
      description: json['description'],
      email: json['email'],
      website: json['website'],
      instagram: json['instagram'],
      linkedIn: json['linkedIn'],
      createdAt: json['createdAt']
    );
  }
}

class CouncilItem {
  final String id;
  final List<User> admin;
  final String councilName;
  final String councilImg;
  final PopulatedCollege college;
  final String clubItem;
  final String description;
  final String email;
  final String website;
  final String instagram;
  final String linkedIn;

  CouncilItem({
    required this.id,
    required this.admin,
    required this.councilName,
    required this.councilImg,
    required this.college,
    required this.clubItem,
    required this.description,
    required this.email,
    required this.website,
    required this.instagram,
    required this.linkedIn,
  });

  factory CouncilItem.fromJson(Map<String, dynamic> json) {
    return CouncilItem(
      id: json['_id'],
      admin: List<User>.from(
          json['admin'].map((itemJson) => User.fromJson(itemJson))),
      councilName: json['councilName'],
      councilImg: json['councilImg'],
      college: PopulatedCollege.fromJson(json['college']),
      clubItem: json['club'],
      description: json['description'],
      email: json['email'],
      website: json['website'],
      instagram: json['instagram'],
      linkedIn: json['linkedIn'],
    );
  }
}
