import 'package:learningx_flutter_app/api/model/college_model.dart';
import 'package:learningx_flutter_app/api/model/event_model.dart';
import 'package:learningx_flutter_app/api/model/fest_model.dart';
import 'package:learningx_flutter_app/api/model/populated_model.dart';

class FeaturedAd {
  final String id;
  final College? college;
  final Fest? fest;
  final EventItem? event;
  final PopulatedClub? club;
  final String description;
  final bool sponsered;

  FeaturedAd(
      {required this.id,
      this.college,
      this.fest,
      this.event,
      this.club,
      required this.description,
      required this.sponsered});

  factory FeaturedAd.fromJson(Map<String, dynamic> json) {
    return FeaturedAd(
      id: json['_id'],
      college:
          json['college'] != null ? College.fromJson(json['college']) : null,
      fest: json['fest'] != null ? Fest.fromJson(json['fest']) : null,
      event: json['event'] != null ? EventItem.fromJson(json['event']) : null,
      club: json['club'] != null ? PopulatedClub.fromJson(json['club']) : null,
      description: json['description'],
      sponsered: json['sponsered'],
    );
  }
}
