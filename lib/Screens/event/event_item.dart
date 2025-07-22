// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:learningx_flutter_app/Style/custom_style.dart';
// import 'package:learningx_flutter_app/api/model/event_model.dart';
// import 'package:learningx_flutter_app/api/utils/utils.dart';
//
// class EventItemCard extends StatelessWidget {
//   final EventItem event;
//   final Function? onRemove;
//   final bool isNietCollegeAdmin;
//   const EventItemCard(
//       {super.key,
//       required this.event,
//       this.onRemove,
//       required this.isNietCollegeAdmin});
//
//   @override
//   Widget build(BuildContext context) {
//     final random = Random();
//     var hostedBy = "";
//     var lastDate = "";
//     if (event.college != null) {
//       hostedBy = event.college!.collegeName;
//     } else {
//       hostedBy = event.club!.clubName;
//     }
//
//     if (event.takeRegistration) {
//       lastDate = event.registrationEndDate;
//     } else {
//       lastDate = event.eventStartDate;
//     }
//
//     return GestureDetector(
//       onTap: () {
//         context.push("/events/${event.id}", extra: onRemove);
//       },
//       child: Card(
//         color: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(4),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Stack(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(4),
//                     child: event.eventImg ==
//                             "https://learningx-s3.s3.ap-south-1.amazonaws.com/image_850_315.png"
//                         ? Container(
//                             padding: const EdgeInsets.all(16),
//                             height: 150,
//                             color: DefaultImageColors
//                                 .randomColor[random.nextInt(6)],
//                             alignment: Alignment.center,
//                             child: Text(
//                               event.eventTitle,
//                               textAlign: TextAlign.center,
//                               style: const TextStyle(
//                                   fontSize: 24,
//                                   color: Color.fromARGB(255, 56, 56, 56),
//                                   fontWeight: FontWeight.bold),
//                             ),
//                           )
//                         : Image.network(
//                             event
//                                 .eventImg, // Replace with your actual image path
//                             width: double.infinity,
//                             height: 150,
//                             fit: BoxFit.cover,
//                           ),
//                   ),
//                   if (isNietCollegeAdmin)
//                     Positioned(
//                       top: 8,
//                       right: 8,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: event.verified
//                               ? Colors.green.withOpacity(0.8)
//                               : Colors.orange.withOpacity(0.8),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               event.verified
//                                   ? Icons.verified
//                                   : Icons.hourglass_empty,
//                               color: Colors.white,
//                               size: 16,
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               event.verified ? "Approved" : "In Review",
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   if (event.college != null &&
//                       (event.club != null || event.fest != null))
//                     Positioned(
//                       top: 8,
//                       left: 8,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.blue.withOpacity(0.8),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             if (event.club != null)
//                               const Icon(
//                                 Icons.groups_2_outlined,
//                                 color: Colors.white,
//                                 size: 16,
//                               ),
//                             if (event.club == null && event.fest != null)
//                               Padding(
//                                 padding: const EdgeInsets.only(left: 4),
//                                 child: Image.asset(
//                                   'assets/icons/fest_icon_white.png',
//                                   width: 16,
//                                   height: 16,
//                                 ),
//                               ),
//                             const SizedBox(width: 4),
//                             Text(
//                               event.club != null
//                                   ? event.club!.clubName
//                                   : event.fest!.festName,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 event.eventTitle,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 15,
//                   color: Colors.black,
//                 ),
//               ),
//               Text(
//                 hostedBy,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   color: Colors.black,
//                 ),
//               ),
//               const SizedBox(height: 6),
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.access_time,
//                     size: 18,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     Utils.getDateString(DateTime.parse(lastDate)),
//                     style: const TextStyle(
//                       fontSize: 13,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 6),
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.bar_chart,
//                     size: 18,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     '${event.views} impressions',
//                     style: const TextStyle(
//                       fontSize: 13,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 6),
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.emoji_events_outlined,
//                     size: 18,
//                   ),
//                   const SizedBox(width: 8),
//                   Flexible(
//                     child: Text(
//                       event.eventType == "contest" ? event.totalRewards : "N/A",
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                   Container(
//                     margin: const EdgeInsets.only(left: 24),
//                     decoration: BoxDecoration(
//                       color: event.stepsDone != 6
//                           ? Colors.red
//                           : event.eventType == "contest"
//                               ? Colors.blue
//                               : event.eventType == "entertainment"
//                                   ? Colors.green
//                                   : Colors.orange,
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                     padding: const EdgeInsets.symmetric(horizontal: 8),
//                     child: Text(
//                       event.stepsDone != 6
//                           ? "Not Completed"
//                           : event.eventType == "contest"
//                               ? "Contest"
//                               : event.eventType == "entertainment"
//                                   ? "Non-Contest"
//                                   : "Workshop",
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                   )
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/Style/custom_style.dart';
import 'package:learningx_flutter_app/api/model/event_model.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';

class EventItemCard extends StatelessWidget {
  final EventItem event;
  final Function? onRemove;
  final bool isNietCollegeAdmin;
  const EventItemCard({
    super.key,
    required this.event,
    this.onRemove,
    required this.isNietCollegeAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final random = Random();
    var hostedBy = event.college?.collegeName ?? event.club!.clubName;
    var lastDate = event.takeRegistration
        ? event.registrationEndDate
        : event.eventStartDate;

    bool isFree = event.totalRewards.toLowerCase().contains("free") || event.totalRewards == "0";

    return GestureDetector(
      onTap: () {
        context.push("/events/${event.id}", extra: onRemove);
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: event.eventImg ==
                      "https://learningx-s3.s3.ap-south-1.amazonaws.com/image_850_315.png"
                      ? Container(
                    padding: const EdgeInsets.all(16),
                    height: 160,
                    color: DefaultImageColors.randomColor[random.nextInt(6)],
                    alignment: Alignment.center,
                    child: Text(
                      event.eventTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        color: Color.fromARGB(255, 56, 56, 56),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  )
                      : Image.network(
                    event.eventImg,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),

                // Club/Fest Label (Top-right)
                if (event.club != null || event.fest != null)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event.club?.clubName ?? event.fest!.festName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Popular & Free tags (Top-left)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((event.views) > 3000) // Popular condition (dynamic)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Popular',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isFree) // Free condition
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Free!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Verification status (unchanged)
                if (isNietCollegeAdmin)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: event.verified
                            ? Colors.green.withOpacity(0.8)
                            : Colors.orange.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            event.verified ? Icons.verified : Icons.hourglass_empty,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.verified ? "Approved" : "In Review",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.eventTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                      )),
                  const SizedBox(height: 4),
                  Text(
                    hostedBy,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text(
                        Utils.getDateString(DateTime.parse(lastDate)),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.emoji_events_outlined, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.eventType == "contest"
                              ? event.totalRewards
                              : "Certificates and Cash Prizes",
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.bar_chart, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${event.views ~/ 1000}k',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
