
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/common/launch_url.dart';
import '../../../api/model/event_model.dart';
import '../../../api/model/event_team_model.dart';
import '../../../api/provider/college_provider.dart';
import '../../../api/provider/event_feed_provider.dart';
import '../../../api/provider/event_manage_provider.dart';
import '../../../api/provider/event_provider.dart';
import '../../common/qr_creator.dart';
import '../../common/unauth_alert_dialog.dart';
import '../comment/event_comment_page.dart';
import '../event_info/bottom_sheet_event_info.dart';
import '../event_ticket.dart';
import '../registration_form.dart';

class EventInfoActivity extends ConsumerStatefulWidget {
  final String id;
  final Function? onRemove;
  const EventInfoActivity({super.key, required this.id, this.onRemove});

  @override
  ConsumerState<EventInfoActivity> createState() => _EventInfoActivity();
}

class _EventInfoActivity extends ConsumerState<EventInfoActivity> {
  bool isRegistered = false ;
  bool isReistrationOpen = true;
  var isAdmin = false;
  var isAuthenticated = false;
  var isTeamVerified = false;
  EventTeam? registeredTeam;
  String _currentUserId = "";
  String _collegeId = "";
  final random = Random();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  List rules = [
    "Use of AI tools not allowed",
    "Arrive 30 minutes before event starts",
    "Carry college ID and registration proof",
    "Plagiarism or cheating leads to disqualification",
  ];

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString("id") ?? "";
    _collegeId = prefs.getString("college") ?? "";

    Map<String, dynamic> map = HashMap();
    map['event'] = widget.id;
    map['user'] = _currentUserId;

    // Fetch the registered team status outside of setState
    final eventCurrentTeam = await ref.read(fetchRegisteredTeam(map).future);

