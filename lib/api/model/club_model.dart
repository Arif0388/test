import 'package:learningx_flutter_app/api/model/channel_model.dart';
import 'package:learningx_flutter_app/api/model/populated_model.dart';
import 'package:learningx_flutter_app/api/model/user_modal.dart';

class Club {
  final String id;
  final List<User> admin;
  final String clubName;
  final String clubImg;
  final String category;
  final String councilName;
  final List<Channel> channels;
  final bool learningXClub;
  final PopulatedCollege? college;
  final PopulatedCouncil? council;
  final String privacy;
  final String collegeStatus;
  final String description;
  final String email;
  final String website;
  final String instagram;
  final String linkedIn;
  final List<Learning> learnings;
  final List<String> members;
  final List<Faqs>? faqs;
  final String createdAt;

  Club(
      {required this.id,
      required this.admin,
      required this.clubName,
      required this.clubImg,
      required this.category,
      required this.councilName,
      required this.channels,
      required this.learningXClub,
      this.college,
      this.council,
      required this.privacy,
      required this.collegeStatus,
      required this.description,
      required this.email,
      required this.website,
      required this.instagram,
      required this.linkedIn,
      required this.learnings,
      required this.members,
      this.faqs,
      required this.createdAt});

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
        id: json['_id'],
        admin: List<User>.from(
            json['admin'].map((itemJson) => User.fromJson(itemJson))),
        clubName: json['clubName'],
        clubImg: json['clubImg'],
        category: json['category'],
        councilName: json['councilName'],
        channels: List<Channel>.from(
            json['channels'].map((itemJson) => Channel.fromJson(itemJson))),
        learningXClub: json['learningXClub'],
        college: json['college'] != null
            ? PopulatedCollege.fromJson(json['college'])
            : null,
        council: json['council'] != null
            ? PopulatedCouncil.fromJson(json['council'])
            : null,
        privacy: json['privacy'],
        collegeStatus: json['college_status'],
        description: json['description'],
        email: json['email'],
        website: json['website'],
        instagram: json['instagram'],
        linkedIn: json['linkedIn'],
        learnings: List<Learning>.from(
            json['learnings'].map((itemJson) => Learning.fromJson(itemJson))),
        members: List<String>.from(json['members']),
        faqs: json['faqs'] != null
            ? List<Faqs>.from(
                json['faqs'].map((itemJson) => Faqs.fromJson(itemJson)))
            : [],
        createdAt: json['createdAt']);
  }

  Club copyWith({
    String? id,
    List<User>? admin,
    String? clubName,
    String? clubImg,
    String? category,
    String? councilName,
    List<Channel>? channels,
    bool? learningXClub,
    PopulatedCollege? college,
    String? privacy,
    String? collegeStatus,
    String? description,
    String? email,
    String? website,
    String? instagram,
    String? linkedIn,
    List<Learning>? learnings,
    List<String>? members,
    List<Faqs>? faqs,
    String? createdAt,
  }) {
    return Club(
      id: id ?? this.id,
      admin: admin ?? this.admin,
      clubName: clubName ?? this.clubName,
      clubImg: clubImg ?? this.clubImg,
      category: category ?? this.category,
      councilName: category ?? this.councilName,
      channels: channels ?? this.channels,
      learningXClub: learningXClub ?? this.learningXClub,
      college: college ?? this.college,
      privacy: privacy ?? this.privacy,
      collegeStatus: collegeStatus ?? this.collegeStatus,
      description: description ?? this.description,
      email: email ?? this.email,
      website: website ?? this.website,
      instagram: instagram ?? this.instagram,
      linkedIn: linkedIn ?? this.linkedIn,
      learnings: learnings ?? this.learnings,
      members: members ?? this.members,
      faqs: faqs ?? this.faqs,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Faqs {
  final String question;
  final String answer;

  Faqs({required this.question, required this.answer});

  factory Faqs.fromJson(Map<String, dynamic> json) {
    return Faqs(
      question: json['question'],
      answer: json['answer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'question': question, 'answer': answer};
  }
}

class Learning {
  final String learning;

  Learning({required this.learning});

  factory Learning.fromJson(Map<String, dynamic> json) {
    return Learning(
      learning: json['learning'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'learning': learning};
  }
}

class ClubItem {
  final String id;
  final List<String> admin;
  final String clubName;
  final String clubImg;
  final String category;
  final String? councilName;
  final List<Channel> channels;
  final bool learningXClub;
  final PopulatedCollege? college;
  final String privacy;
  final String collegeStatus;
  final String description;
  final String email;
  final String website;
  final String instagram;
  final String linkedIn;
  final List<Learning> learnings;
  final List<String> members;
  final List<Faqs>? faqs;

  ClubItem({
    required this.id,
    required this.admin,
    required this.clubName,
    required this.clubImg,
    required this.category,
    this.councilName,
    required this.channels,
    required this.learningXClub,
    this.college,
    required this.privacy,
    required this.collegeStatus,
    required this.description,
    required this.email,
    required this.website,
    required this.instagram,
    required this.linkedIn,
    required this.learnings,
    required this.members,
    this.faqs,
  });

  factory ClubItem.fromJson(Map<String, dynamic> json) {
    return ClubItem(
      id: json['_id'],
      admin: List<String>.from(json['admin']),
      clubName: json['clubName'],
      clubImg: json['clubImg'],
      category: json['category'],
      councilName: json['councilName'] ?? "",
      channels: List<Channel>.from(
          json['channels'].map((itemJson) => Channel.fromJson(itemJson))),
      learningXClub: json['learningXClub'],
      college: json['college'] != null
          ? PopulatedCollege.fromJson(json['college'])
          : null,
      privacy: json['privacy'],
      collegeStatus: json['college_status'],
      description: json['description'],
      email: json['email'],
      website: json['website'],
      instagram: json['instagram'],
      linkedIn: json['linkedIn'],
      learnings: List<Learning>.from(
          json['learnings'].map((itemJson) => Learning.fromJson(itemJson))),
      members: List<String>.from(json['members']),
      faqs: json['faqs'] != null
          ? List<Faqs>.from(
              json['faqs'].map((itemJson) => Faqs.fromJson(itemJson)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'admin': admin,
      'clubName': clubName,
      'clubImg': clubImg,
      'category': category,
      'councilName': councilName,
      'channels': channels.map((channel) => channel.toJson()).toList(),
      'learningXClub': learningXClub,
      'college': college?.toJson(),
      'privacy': privacy,
      'college_status': collegeStatus,
      'description': description,
      'email': email,
      'website': website,
      'instagram': instagram,
      'linkedIn': linkedIn,
      'learnings': learnings.map((learning) => learning.toJson()).toList(),
      'members': members,
      'faqs': faqs?.map((faq) => faq.toJson()).toList(),
    };
  }
}

extension ClubExtensions on Club {
  ClubItem toClubItem() {
    return ClubItem(
      id: id,
      admin: admin.map((user) => user.id).toList(),
      clubName: clubName,
      clubImg: clubImg,
      category: category,
      councilName: councilName,
      channels: channels,
      learningXClub: learningXClub,
      college: college,
      privacy: privacy,
      collegeStatus: collegeStatus,
      description: description,
      email: email,
      website: website,
      instagram: instagram,
      linkedIn: linkedIn,
      learnings: learnings,
      members: members,
      faqs: faqs,
    );
  }
}
