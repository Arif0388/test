import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/Screens/club/about/club_about_activity.dart';
import 'package:learningx_flutter_app/Screens/college/college_page.dart';
import 'package:learningx_flutter_app/Screens/event/event_info/event_info_page.dart';
import 'package:learningx_flutter_app/Screens/fest/fest_page.dart';
import 'package:learningx_flutter_app/Screens/home/home_page.dart';
import 'package:learningx_flutter_app/api/model/featured_ad_model.dart';

class AdvertisementCard extends StatelessWidget {
  final FeaturedAd ad;

  const AdvertisementCard({
    super.key,
    required this.ad,
  });

  @override
  Widget build(BuildContext context) {
    var title = "";
    var subTitle = "";
    var img = "";
    Widget page = const MyHomePage();
    if (ad.college != null) {
      title = ad.college!.collegeName;
      subTitle = ad.college!.city.address;
      img = ad.college!.collegeImg;
      page = CollegeActivity(
        id: ad.college!.id,
      );
    } else if (ad.fest != null) {
      title = ad.fest!.festName;
      subTitle = ad.fest!.college.collegeName;
      img = ad.fest!.festImg;
      page = CollegeFestActivity(id: ad.fest!.id);
    } else if (ad.event != null) {
      title = ad.event!.eventTitle;
      if (ad.event!.college != null) {
        subTitle = ad.event!.college!.collegeName;
      } else {
        subTitle = ad.event!.club!.clubName;
      }
      img = ad.event!.eventImg;
      page = EventInfoActivity(id: ad.event!.id);
    } else if (ad.club != null) {
      title = ad.club!.clubName;
      subTitle = "";
      img = ad.club!.clubImg;
      page = AboutClubScreen(clubId: ad.club!.id);
    }
    return Container(
      margin: const EdgeInsets.all(2),
      child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
          child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 60,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          image: DecorationImage(
                            image: NetworkImage(
                                img), // Replace with your image asset
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subTitle,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Visibility(
                                visible: false,
                                child: Text(
                                  ad.description,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  )))),
    );
  }
}
