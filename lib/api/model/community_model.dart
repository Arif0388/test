import 'package:learningx_flutter_app/api/model/channel_model.dart';
import 'package:learningx_flutter_app/api/model/user_modal.dart';

class Community {
  final String id;
  final List<User> admin;
  final String title;
  final String coverImg;
  final String category;
  final List<Channel> channels;
  final String privacy;
  final String description;
  final String email;
  final String website;
  final String instagram;
  final String linkedIn;
  final List<Learning> learnings;
  final List<String> members;
  final List<Faqs>? faqs;
  final String createdAt;

  Community(
      {required this.id,
      required this.admin,
      required this.title,
      required this.coverImg,
      required this.category,
      required this.channels,
      required this.privacy,
      required this.description,
      required this.email,
      required this.website,
      required this.instagram,
      required this.linkedIn,
      required this.learnings,
      required this.members,
      this.faqs,
      required this.createdAt});

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
        id: json['_id'],
        admin: List<User>.from(
            json['admin'].map((itemJson) => User.fromJson(itemJson))),
        title: json['title'],
        coverImg: json['coverImg'],
        category: json['category'],
        channels: List<Channel>.from(
            json['channels'].map((itemJson) => Channel.fromJson(itemJson))),
        privacy: json['privacy'],
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

  Community copyWith({
    String? id,
    List<User>? admin,
    String? title,
    String? coverImg,
    String? category,
    List<Channel>? channels,
    String? privacy,
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
    return Community(
      id: id ?? this.id,
      admin: admin ?? this.admin,
      title: title ?? this.title,
      coverImg: coverImg ?? this.coverImg,
      category: category ?? this.category,
      channels: channels ?? this.channels,
      privacy: privacy ?? this.privacy,
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

class CommunityItem {
  final String id;
  final List<String> admin;
  final String title;
  final String coverImg;
  final String category;
  final List<Channel> channels;
  final String privacy;
  final String description;
  final String email;
  final String website;
  final String instagram;
  final String linkedIn;
  final List<Learning> learnings;
  final List<String> members;
  final List<Faqs>? faqs;

  CommunityItem({
    required this.id,
    required this.admin,
    required this.title,
    required this.coverImg,
    required this.category,
    required this.channels,
    required this.privacy,
    required this.description,
    required this.email,
    required this.website,
    required this.instagram,
    required this.linkedIn,
    required this.learnings,
    required this.members,
    this.faqs,
  });

  factory CommunityItem.fromJson(Map<String, dynamic> json) {
    return CommunityItem(
      id: json['_id'],
      admin: List<String>.from(json['admin']),
      title: json['title'],
      coverImg: json['coverImg'],
      category: json['category'],
      channels: List<Channel>.from(
          json['channels'].map((itemJson) => Channel.fromJson(itemJson))),
      privacy: json['privacy'],
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
      'title': title,
      'coverImg': coverImg,
      'category': category,
      'channels': channels.map((channel) => channel.toJson()).toList(),
      'privacy': privacy,
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

extension CommunityExtensions on Community {
  CommunityItem toClubItem() {
    return CommunityItem(
      id: id,
      admin: admin.map((user) => user.id).toList(),
      title: title,
      coverImg: coverImg,
      category: category,
      channels: channels,
      privacy: privacy,
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
