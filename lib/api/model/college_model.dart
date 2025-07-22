import 'package:learningx_flutter_app/api/model/user_modal.dart';

class College {
  final String id;
  final List<User> admin;
  final String collegeName;
  final String collegeImg;
  final String description;
  final String email;
  final String website;
  final String instagram;
  final String linkedIn;
  final bool restricted;
  final String emailDomain;
  final bool verified;
  final City city;

  College(
      {required this.id,
      required this.admin,
      required this.collegeName,
      required this.collegeImg,
      required this.description,
      required this.email,
      required this.website,
      required this.instagram,
      required this.linkedIn,
      required this.restricted,
      required this.emailDomain,
      required this.verified,
      required this.city});

  factory College.fromJson(Map<String, dynamic> json) {
    return College(
      id: json['_id'],
      admin: List<User>.from(
          json['admin'].map((itemJson) => User.fromJson(itemJson))),
      collegeName: json['collegeName'],
      collegeImg: json['collegeImg'],
      description: json['description'],
      email: json['email'],
      website: json['website'],
      instagram: json['instagram'],
      linkedIn: json['linkedIn'],
      restricted: json['restricted'],
      emailDomain: json['emailDomain'],
      verified: json['verified'],
      city: City.fromJson(json['city']),
    );
  }
}

class City {
  final String address;
  City({required this.address});
  factory City.fromJson(Map<String, dynamic> json) {
    return City(address: json['address']);
  }
  Map<String, dynamic> toJson() {
    return {
      'address': address,
    };
  }
}
