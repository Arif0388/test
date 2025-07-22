class PopulatedClub {
  final String id;
  final String clubName;
  final String clubImg;
  final List<String> admin;
  final List<String> members;
  final String email;

  PopulatedClub(
      {required this.id,
      required this.clubName,
      required this.clubImg,
      required this.admin,
      required this.members,
      required this.email});

  factory PopulatedClub.fromJson(Map<String, dynamic> json) {
    return PopulatedClub(
        id: json['_id'],
        clubName: json['clubName'],
        clubImg: json['clubImg'],
        admin: List<String>.from(json['admin']),
        members: List<String>.from(json['members']),
        email: json['email']);
  }
}

class PopulatedFest {
  final String id;
  final String festName;
  final String festImg;
  final List<String> admin;
  final String email;

  PopulatedFest(
      {required this.id,
      required this.festName,
      required this.festImg,
      required this.admin,
      required this.email});

  factory PopulatedFest.fromJson(Map<String, dynamic> json) {
    return PopulatedFest(
        id: json['_id'],
        festName: json['festName'],
        festImg: json['festImg'],
        admin: List<String>.from(json['admin']),
        email: json['email']);
  }
}

class PopulatedCollege {
  final String id;
  final String collegeName;
  final String collegeImg;
  final List<String> admin;
  final String email;
  final bool restricted;
  final String emailDomain;

  PopulatedCollege(
      {required this.id,
      required this.collegeName,
      required this.collegeImg,
      required this.admin,
      required this.email,
      required this.restricted,
      required this.emailDomain});

  factory PopulatedCollege.fromJson(Map<String, dynamic> json) {
    return PopulatedCollege(
      id: json['_id'],
      collegeName: json['collegeName'],
      collegeImg: json['collegeImg'],
      admin: List<String>.from(json['admin']),
      email: json['email'],
      restricted: json['restricted'],
      emailDomain: json['emailDomain'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'collegeName': collegeName,
      'collegeImg': collegeImg,
      'admin': admin,
      'email': email,
      'restricted': restricted,
      'emailDomain': emailDomain
    };
  }
}

class PopulatedEvent {
  final String id;
  final String eventTitle;
  final String eventImg;
  final List<String> admin;

  PopulatedEvent(
      {required this.id,
      required this.eventTitle,
      required this.eventImg,
      required this.admin});

  factory PopulatedEvent.fromJson(Map<String, dynamic> json) {
    return PopulatedEvent(
      id: json['_id'],
      eventTitle: json['eventTitle'],
      eventImg: json['eventImg'],
      admin: List<String>.from(json['admin']),
    );
  }
}

class PopulatedPost {
  final String id;
  final String text;
  final List<String>? likes;
  final int commentsCount;

  PopulatedPost(
      {required this.id,
      required this.text,
      this.likes,
      required this.commentsCount});

  factory PopulatedPost.fromJson(Map<String, dynamic> json) {
    return PopulatedPost(
      id: json['_id'],
      text: json['text'],
      likes: json['likes'] != null ? List<String>.from(json['likes']) : [],
      commentsCount: json['commentsCount'],
    );
  }
}

class PopulatedCouncil {
  final String id;
  final String councilName;
  final String councilImg;
  final List<String> admin;
  final List<String> members;
  final String email;

  PopulatedCouncil(
      {required this.id,
      required this.councilName,
      required this.councilImg,
      required this.admin,
      required this.members,
      required this.email});

  factory PopulatedCouncil.fromJson(Map<String, dynamic> json) {
    return PopulatedCouncil(
        id: json['_id'],
        councilName: json['councilName'],
        councilImg: json['councilImg'],
        admin: List<String>.from(json['admin']),
        members: List<String>.from(json['members']),
        email: json['email']);
  }
}
