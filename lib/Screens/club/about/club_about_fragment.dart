// import 'package:flutter/material.dart';
// import 'package:learningx_flutter_app/Screens/club/about/club_setup_screen.dart';
// import 'package:learningx_flutter_app/Screens/club/about/faqs_item.dart';
// import 'package:learningx_flutter_app/api/common/launch_url.dart';
// import 'package:learningx_flutter_app/api/model/club_model.dart';
// import 'package:learningx_flutter_app/api/utils/utils.dart';
//
// class ClubAboutFragment extends StatefulWidget {
//   final Club club;
//   final Widget page;
//   final bool isCollegeAdmin;
//   final bool isClubAdmin;
//   const ClubAboutFragment(
//       {super.key,
//       required this.club,
//       required this.page,
//       required this.isCollegeAdmin,
//       required this.isClubAdmin});
//
//   @override
//   State<ClubAboutFragment> createState() => _ClubAboutFragmentState();
// }
//
// class _ClubAboutFragmentState extends State<ClubAboutFragment> {
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//         child: Column(
//       children: [
//         widget.page,
//         Container(
//           color: Colors.white,
//           margin: const EdgeInsets.only(top: 2),
//           padding: const EdgeInsets.symmetric(horizontal: 8),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Padding(
//                 padding: EdgeInsets.only(left: 8.0, top: 8),
//                 child: Text(
//                   'Club Description',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color:  Color(0xFF2B3595),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   widget.club.description,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               const Divider(
//                 color: Color.fromARGB(255, 238, 238, 238),
//                 height: 4,
//               ),
//               const Padding(
//                 padding: EdgeInsets.only(left: 8.0, top: 8),
//                 child: Text(
//                   'Contact info',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color:  Color(0xFF2B3595),
//                   ),
//                 ),
//               ),
//               Padding(
//                   padding: const EdgeInsets.all(8),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Icon(Icons.mail_outline,
//                           size: 18, color: Colors.grey[700]),
//                       const SizedBox(width: 8),
//                       Text(
//                         widget.club.email,
//                         style: TextStyle(color: Colors.grey[700]),
//                       ),
//                     ],
//                   )),
//               if (widget.club.website.isNotEmpty)
//                 Padding(
//                     padding: const EdgeInsets.all(8),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Icon(Icons.link, size: 18, color: Colors.grey[700]),
//                         const SizedBox(width: 8),
//                         Flexible(
//                             child: GestureDetector(
//                                 onTap: () {
//                                   LaunchUrl.openUrl(widget.club.website);
//                                 },
//                                 child: Text(
//                                   widget.club.website,
//                                   style: const TextStyle(
//                                       color: Colors.blue,
//                                       overflow: TextOverflow.visible),
//                                 ))),
//                       ],
//                     )),
//               if (widget.club.linkedIn.isNotEmpty)
//                 Padding(
//                     padding: const EdgeInsets.all(8),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Image.asset(
//                           'assets/images/linkedin.png',
//                           width: 18,
//                           height: 18,
//                         ),
//                         const SizedBox(width: 8),
//                         Flexible(
//                             child: GestureDetector(
//                                 onTap: () {
//                                   LaunchUrl.openUrl(widget.club.linkedIn);
//                                 },
//                                 child: Text(
//                                   widget.club.linkedIn,
//                                   style: const TextStyle(
//                                       color: Colors.blue,
//                                       overflow: TextOverflow.visible),
//                                 ))),
//                       ],
//                     )),
//               if (widget.club.instagram.isNotEmpty)
//                 Padding(
//                     padding: const EdgeInsets.all(8),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Image.asset(
//                           'assets/images/instagram.png',
//                           width: 18,
//                           height: 18,
//                         ),
//                         const SizedBox(width: 8),
//                         Flexible(
//                             child: GestureDetector(
//                                 onTap: () {
//                                   LaunchUrl.openUrl(widget.club.instagram);
//                                 },
//                                 child: Text(
//                                   widget.club.instagram,
//                                   style: const TextStyle(
//                                       color: Colors.blue,
//                                       overflow: TextOverflow.visible),
//                                 ))),
//                       ],
//                     )),
//               Padding(
//                   padding: const EdgeInsets.all(8),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Icon(Icons.access_time,
//                           size: 18, color: Colors.grey[700]),
//                       const SizedBox(width: 8),
//                       Text(
//                         Utils.getDateString(
//                             DateTime.parse(widget.club.createdAt)),
//                         style: TextStyle(color: Colors.grey[700]),
//                       ),
//                     ],
//                   )),
//               const Divider(
//                 color: Color.fromARGB(255, 238, 238, 238),
//                 height: 4,
//               ),
//               if (widget.club.collegeStatus == "verified")
//                 const Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                       width: 8,
//                     ),
//                     Icon(
//                       Icons.verified,
//                       size: 15,
//                       color: Colors.blue,
//                     ),
//                     SizedBox(
//                       width: 8,
//                     ),
//                     Text("The club is Campus verified.")
//                   ],
//                 ),
//               if (widget.club.collegeStatus == "unverified" &&
//                   (widget.isCollegeAdmin || widget.isClubAdmin))
//                 const Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                       width: 8,
//                     ),
//                     Icon(
//                       Icons.verified_user_outlined,
//                       size: 15,
//                       color: Colors.grey,
//                     ),
//                     SizedBox(
//                       width: 8,
//                     ),
//                     Expanded(
//                         child: Text(
//                       "The club is not official Campus club. And this icon only seen to Campus admin and Club admin",
//                       overflow: TextOverflow.visible,
//                     ))
//                   ],
//                 ),
//               if (widget.club.college != null &&
//                   widget.club.collegeStatus == "rejected" &&
//                   (widget.isCollegeAdmin || widget.isClubAdmin))
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Image.asset(
//                       "assets/images/under_approval.jpg",
//                       height: 40,
//                     ),
//                     const SizedBox(
//                       width: 8,
//                     ),
//                     const Expanded(
//                         child: Text(
//                       "The club is under approval by Campus Admin. And To get approved your club kindly reach to campus Admin",
//                       overflow: TextOverflow.visible,
//                     ))
//                   ],
//                 ),
//               if (widget.club.learnings.isNotEmpty)
//                 const Divider(
//                   color: Color.fromARGB(255, 238, 238, 238),
//                   height: 4,
//                 ),
//               if (widget.club.learnings.isNotEmpty)
//                 const Padding(
//                   padding: EdgeInsets.only(left: 8.0, top: 8),
//                   child: Text(
//                     'What you\'ll learn',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color:  Color(0xFF2B3595),
//                     ),
//                   ),
//                 ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: ListView.builder(
//                   physics: const NeverScrollableScrollPhysics(),
//                   shrinkWrap: true,
//                   itemCount: widget.club.learnings.length,
//                   itemBuilder: (context, index) {
//                     final learning = widget.club.learnings[index];
//                     if (learning.learning.isNotEmpty) {
//                       return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 4),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Icon(Icons.check_box_outlined),
//                               const SizedBox(
//                                 width: 8,
//                               ),
//                               Flexible(child: Text(learning.learning))
//                             ],
//                           ));
//                     }
//                     return const SizedBox.shrink();
//                   },
//                 ),
//               ),
//               const Divider(
//                 color: Color.fromARGB(255, 238, 238, 238),
//                 height: 4,
//               ),
//               if (widget.club.faqs!.isNotEmpty)
//                 const Padding(
//                   padding: EdgeInsets.only(left: 8.0, top: 8),
//                   child: Text(
//                     'Frequently asked questions',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color:  Color(0xFF2B3595),
//                     ),
//                   ),
//                 ),
//               const SizedBox(
//                 height: 8,
//               ),
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: widget.club.faqs!.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   return AccordionWidget(
//                     question: widget.club.faqs![index].question,
//                     answer: widget.club.faqs![index].answer,
//                   );
//                 },
//               ),
//               const SizedBox(
//                 height: 16,
//               ),
//               if (widget.isClubAdmin && widget.club.learnings.isEmpty)
//                 ClubSetupScreen(
//                   club: widget.club,
//                 )
//             ],
//           ),
//         ),
//       ],
//     ));
//   }
// }

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../api/model/club_model.dart';

class ClubAboutFragment extends StatefulWidget {
  final Club club;
  final Widget page;
  final bool isCollegeAdmin;
  final bool isClubAdmin;
  const ClubAboutFragment(
      {super.key,
        required this.club,
        required this.page,
        required this.isCollegeAdmin,
        required this.isClubAdmin});

  @override
  State<ClubAboutFragment> createState() => _ClubAboutFragmentState();
}

class _ClubAboutFragmentState extends State<ClubAboutFragment> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius:40,
                  backgroundImage:AssetImage('assets/images/Club Logo.png'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("TechInnovate Club", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w400)),
                        const SizedBox(width:10),
                        const Icon(Icons.verified, color: Color(0xff4F46E5), size: 18),
                      ],
                    ),
                    Text("🏛️ NIET, Noida", style: GoogleFonts.poppins(fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical:6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text("Science & Technology", style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xff4F46E5))),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical:6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text("Active", style: GoogleFonts.poppins(fontSize: 11, color: Colors.green)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("Request to Join", style: GoogleFonts.poppins(color: Colors.white)),
              ),
            ),
            const SizedBox(height:10),
            tabWidget(),
            Text("What You'll Learn", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.code, color: Color(0xff4F46E5)),
                        const SizedBox(height: 8),
                        Text("Technical Skills", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        Text("Practical coding and development experience", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 11)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.groups, color: Color(0xff4F46E5)),
                        const SizedBox(height: 8),
                        Text("Teamwork", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        Text("Collaborative project experience", textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Text("Activities", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 10),
            activityItem("Weekly Coding Workshops", Icons.code),
            activityItem("Monthly Hackathons", Icons.bolt),
            activityItem("Tech Talks & Seminars", Icons.record_voice_over),

            const SizedBox(height: 20),


            Text("Contact Information", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 10),
            infoRow(Icons.email, "techinnovate@stanford.edu"),
            infoRow(Icons.calendar_today, "Established 2020"),

            const SizedBox(height: 10),

            const Row(
              children: [
                Icon(FontAwesomeIcons.github),
                SizedBox(width: 20),
                Icon(FontAwesomeIcons.linkedin),
                SizedBox(width: 20),
                Icon(FontAwesomeIcons.instagram),
              ],
            )
          ],
        ),
      );
  }

  Widget activityItem(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xff4F46E5)),
          const SizedBox(width: 10),
          Text(title, style: GoogleFonts.poppins(fontSize: 13)),
        ],
      ),
    );
  }

  Widget infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16,color:const Color(0xff4B5563)),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.poppins(fontSize: 13)),
        ],
      ),
    );
  }
}

Widget tabWidget(){
  return DefaultTabController(
    length: 2,
    child: Column(
      children: [
        TabBar(
          labelColor:const Color(0xff4F46E5),
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          indicatorColor: const Color(0xff4F46E5),
          tabs: const [
            Tab(text: "About"),
            Tab(text: "Events"),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height:170,
          child: TabBarView(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("About Us", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(
                      "TechInnovate is a dynamic community of tech enthusiasts, innovators, and problem-solvers. "
                          "We focus on emerging technologies, hands-on projects, and fostering collaboration among students passionate about technology.",
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Upcoming Events", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection:Axis.horizontal,
                      child: Row(
                        mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                        children: [
                          eventCard("AI Hackathon", "Build an AI app in 24 hours", "12 Aug, 2025"),
                          const SizedBox(width:10),
                          eventCard("Flutter Seminar", "Learn Flutter 2025 updates", "20 Aug, 2025"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget eventCard(String title, String desc, String date) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 4),
        Text(desc, style: GoogleFonts.poppins(fontSize: 12)),
        const SizedBox(height: 4),
        Text("📅 $date", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
      ],
    ),
  );
}
