import 'package:learningx_flutter_app/api/model/populated_model.dart';

class Session {
  final String id;
  final PopulatedClub club;
  final String channel;
  final String title;
  final String sessionImg;
  final String location;
  final String venue;
  final String sessionLink;
  final String storedLink;
  final String description;
  final String startTime;
  final int duration;

  Session(
      {required this.id,
      required this.club,
      required this.channel,
      required this.title,
      required this.sessionImg,
      required this.location,
      required this.venue,
      required this.sessionLink,
      required this.storedLink,
      required this.description,
      required this.startTime,
      required this.duration});

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['_id'],
      club: PopulatedClub.fromJson(json['club']),
      channel: json['channel'],
      title: json['title'],
      sessionImg: json['sessionImg'],
      location: json['location'],
      venue: json['venue'],
      sessionLink: json['sessionLink'],
      storedLink: json['storedLink'],
      description: json['description'],
      startTime: json['startTime'],
      duration: json['duration'],
    );
  }

  DateTime get startedAtDate => DateTime.parse(startTime);
}
