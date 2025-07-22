// import 'dart:collection';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:learningx_flutter_app/Screens/common/qr_creator.dart';
// import 'package:learningx_flutter_app/Screens/event/event_fragment_page.dart';
// import 'package:learningx_flutter_app/Screens/event/form/event_form_page.dart';
// import 'package:learningx_flutter_app/Screens/fest/bottom_sheet_fest_info.dart';
// import 'package:learningx_flutter_app/Screens/fest/fest_about_fragment.dart';
// import 'package:learningx_flutter_app/api/model/fest_model.dart';
// import 'package:learningx_flutter_app/api/provider/fest_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class CollegeFestActivity extends ConsumerStatefulWidget {
//   final String id;
//   const CollegeFestActivity({super.key, required this.id});
//
//   @override
//   ConsumerState<CollegeFestActivity> createState() =>
//       _CollegeFestActivityState();
// }
//
// class _CollegeFestActivityState extends ConsumerState<CollegeFestActivity> {
//   int _selectedFragmentIndex = 0;
//   String _currentUserId = "";
//   bool isAdmin = false;
//   var isAuthenticated = false;
//
//   @override
//   void initState() {
//     _loadCurrentUser();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _refresh();
//     });
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   _loadCurrentUser() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _currentUserId = prefs.getString("id") ?? "";
//       isAuthenticated = prefs.getBool("isLoggedIn") ?? false;
//     });
//   }
//
//   void _onFragmentChanged(int index) {
//     setState(() {
//       _selectedFragmentIndex = index;
//     });
//   }
//
//   Future<void> _refresh() async {
//     try {
//       final festNotifier = ref.read(selectedFestProvider(widget.id).notifier);
//       if (festNotifier.isLoading) {
//         // Already fetching or fetched, no need to refresh
//         return;
//       }
//       // Not fetched, start fetching
//       await festNotifier.fetchFest(widget.id);
//     } catch (e) {
//       // Handle error and navigate to the error page
//       context.go("/error");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final festData = ref.watch(selectedFestProvider(widget.id));
//
//     setState(() {
//       isAdmin = festData.admin.any((item) => item.id == _currentUserId);
//     });
//
//     final List<Widget> fragments = [
//       EventFragmentPage(
//         query: isAdmin
//             ? "?festival=${widget.id}"
//             : "?festival=${widget.id}&stepsDone=6",
//         page: _buildInfoSection(festData),
//       ),
//       FestAboutFragment(
//         fest: festData,
//         page: _buildInfoSection(festData),
//       ),
//     ];
//
//     final List<Widget> appBarActions = [
//       if (!isAuthenticated)
//         OutlinedButton(
//             onPressed: () {
//               context.go("/apps");
//             },
//             child: const Text("Sign In")),
//       if (isAuthenticated)
//         IconButton(
//           icon: const Icon(Icons.more_horiz),
//           onPressed: () {
//             final BottomSheetFestInfo sheetFestInfo = BottomSheetFestInfo();
//             sheetFestInfo.showBottomSheet(
//                 context, festData, isAdmin);
//           },
//         ),
//       const SizedBox(
//         width: 8,
//       )
//     ];
//     return Scaffold(
//         appBar: AppBar(
//           title: Text(festData.festName),
//           backgroundColor: const Color.fromARGB(255, 211, 232, 255),
//           titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
//           elevation: 0,
//           actions: appBarActions,
//         ),
//         body: fragments[_selectedFragmentIndex]);
//   }
//
//   Widget _buildInfoSection(Fest festData) {
//     void shareText() {
//       String text =
//           "to see the details of events hosted by ${festData.festName} !\n\n https://clubchat.live/club/fest/${festData.id}";
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//             builder: (context) => QrCreator(
//                   appBarText: "Share Festival",
//                   sharedText: text,
//                   url: "https://clubchat.live/club/fest/${festData.id}",
//                   imageUrl: festData.festImg,
//                 )),
//       );
//     }
//
//     return Container(
//       color: Colors.white,
//       margin: const EdgeInsets.all(0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Image.network(
//             festData.festImg,
//             fit: BoxFit.cover,
//             width: double.infinity,
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 8, top: 8, bottom: 4),
//             child: Text(
//               festData.festName,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 4, bottom: 8),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.account_balance),
//                 const SizedBox(width: 8),
//                 Flexible(
//                   child: Text(
//                     festData.college.collegeName,
//                     textAlign: TextAlign.center,
//                   ),
//                 )
//               ],
//             ),
//           ),
//           if (isAdmin)
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       onPressed: () {
//                         Map<String, String> formData = HashMap();
//                         formData['festId'] = widget.id;
//                         formData['collegeId'] = festData.college.id;
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) =>
//                                   EventFormPage(formData: formData)),
//                         );
//                       },
//                       icon: const Icon(Icons.event_available_outlined,
//                           color: Colors.blue),
//                       label: const Text('Create Event'),
//                       style: OutlinedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         padding: const EdgeInsets.all(12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                         foregroundColor: Colors.blue,
//                         side: const BorderSide(
//                             color: Colors.blue), // Set the border color here
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8), // Space between buttons
//                   Expanded(
//                     child: OutlinedButton.icon(
//                       onPressed: () {
//                         shareText();
//                       },
//                       icon: const Icon(
//                         Icons.share_outlined,
//                         color: Colors.blue,
//                       ),
//                       label: const Text('Share Fest'),
//                       style: OutlinedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         padding: const EdgeInsets.all(12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                         foregroundColor: Colors.blue,
//                         side: const BorderSide(
//                             color: Colors.blue), // Set the border color here
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           if (!isAdmin)
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//               child: SizedBox(
//                 width: double.infinity, // Full width button
//                 child: OutlinedButton.icon(
//                   onPressed: () {
//                     shareText();
//                   },
//                   icon: const Icon(
//                     Icons.share_outlined,
//                     color: Colors.blue,
//                   ),
//                   label: const Text('Share Fest'),
//                   style: OutlinedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     padding: const EdgeInsets.all(12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                     foregroundColor: Colors.blue,
//                     side: const BorderSide(
//                         color: Colors.blue), // Set the border color here
//                   ),
//                 ),
//               ),
//             ),
//           const Divider(
//             color: Color.fromARGB(255, 238, 238, 238),
//             height: 4,
//           ),
//           const SizedBox(height: 4),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               const SizedBox(width: 8),
//               _buildButton('Event', 0),
//               const SizedBox(width: 8),
//               _buildButton('About', 1),
//             ],
//           ),
//           const SizedBox(height: 4),
//           const Divider(
//             color: Color.fromARGB(255, 238, 238, 238),
//             height: 4,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildButton(String text, int index) {
//     bool isActive = _selectedFragmentIndex == index;
//
//     return isActive
//         ? ElevatedButton(
//             onPressed: () {
//               _onFragmentChanged(index);
//             },
//             style: ButtonStyle(
//               textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 13)),
//               backgroundColor: WidgetStateProperty.all(
//                   Colors.blue), // Active button background color
//               foregroundColor: WidgetStateProperty.all(
//                   Colors.white), // Active button text color
//               shape: WidgetStateProperty.all(
//                 RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//               ),
//             ),
//             child: Text(text),
//           )
//         : OutlinedButton(
//             onPressed: () {
//               _onFragmentChanged(index);
//             },
//             style: ButtonStyle(
//               textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 13)),
//               foregroundColor: WidgetStateProperty.all(Colors.black),
//               side: WidgetStateProperty.all(const BorderSide(
//                   color: Colors.white)), // Inactive button border color
//               shape: WidgetStateProperty.all(
//                 RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//               ),
//             ),
//             child: Text(text),
//           );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/provider/fest_provider.dart';

