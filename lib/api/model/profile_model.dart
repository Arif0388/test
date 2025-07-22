import 'package:learningx_flutter_app/api/model/post_model.dart';

class Profile {
  final String id;
  final PostUser user;
  final String email;
  final String gender;
  final String birthday;
  final String bio;
  final String currentLocation;
  final String website;
  final String createdAt;
  final List<String>? blockedUser;

  Profile(
      {required this.id,
      required this.user,
      required this.email,
      required this.gender,
      required this.birthday,
      required this.bio,
      required this.currentLocation,
      required this.website,
      required this.createdAt,
      this.blockedUser});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['_id'],
      user: PostUser.fromJson(json['user']),
      email: json['email'],
      gender: json['gender'],
      birthday: json['birthday'],
      bio: json['bio'],
      currentLocation: json['currentLocation'],
      website: json['website'],
      createdAt: json['createdAt'],
      blockedUser: json['blockedUser'] != null
          ? List<String>.from(json['blockedUser'])
          : [],
    );
  }

  Profile copyWith({PostUser? user}) {
    return Profile(
        id: id,
        user: user ?? this.user,
        email: email,
        gender: gender,
        birthday: birthday,
        bio: bio,
        currentLocation: currentLocation,
        website: website,
        createdAt: createdAt,
        blockedUser: blockedUser);
  }

  DateTime get createdAtDate => DateTime.parse(createdAt);
}
