import 'package:learningx_flutter_app/api/model/college_model.dart';
import 'package:learningx_flutter_app/api/model/populated_model.dart';
import 'package:learningx_flutter_app/api/model/user_modal.dart';

class Event {
  final String id;
  final String eventTitle;
  final String eventImg;
  final List<User> admin;
  final PopulatedClub? club;
  final PopulatedCollege? college;
  final PopulatedFest? festival;
  final String eventType;
  final String eventStartDate;
  final String eventEndDate;
  final String location;
  final City city;
  final City venue;
  final String eventLink;
  final int views;
  final String visibility;
  final bool takeRegistration;
  final String registrationPlace;
  final String registrationLink;
  final String participation;
  final String registrationStartDate;
  final String registrationEndDate;
  final int minSizeTeam;
  final int maxSizeTeam;
  final String registrationCharge;
  final String payment;
  final int registrationFee;
  final List<Stage>? stages;
  final List<Result>? results;
  final String description;
  final List<Guideline> guidelines;
  final bool partCertificate;
  final String totalRewards;
  final List<Reward>? rewards;
  final int stepsDone;
  final bool verified;
  final List<String>? registerdTeamLead;
  final String createdAt;

  Event(
      {required this.id,
      required this.eventTitle,
      required this.eventImg,
      required this.admin,
      this.club,
      this.college,
      this.festival,
      required this.eventType,
      required this.eventStartDate,
      required this.eventEndDate,
      required this.location,
      required this.city,
      required this.venue,
      required this.eventLink,
      required this.views,
      required this.visibility,
      required this.takeRegistration,
      required this.registrationPlace,
      required this.registrationLink,
      required this.participation,
      required this.registrationStartDate,
      required this.registrationEndDate,
      required this.minSizeTeam,
      required this.maxSizeTeam,
      required this.registrationCharge,
      required this.payment,
      required this.registrationFee,
      this.stages,
      this.results,
      required this.description,
      required this.guidelines,
      required this.partCertificate,
      required this.totalRewards,
      this.rewards,
      required this.stepsDone,
      required this.verified,
      this.registerdTeamLead,
      required this.createdAt});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
        id: json['_id'],
        eventTitle: json['eventTitle'],
        eventImg: json['eventImg'],
        admin: List<User>.from(
            json['admin'].map((itemJson) => User.fromJson(itemJson))),
        club:
            json['club'] != null ? PopulatedClub.fromJson(json['club']) : null,
        college: json['college'] != null
            ? PopulatedCollege.fromJson(json['college'])
            : null,
        festival: json['festival'] != null
            ? PopulatedFest.fromJson(json['festival'])
            : null,
        eventType: json['eventType'],
        eventStartDate: json['eventStartDate'],
        eventEndDate: json['eventEndDate'],
        location: json['location'],
        city: City.fromJson(json['city']),
        venue: City.fromJson(json['venue']),
        eventLink: json['eventLink'],
        views: json['views'],
        visibility: json['visibility'],
        takeRegistration: json['takeRegistration'],
        registrationPlace: json['registrationPlace'],
        registrationLink: json['registrationLink'],
        participation: json['participation'],
        registrationStartDate: json['registrationStartDate'],
        registrationEndDate: json['registrationEndDate'],
        minSizeTeam: json['minSizeTeam'],
        maxSizeTeam: json['maxSizeTeam'],
        registrationCharge: json['registrationCharge'],
        payment: json['payment'],
        registrationFee: json['registrationFee'],
        stages: json['stages'] != null
            ? List<Stage>.from(
                json['stages'].map((itemJson) => Stage.fromJson(itemJson)))
            : [],
        results: json['results'] != null
            ? List<Result>.from(
                json['results'].map((itemJson) => Result.fromJson(itemJson)))
            : [],
        description: json['description'],
        guidelines: List<Guideline>.from(
            json['guidelines'].map((itemJson) => Guideline.fromJson(itemJson))),
        partCertificate: json['partCertificate'],
        totalRewards: json['totalRewards'],
        rewards: json['rewards'] != null
            ? List<Reward>.from(
                json['rewards'].map((itemJson) => Reward.fromJson(itemJson)))
            : [],
        stepsDone: json['stepsDone'],
        verified: json['verified'],
        registerdTeamLead: json['registerdTeamLead'] != null
            ? List<String>.from(json['registerdTeamLead'])
            : [],
        createdAt: json['createdAt']);
  }

  DateTime get eventStartedAtDate => DateTime.parse(eventStartDate);
  DateTime get eventEndedAtDate => DateTime.parse(eventEndDate);
  DateTime get registrationStartedAtDate =>
      DateTime.parse(registrationStartDate);
  DateTime get registrationEndedAtDate => DateTime.parse(registrationEndDate);
  DateTime get createdAtDate => DateTime.parse(createdAt);
}

