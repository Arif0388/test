import 'package:learningx_flutter_app/api/model/populated_model.dart';
import 'package:learningx_flutter_app/api/model/user_modal.dart';

class Fest {
  final String id;
  final List<User> admin;
  final String festName;
  final String festImg;
  final PopulatedCollege college;
  final String startDate;
  final String endDate;
  final String description;
  final String email;
  final String website;
  final String instagram;
  final String linkedIn;
  final List<String>? followedBy;

  Fest({
    required this.id,
    required this.admin,
    required this.festName,
    required this.festImg,
    required this.college,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.email,
    required this.website,
    required this.instagram,
    required this.linkedIn,
    this.followedBy,
  });

  factory Fest.fromJson(Map<String, dynamic> json) {
    return Fest(
      id: json['_id'],
      admin: List<User>.from(
          json['admin'].map((itemJson) => User.fromJson(itemJson))),
      festName: json['festName'],
      festImg: json['festImg'],
      college: PopulatedCollege.fromJson(json['college']),
      startDate: json['startDate'],
      endDate: json['endDate'],
      description: json['description'],
      email: json['email'],
      website: json['website'],
      instagram: json['instagram'],
      linkedIn: json['linkedIn'],
      followedBy: json['followedBy'] != null
          ? List<String>.from(json['followedBy'])
          : [],
    );
  }

  DateTime get startedAtDate => DateTime.parse(startDate);
  DateTime get endAtDate => DateTime.parse(endDate);
}
