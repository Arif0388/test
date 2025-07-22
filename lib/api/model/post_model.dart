import 'package:learningx_flutter_app/api/model/populated_model.dart';
import 'package:learningx_flutter_app/api/model/user_modal.dart';

class Post {
  final String id;
  final String text;
  final PostUser? user;
  final PostClub? club;
  final PostFest? fest;
  final PopulatedClub? privacy;
  final List<String> images;
  final String? videofile;
  final SharedPost? sharedPost;
  final List<String>? likes;
  final List<String>? savedBy;
  final int commentsCount;
  final bool edited;

  Post(
      {required this.id,
      required this.text,
      this.user,
      this.club,
      this.fest,
      this.privacy,
      required this.images,
      this.videofile,
      this.sharedPost,
      this.likes,
      this.savedBy,
      required this.commentsCount,
      required this.edited});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        id: json['_id'],
        text: json['text'],
        user: json['user'] != null ? PostUser.fromJson(json['user']) : null,
        club: json['club'] != null ? PostClub.fromJson(json['club']) : null,
        fest: json['fest'] != null ? PostFest.fromJson(json['fest']) : null,
        privacy: json['privacy'] != null
            ? PopulatedClub.fromJson(json['privacy'])
            : null,
        images: List<String>.from(json['images']),
        videofile: json['videofile'],
        sharedPost: json['sharedPost'] != null
            ? SharedPost.fromJson(json['sharedPost'])
            : null,
        likes: json['likes'] != null ? List<String>.from(json['likes']) : [],
        savedBy:
            json['savedBy'] != null ? List<String>.from(json['savedBy']) : [],
        commentsCount: json['commentsCount'],
        edited: json['edited']);
  }

  Post copyWith({List<String>? likes, List<String>? savedBy}) {
    return Post(
        id: id,
        text: text,
        user: user,
        club: club,
        fest: fest,
        privacy: privacy,
        images: images,
        videofile: videofile,
        sharedPost: sharedPost,
        likes: likes ?? this.likes,
        savedBy: savedBy ?? this.savedBy,
        commentsCount: commentsCount,
        edited: edited);
  }
}

class PostUser {
  final String id;
  late final String firstname;
  final String lastname;
  final String displayName;
  final String userImg;
  final String userName;
  final String googleId;
  final bool verified;
  final PopulatedCollege? college;

  PostUser(
      {required this.id,
      required this.firstname,
      required this.lastname,
      required this.displayName,
      required this.userImg,
      required this.userName,
      required this.googleId,
      required this.verified,
      this.college});

  factory PostUser.fromJson(Map<String, dynamic> json) {
    return PostUser(
      id: json['_id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      displayName: json['displayName'],
      userImg: json['userImg'],
      userName: json['user_name'],
      googleId: json['googleId'],
      verified: json['admin'],
      college: json['college'] != null
          ? PopulatedCollege.fromJson(json['college'])
          : null,
    );
  }
}

class PostClub {
  final String id;
  final List<String> admin;
  final String clubName;
  final String clubImg;
  final String category;
  final PopulatedCollege? college;
  final List<String> members;

  PostClub({
    required this.id,
    required this.admin,
    required this.clubName,
    required this.clubImg,
    required this.category,
    this.college,
    required this.members,
  });

  factory PostClub.fromJson(Map<String, dynamic> json) {
    return PostClub(
      id: json['_id'],
      admin: List<String>.from(json['admin']),
      clubName: json['clubName'],
      clubImg: json['clubImg'],
      category: json['category'],
      college: json['college'] != null
          ? PopulatedCollege.fromJson(json['college'])
          : null,
      members: List<String>.from(json['members']),
    );
  }
}

class PostFest {
  final String id;
  final List<String> admin;
  final String festName;
  final String festImg;
  final PopulatedCollege college;

  PostFest({
    required this.id,
    required this.admin,
    required this.festName,
    required this.festImg,
    required this.college,
  });

  factory PostFest.fromJson(Map<String, dynamic> json) {
    return PostFest(
        id: json['_id'],
        admin: List<String>.from(json['admin']),
        festName: json['festName'],
        festImg: json['festImg'],
        college: PopulatedCollege.fromJson(json['college']));
  }
}

class SharedPost {
  final String id;
  final String text;
  final User? user;
  final PopulatedClub? club;
  final PopulatedFest? fest;
  final List<String> images;
  final String? videofile;
  final List<String>? likes;
  final List<String>? savedBy;
  final int commentsCount;
  final bool edited;

  SharedPost(
      {required this.id,
      required this.text,
      this.user,
      this.club,
      this.fest,
      required this.images,
      this.videofile,
      this.likes,
      this.savedBy,
      required this.commentsCount,
      required this.edited});

  factory SharedPost.fromJson(Map<String, dynamic> json) {
    return SharedPost(
        id: json['_id'],
        text: json['text'],
        user: json['user'] != null ? User.fromJson(json['user']) : null,
        club:
            json['club'] != null ? PopulatedClub.fromJson(json['club']) : null,
        fest:
            json['fest'] != null ? PopulatedFest.fromJson(json['fest']) : null,
        images: List<String>.from(json['images']),
        videofile: json['videofile'],
        likes: json['likes'] != null ? List<String>.from(json['likes']) : [],
        savedBy:
            json['savedBy'] != null ? List<String>.from(json['savedBy']) : [],
        commentsCount: json['commentsCount'],
        edited: json['edited']);
  }
}