    // Update the state with the result
    setState(() {
      isAuthenticated = prefs.getBool("isLoggedIn") ?? false;
      if (eventCurrentTeam.isNotEmpty) {
        isRegistered = true;
        registeredTeam = eventCurrentTeam[0];
        if (eventCurrentTeam[0].status == "verified") {
          isTeamVerified = true;
        }
      } else {
        isRegistered = false;
      }
    });
  }

  void checkRegistration(DateTime endDate) {
    DateTime currentDateTime = DateTime.now();

    if (endDate.isBefore(currentDateTime)) {
      setState(() {
        isReistrationOpen = false;
      });
    }
  }

  void registrationFilled(EventTeam team) {
    setState(() {
      isRegistered = true;
      registeredTeam = team;
      if (team.status == "verified") {
        isTeamVerified = true;
      }
    });
  }

  void removeEvent(String eventId) {
    ref.read(eventFeedProvider(_collegeId).notifier).removeEvent(eventId);
  }

  Future<void> _refresh() async {
    await ref.refresh(selectedEventProvider(widget.id).future);
  }

  Future<void> updateEvent(bool isVerified) async {
    Map<String, dynamic> data = HashMap();
    data['verified'] = isVerified;
    data['_id'] = widget.id;
    await ref
        .read(eventManageProvider(widget.id).notifier)
        .updateEventApi(context, data);
    await _refresh();
  }


  @override
  Widget build(BuildContext context) {
    final eventAsyncValue = ref.watch(selectedEventProvider(widget.id));
    return eventAsyncValue.when(
      data: (eventData) {
        checkRegistration(eventData.registrationEndedAtDate);
        isAdmin = eventData.admin.any((item) => item.id == _currentUserId);

        var isNietCollegeAdmin = false;

        if (eventData.college != null) {
          final collegeData =
          ref.watch(selectedCollegeProvider(eventData.college!.id));

          if (eventData.college!.id == dotenv.env['NIET_COLLEGE_ID']) {
            setState(() {
              isNietCollegeAdmin =
                  collegeData.admin.any((item) => item.id == _currentUserId);
            });
          }
        }

        void shareText(Event event) {
          String text = "to register event named ${event.eventTitle} !\n\n https://clubchat.live/events";
          // String text = "to register event named ${event.eventTitle} !\n\n https://clubchat.live/events/${event.id}";
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => QrCreator(
                  appBarText: "Share Event",
                  sharedText: text,
                  url: "https://clubchat.live/events/${event.id}",
                  imageUrl: event.eventImg,
                )),
          );
        }

        final List<Widget> appBarActions = [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              shareText(eventData);
            },
          ),
          if (!isAuthenticated)
            OutlinedButton(
                onPressed: () {
                  context.go("/apps");
                },
                child: const Text("Sign In")),
          if (isAuthenticated)
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {
                final BottomSheetEventInfo sheetEventInfo =
                BottomSheetEventInfo();
                sheetEventInfo.showBottomSheet(context, eventData, isAdmin,
                    isNietCollegeAdmin, widget.onRemove, updateEvent);
              },
            ),
          const SizedBox(
            width: 8,
          )
        ];
        Future<dynamic> handleEventChat() {
          return Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EventCommentActivity(
                  event: eventData,
                )),
          );
        }

        Future<dynamic> handleRegisterBtn() {
          if (eventData.registrationPlace == "on") {
            return Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EventRegisterForm(
                      event: eventData, onRegistration: registrationFilled)),
            );
          } else {
            return LaunchUrl.openUrl(eventData.registrationLink);
          }
        }

        var hostLink = "/home";
        var hostedBy = "";
        var hostImg =
            "https://learningx-s3.s3.ap-south-1.amazonaws.com/image_2_1.png";
        var hostEmail = "";
        var hostCollege = "";
        var teamSize = "individual";
        var payment = "Free";
        if (eventData.club != null) {
          hostLink = "/club/about/${eventData.club!.id}";
          hostedBy = eventData.club!.clubName;
          hostImg = eventData.club!.clubImg;
          hostEmail = eventData.club!.email;
          if (eventData.college != null) {
            hostCollege = eventData.college!.collegeName;
          }
        } else if (eventData.festival != null) {
          hostLink = "/club/fest/${eventData.festival!.id}";
          hostedBy = eventData.festival!.festName;
          hostImg = eventData.festival!.festImg;
          hostEmail = eventData.festival!.email;
          hostCollege = eventData.college!.collegeName;
        } else if (eventData.college != null) {
          hostLink = "/college/${eventData.college!.id}";
          hostedBy = eventData.college!.collegeName;
          hostImg = eventData.college!.collegeImg;
          hostEmail = eventData.college!.email;
        }
        if (eventData.participation == "team") {
          teamSize =
          "${eventData.minSizeTeam} - ${eventData.maxSizeTeam} members";
        }
        if (eventData.registrationCharge == "paid") {
          payment = "${eventData.registrationFee} ${eventData.payment}";
        }

        return Scaffold(
          appBar:AppBar(
            backgroundColor: const Color.fromARGB(255, 211, 232, 255),
            title:Text(eventData.eventTitle,style:GoogleFonts.poppins(fontSize:17),),
            actions: appBarActions,
          ),
          body:SingleChildScrollView(
            scrollDirection:Axis.vertical,
            child: Column(
              children: [
                Stack(
                  children: [
                    Image.network(
                      eventData.eventImg,
                      width: double.infinity,
                    ),
                    Positioned(
                        left:20,
                        bottom:55,
                        child: Text(eventData.eventTitle,style:GoogleFonts.montserrat(color:Colors.white,fontSize:16,fontWeight:FontWeight.bold),)
                    ),
                    Positioned(
                        left:20,
                        bottom:35,
                        child: Text(hostedBy,style:GoogleFonts.montserrat(color:Colors.white,fontSize:13,fontWeight:FontWeight.w600),)
                    ),
                    Positioned(
                        left:20,
                        bottom:15,
                        child: Text(hostCollege,style:GoogleFonts.montserrat(color:Colors.white,fontSize:11,fontWeight:FontWeight.w500),)
                    ),
                  ],
                ),
                const SizedBox(height:20),
                Row(
                  mainAxisAlignment:MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                          const SizedBox(width: 6),
                          Text(
                            'Registration Open',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.group, size: 16, color: Colors.blue),
                          const SizedBox(width: 6),
                          Text(
                            'Team 1-3 members',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
                const SizedBox(height:10),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  width:MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment:CrossAxisAlignment.start,
                    children: [
                      Text('Event Timeline',style:GoogleFonts.nunito(fontSize:18,fontWeight:FontWeight.w800)),
                      ListTile(
                        leading:Container(
                            width:50,
                            height:45,
                            decoration:BoxDecoration(
                                borderRadius:BorderRadius.circular(10),
                                color:Color(0xffEFEFFE)
                            ),
                            child: const Icon(LucideIcons.calendar,color:Color(0xff4F46E5),)),
                        title:Text('Event Date',style:GoogleFonts.montserrat(fontWeight:FontWeight.w600)),
                        subtitle:Text('April 27, 2025 . 2:00PM - 6:00 PM',style:GoogleFonts.poppins(fontWeight:FontWeight.w500)),
                      ),
                      ListTile(
                        leading:Container(
                            width:50,
                            height:45,
                            decoration:BoxDecoration(
                                borderRadius:BorderRadius.circular(10),
                                color:const Color(0xffFEE2E2)
                            ),
                            child: const Icon(LucideIcons.clock,color:Color(0xffE33629),)),
                        title:Text('Registration Deadline',style:GoogleFonts.montserrat(fontWeight:FontWeight.w600)),
                        subtitle:Text('April 27, 2025 . 12:00PM ',style:GoogleFonts.poppins(fontWeight:FontWeight.w500)),
                      ),
                      ListTile(
                        leading:Container(
                            width:50,
                            height:45,
                            decoration:BoxDecoration(
                                borderRadius:BorderRadius.circular(10),
                                color:const Color(0xffDBEAFE)
                            ),
                            child: const Icon(Icons.location_on_rounded,color:Color(0xff4F46E5),)
                        ),
                        title:Text('Venue',style:GoogleFonts.montserrat(fontWeight:FontWeight.w600)),
                        subtitle:Text('MNNIT Allahabad, Prayagraj, Uttar Pardesh',style:GoogleFonts.poppins(fontWeight:FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height:10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  width:MediaQuery.of(context).size.width,
                  child:Column(
                    crossAxisAlignment:CrossAxisAlignment.start,
                    children: [
                      Text('About the Event',style:GoogleFonts.montserrat(fontSize:18,fontWeight:FontWeight.w800)),
                      const SizedBox(height:10),
                      Text(eventData.description,style:GoogleFonts.nunito(fontSize:13,fontWeight:FontWeight.w400)),
                    ],
                  ),
                ),
                const SizedBox(height:10),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Stages",
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      StageItem(date: "May 30, 2025", title: "Registrations Begins", time: "10:00 AM"),
                      StageItem(date: "June 1, 2025", title: "Registrations closes", time: "10:00 PM"),
                      StageItem(date: "June 3, 2025", title: "Submission Deadline", time: "12:00 PM"),
                      StageItem(date: "June 4, 2025", title: "Presentations & Judging", time: "2:00 PM - 5:00 PM"),
                      StageItem(date: "June 5, 2025", title: "Result Declarations", time: "2:00 PM"),
                      StageItem(date: "June 6, 2025", title: "Awards Ceremony", time: "11:00 PM - 2:00 PM"),
                    ],
                  ),
                ),
                const SizedBox(height:10),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Key Highlights",
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height:10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children:  [
                          HighlightBox(
                            icon: LucideIcons.bookOpen,
                            title: "Quiz Type",
                            subtitle: "Business, Tech, Markets",
                            color:Color(0xffEFEFFE),
                            iconColor:Color(0xff1E40AF),
                          ),
                          HighlightBox(
                            icon: LucideIcons.graduationCap,
                            title: "Eligibility",
                            subtitle: "UG & PG Students",
                            color:Color(0xffDCFCE7),
                            iconColor:Color(0xff16A34A),
                          ),
                          HighlightBox(
                            icon: LucideIcons.user,
                            title: "Participation",
                            subtitle: "Solo or in teams",
                            color:Color(0xffFEF3C7),
                            iconColor:Color(0xffFFB54D),
                          ),
                          HighlightBox(
                            icon: LucideIcons.wifi,
                            title: "Event Type",
                            subtitle: "Offline at campus",
                            color:Color(0xffFFE4E6),
                            iconColor:Color(0xffE33629),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height:10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rules and Guidelines",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...rules.map(
                            (rule) => Padding(
                          padding: const EdgeInsets.only(bottom:8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("• ",
                                  style: TextStyle(fontSize: 18, height: 1.4)),
                              Expanded(
                                child: Text(
                                  rule,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    height: 1.4,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height:10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Prizes & Certificates",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children:  [
                          Expanded(
                            child: PrizeBox(
                              icon: Icons.emoji_events,
                              title: "First Prize",
                              amount: "INR 15000 + Internship",
                              backgroundColor:const Color(0xFFFFF8E1),
                              backgroundColor2: const Color(0xFFFBBF24),
                              iconBgcolor:const Color(0xffFBBF24),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child:PrizeBox(
                              icon: Icons.emoji_events_outlined,
                              title: "Second Prize",
                              amount: "INR 15000 + Internship",
                              backgroundColor:Color(0xFFF3F4F6),
                              backgroundColor2:  Color(0xFF9CA3AF),
                              iconBgcolor:Color(0xff9CA3AF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                        },
                        child: Text(
                          "View Results",
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height:10),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  width:MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment:CrossAxisAlignment.start,
                    children: [
                      Text('Event Timeline',style:GoogleFonts.nunito(fontSize:18,fontWeight:FontWeight.w800)),
                      ListTile(
                        leading:Container(
                            width:50,
                            height:50,
                            decoration:BoxDecoration(
                                borderRadius:BorderRadius.circular(25),
                                color:Color(0xffEFEFFE)
                            ),
                            child: const Icon(Icons.person,color:Color(0xff4F46E5),)),
                        title:Text('Amit Vishwas',style:GoogleFonts.inter(fontWeight:FontWeight.w500,fontSize:18)),
                        subtitle:Text('Faculty Coordinator',style:GoogleFonts.poppins(fontWeight:FontWeight.w500,fontSize:14)),
                      ),
                      ListTile(
                        leading:Container(
                            width:50,
                            height:50,
                            decoration:BoxDecoration(
                                borderRadius:BorderRadius.circular(25),
                                color:Color(0xffFEE2E2)
                            ),
                            child: const Icon(Icons.person,color:Color(0xffE33629),)),
                        title:Text('Ajeet',style:GoogleFonts.inter(fontWeight:FontWeight.w500,fontSize:18)),
                        subtitle:Text('Student Coordinator',style:GoogleFonts.poppins(fontWeight:FontWeight.w500,fontSize:14)),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  width:MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment:CrossAxisAlignment.start,
                    children: [
                      Text('Contact Information',style:GoogleFonts.nunito(fontSize:18,fontWeight:FontWeight.w800)),
                      ListTile(
                        leading:Container(
                            width:50,
                            height:45,
                            decoration:BoxDecoration(
                                borderRadius:BorderRadius.circular(18),
                                color:Color(0xffDCFCE7)
                            ),
                            child: const Icon(Icons.call,color:Color(0xff22C55E),)),
                        title:Text('Priya Sharma',style:GoogleFonts.montserrat(fontWeight:FontWeight.w500,fontSize:18)),
                        subtitle:Text('+91 98765 43210',style:GoogleFonts.poppins(fontWeight:FontWeight.w500,fontSize:14)),
                      ),
                      ListTile(
                        leading:Container(
                            width:50,
                            height:45,
                            decoration:BoxDecoration(
                                borderRadius:BorderRadius.circular(18),
                                color:const Color(0xffDBEAFE)
                            ),
                            child: const Icon(Icons.mail,color:Color(0xff4F46E5),)),
                        title:Text('Email',style:GoogleFonts.nunito(fontWeight:FontWeight.w600,fontSize:18)),
                        subtitle:Text('technoquest@mnnit.ac.in',style:GoogleFonts.montserrat(fontWeight:FontWeight.w500,fontSize:14)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Visibility(
            visible: eventData.takeRegistration,
            child: Container(
              // color: const Color.fromARGB(255, 225, 232, 243),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    flex: 4,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!isRegistered && isReistrationOpen) {
                          handleRegisterBtn();
                        }
                        if (!isAuthenticated) {
                          AuthDialog.showUnauthDialog(context);
                        }
                        if (isRegistered && registeredTeam == null) {
                          _refresh();
                        }
                        if (isRegistered && registeredTeam != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EventTicket(
                                    event: eventData, team: registeredTeam!)),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        !isAuthenticated
                            ? 'Sign In to Register'
                            : isRegistered
                            ? 'Get Ticket'
                            : isReistrationOpen
                            ? 'Register Event'
                            : 'Registration Closed',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  IconButton.outlined(
                    onPressed: () {
                      if (isAuthenticated) {
                        handleEventChat();
                      } else {
                        AuthDialog.showUnauthDialog(context);
                      }
                    },
                    icon: const Icon(Icons.comment_outlined),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(12  ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        // Handle the error gracefully and show a message or navigate to an error page
        return Scaffold(
            appBar: AppBar(
              title: const Text("Page not Found"),
              backgroundColor: const Color.fromARGB(255, 211, 232, 255),
              titleTextStyle:
              const TextStyle(color: Colors.black, fontSize: 18),
              elevation: 0,
            ),
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      OutlinedButton(
                          onPressed: () {
                            context.go("/home");
                          },
                          child: const Text("Go to Home"))
                    ])),
        );
      },
    );
  }

}

Widget StageItem({required String date,required String title,required String time}){
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            date,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        )
      ],
    ),
  );
}

Widget HighlightBox({required IconData icon,required String title,required String subtitle,required Color color,required Color iconColor}){
  return Container(
    width: 160,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            width:50,
            height:45,
            decoration:BoxDecoration(
                borderRadius:BorderRadius.circular(10),
                color:color
            ),
            child: Icon(icon, size: 24, color:iconColor)),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.montserrat(
            fontSize: 12.5,
            fontWeight: FontWeight.w400,
            color: Colors.grey[700],
          ),
        ),
      ],
    ),
  );
}

Widget PrizeBox({required IconData icon,required Color backgroundColor,required Color backgroundColor2,required String title,required String amount,required Color iconBgcolor}){
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      gradient:LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:[backgroundColor,backgroundColor2]),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Container(
            width:50,
            height:45,
            decoration:BoxDecoration(
                borderRadius:BorderRadius.circular(10),
                color:iconBgcolor
            ),
            child: Icon(icon, size: 28, color: const Color(0xffFFFFFF))),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Text(
          amount,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.grey[800],
          ),
        ),
      ],
    ),
  );
}