class Reward {
  final String id;
  final int reward;
  final String rank;
  final int money;
  final bool certificate;
  final String otherDetails;

  Reward(
      {required this.id,
      required this.reward,
      required this.rank,
      required this.money,
      required this.certificate,
      required this.otherDetails});

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['_id'],
      reward: json['reward'],
      rank: json['rank'],
      money: json['money'],
      certificate: json['certificate'],
      otherDetails: json['otherDetails'],
    );
  }
}

class Stage {
  final String id;
  final int round;
  final String roundTitle;
  final String startDate;
  final String endDate;
  final String description;
  final String roundType;
  final String link;
  final String eliminator;

  Stage(
      {required this.id,
      required this.round,
      required this.roundTitle,
      required this.startDate,
      required this.endDate,
      required this.description,
      required this.roundType,
      required this.link,
      required this.eliminator});

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      id: json['_id'],
      round: json['round'],
      roundTitle: json['roundTitle'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      description: json['description'],
      roundType: json['roundType'],
      link: json['link'],
      eliminator: json['eliminator'],
    );
  }
  DateTime get startedAtDate => DateTime.parse(startDate);
  DateTime get endedAtDate => DateTime.parse(endDate);
}

class Result {
  final String id;
  final int round;
  final String file;
  final String filename;

  Result(
      {required this.id,
      required this.round,
      required this.file,
      required this.filename});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'round': round,
      'file': file,
      'filename': filename,
    };
  }

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      id: json['_id'],
      round: json['round'],
      file: json['file'],
      filename: json['filename'],
    );
  }
}

class Guideline {
  final String guideline;

  Guideline({required this.guideline});

  factory Guideline.fromJson(Map<String, dynamic> json) {
    return Guideline(
      guideline: json['guideline'],
    );
  }
}

class EventItem {
  final String id;
  final String eventTitle;
  final String eventImg;
  final String eventType;
  final bool takeRegistration;
  final List<String> admin;
  final PopulatedClub? club;
  final PopulatedFest? fest;
  final PopulatedCollege? college;
  final int views;
  final String registrationEndDate;
  final String eventStartDate;
  final String totalRewards;
  final int stepsDone;
  final bool verified;

  EventItem(
      {required this.id,
      required this.eventTitle,
      required this.eventImg,
      required this.eventType,
      required this.takeRegistration,
      required this.admin,
      this.club,
      this.fest,
      this.college,
      required this.views,
      required this.registrationEndDate,
      required this.eventStartDate,
      required this.totalRewards,
      required this.stepsDone,
      required this.verified});

  factory EventItem.fromJson(Map<String, dynamic> json) {
    return EventItem(
        id: json['_id'],
        eventTitle: json['eventTitle'],
        eventImg: json['eventImg'],
        eventType: json['eventType'],
        takeRegistration: json['takeRegistration'],
        admin: List<String>.from(json['admin']),
        club:
            json['club'] != null ? PopulatedClub.fromJson(json['club']) : null,
        fest: json['festival'] != null
            ? PopulatedFest.fromJson(json['festival'])
            : null,
        college: json['college'] != null
            ? PopulatedCollege.fromJson(json['college'])
            : null,
        views: json['views'],
        registrationEndDate: json['registrationEndDate'],
        eventStartDate: json['eventStartDate'],
        totalRewards: json['totalRewards'],
        stepsDone: json['stepsDone'],
        verified: json['verified']);
  }

  factory EventItem.fromEvent(Event event) {
    return EventItem(
        id: event.id,
        eventTitle: event.eventTitle,
        eventImg: event.eventImg,
        eventType: event.eventType,
        takeRegistration: event.takeRegistration,
        admin: event.admin.map((user) => user.id).toList(),
        club: event.club,
        college: event.college,
        views: event.views,
        registrationEndDate: event.registrationEndDate,
        eventStartDate: event.eventStartDate,
        totalRewards: event.totalRewards,
        stepsDone: event.stepsDone,
        verified: event.verified);
  }
}