class CollegeFestActivity extends ConsumerStatefulWidget {
  final String id;
  const CollegeFestActivity({super.key,required this.id});

  @override
  ConsumerState<CollegeFestActivity> createState() => _CollegeFestActivityState();
}

class _CollegeFestActivityState extends ConsumerState<CollegeFestActivity> {
  int _selectedFragmentIndex = 0;
  String _currentUserId = "";
  bool isAdmin = false;
  var isAuthenticated = false;

  @override
  void initState() {
    _loadCurrentUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString("id") ?? "";
      isAuthenticated = prefs.getBool("isLoggedIn") ?? false;
    });
  }

  void _onFragmentChanged(int index) {
    setState(() {
      _selectedFragmentIndex = index;
    });
  }

  Future<void> _refresh() async {
    try {
      final festNotifier = ref.read(selectedFestProvider(widget.id).notifier);
      if (festNotifier.isLoading) {
        // Already fetching or fetched, no need to refresh
        return;
      }
      // Not fetched, start fetching
      await festNotifier.fetchFest(widget.id);
    } catch (e) {
      // Handle error and navigate to the error page
      context.go("/error");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color(0xffF9FAFB),
      appBar:AppBar(
        leading:IconButton(onPressed:(){}, icon:const Icon(Icons.arrow_back_ios_rounded,color:Color(0xff585858),)),
        title: Text('UDBHAV',style:GoogleFonts.nunito(fontWeight:FontWeight.w700,color:const Color(0xff3C393C))),
        actions:[
          IconButton(onPressed: (){}, icon:const Icon(Icons.more_horiz)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/images/frame1.jpg',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  width:MediaQuery.of(context).size.width,
                  height:MediaQuery.of(context).size.height/4.3,
                  color:Colors.black26,
                ),
                SizedBox(
                  width:MediaQuery.of(context).size.width,
                  height:186,
                  child:Column(
                    crossAxisAlignment:CrossAxisAlignment.start,
                    mainAxisAlignment:MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left:10),
                        child: Text('UDBHAV',style:GoogleFonts.nunito(fontWeight:FontWeight.w700,color:const Color(0xffF8F8F8),fontSize:24)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:10),
                        child: Text('Hosted by MNNIT Allahabad',style:GoogleFonts.nunito(fontWeight:FontWeight.w500,color:const Color(0xffF8F8F8),fontSize:12)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:10),
                        child: Text('MNNIT Tech Club',style:GoogleFonts.nunito(fontWeight:FontWeight.w600,color:const Color(0xffF8F8F8),fontSize:16)),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined,color:Colors.white,size:16,),
                          Text('15 - 18 July 2025',style:GoogleFonts.nunito(fontWeight:FontWeight.w500,color:const Color(0xffFFFFFF),fontSize:11)),
                          const SizedBox(width:10),
                          const Icon(Icons.remove_red_eye,color:Colors.white,size:16,),
                          Text('1.5K Views',style:GoogleFonts.nunito(fontWeight:FontWeight.w500,color:const Color(0xffFFFFFF),fontSize:11)),
                          const SizedBox(width:7),
                          Container(
                            padding:const EdgeInsets.all(5),
                            width:80,
                            height:32,
                            decoration:BoxDecoration(
                              borderRadius:BorderRadius.circular(8),
                              color:const Color(0xff4361EE),
                            ),
                            child:Row(
                              children: [
                                const Icon(Icons.share_outlined,size:16,color:Color(0xffFFFFFF),),
                                const SizedBox(width:6),
                                Text('Share',style:GoogleFonts.nunito(fontWeight: FontWeight.w600,color:const Color(0xffFFFFFF),fontSize:12))
                              ],
                            ),
                          ),
                          const SizedBox(width:12),
                          Container(
                            padding:const EdgeInsets.all(5),
                            width:98,
                            height:32,
                            decoration:BoxDecoration(
                              borderRadius:BorderRadius.circular(8),
                              color:const Color(0xff4361EE),
                            ),
                            child:Row(
                              children: [
                                const Icon(Icons.language,size:16,color:Color(0xffFFFFFF),),
                                const SizedBox(width:5),
                                Text('Visit Website',style:GoogleFonts.nunito(fontWeight: FontWeight.w600,color:const Color(0xffFFFFFF),fontSize:10))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("About the Fest", style: GoogleFonts.nunito(fontWeight: FontWeight.w600,fontSize:16)),
                  const SizedBox(height: 6),
                  Text(
                    "Incididunt Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt...",
                    style: GoogleFonts.montserrat(fontSize: 12,fontWeight:FontWeight.w500,color:Color(0xff9F9F9F)),
                  ),
                  const SizedBox(height: 4),
                  Text("Read More >", style: GoogleFonts.nunito(color: Color(0xff4361EE),fontWeight:FontWeight.w600)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(FontAwesomeIcons.instagram,size:15,color:Color(0xff4B5563),),
                      const SizedBox(width: 15),
                      const Icon(FontAwesomeIcons.linkedin, size: 15,color:Color(0xff4B5563)),
                      const SizedBox(width: 15),
                      const Icon(FontAwesomeIcons.message, size: 15,color:Color(0xff4B5563)),
                      const SizedBox(width: 15),
                      const Icon(FontAwesomeIcons.link, size: 15,color:Color(0xff4B5563)),
                      const SizedBox(width:90),
                      const Icon(Icons.location_on, size: 16),
                      Text("MNNIT Cricket Ground", style:GoogleFonts.nunito(fontSize:12,color: const Color(0xff4B5563),fontWeight:FontWeight.w400)),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text("Events", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),

            eventCard(
              imageUrl: 'assets/images/frame2.jpg',
              tag: 'Popular',
              badge: 'Free!',
              club: 'Dance Club',
              title: 'Dance complex',
              date: '09 Mar 2025',
              college: 'Noida Institute of Engineering and Technology',
              footer: 'Certificates and Cash Prizes',
              type: 'Dance Army',
            ),

            eventCard(
              imageUrl: 'assets/images/frame3.jpg',
              tag: '',
              badge: 'Free!',
              club: 'Robo Race Club',
              title: 'Robo Race',
              date: '09 Mar 2025',
              college: 'Noida Institute of Engineering and Technology',
              footer: 'Certificates',
              type: 'Robo Army',
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


Widget eventCard(
    {
      required String imageUrl,
      required String tag,
      required String badge,
      required String club,
      required String title,
      required String date,
      required String college,
      required String type,
      required String footer
    })
{
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
            ),
            if(tag.isNotEmpty)
              Positioned(
                bottom:60,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(color: Colors.blue,
                    borderRadius: BorderRadius.only(topRight:Radius.circular(15),bottomRight:Radius.circular(15)),
                  ),
                  child: Text(tag, style:GoogleFonts.montserrat(fontWeight:FontWeight.w600,color:const Color(0xffFFFFFF),fontSize:11)),
                ),
              ),
            Positioned(
              bottom:30,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(color: Colors.green,
                  borderRadius: BorderRadius.only(topRight:Radius.circular(15),bottomRight:Radius.circular(15)),
                ),
                child: Text(badge, style:GoogleFonts.montserrat(fontWeight:FontWeight.w600,color:const Color(0xffFFFFFF),fontSize:11)),
              ),
            ),
            Positioned(
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(bottomLeft:Radius.circular(14),bottomRight:Radius.circular(14)),
                ),
                child: Text(club, style:GoogleFonts.montserrat(fontWeight:FontWeight.w700,fontSize:11,color:Colors.white)),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:MainAxisAlignment.spaceBetween,
                children: [
                  Text(type, style: GoogleFonts.montserrat(fontSize: 12, fontWeight:FontWeight.w500,color: const Color(0xff565656))),
                  Row(
                    children: [
                      const Icon(FontAwesomeIcons.clock, size: 14),
                      const SizedBox(width: 5),
                      Text(date, style: GoogleFonts.poppins(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(title, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700,color:const Color(0xff3C393C))),
              const SizedBox(height: 2),
              Text(college, style: GoogleFonts.montserrat(fontSize: 11,fontWeight:FontWeight.w500,color:const Color(0xff9F9F9F))),
              const SizedBox(height: 6),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(FontAwesomeIcons.trophy, size: 14,color:Color(0xffAFAFAF),),
                  const SizedBox(width:10,),
                  Text(footer, style: GoogleFonts.montserrat(fontSize: 11,fontWeight:FontWeight.w500,color:const Color(0xff565656))),
                  const Spacer(),
                  const Icon(Icons.bar_chart, size: 14,color:Color(0xffAFAFAF),),
                  const SizedBox(width: 3),
                  Text("4.3k",style: GoogleFonts.montserrat(fontSize: 11,fontWeight:FontWeight.w500,color:const Color(0xff565656))),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

