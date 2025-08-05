
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/model/college_model.dart';

class CollegeAboutFragment extends StatefulWidget {
  final College college;
  final bool isMyCampus;
  const CollegeAboutFragment(
      {super.key, required this.college, required this.isMyCampus});

  @override
  State<CollegeAboutFragment> createState() => _CollegeAboutFragmentState();
}

class _CollegeAboutFragmentState extends State<CollegeAboutFragment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color(0xffF9FAFB),
      appBar:AppBar(
        leading:const Icon(Icons.arrow_back),
        title:Text(
          'Noida Institute of Engineering & Technology',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset('assets/images/campus_image.jpg'),
              Container(
                width:MediaQuery.of(context).size.width,
                height:196,
                color:Colors.black26,
              ),
              Positioned(
                top:120,
                child: SizedBox(
                  width:MediaQuery.of(context).size.width,
                  height:100,
                  child: ListTile(
                    title: Text(
                      'Noida Institute of Engineering & Technology',
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.bold,color:Colors.white),
                    ),
                    subtitle: Text(
                      '📍 Greater Noida, Uttar Pradesh',
                      style: GoogleFonts.inter(fontSize: 13,color:Colors.white,fontWeight:FontWeight.w400),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // const SizedBox(height:5),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Accreditations ',style:GoogleFonts.inter(fontWeight: FontWeight.w600,fontSize:18),),
              ),
            ],
          ),

          SingleChildScrollView(
            scrollDirection:Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  chip("NAAC 'A' Grade"),
                  const SizedBox(width:5),
                  chip("NBA Accredited"),
                  const SizedBox(width:5),
                  chip("AICTE Approved"),
                ],
              ),
            ),
          ),
          // const SizedBox(height: 5),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('About Campus',style:GoogleFonts.inter(fontWeight: FontWeight.w600,fontSize:18),),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "NIET is a premier engineering institute established in 2001, offering world-class education with state-of-the-art infrastructure and industry-focused curriculum. The campus spans over 15 acres with modern facilities including advanced labs, library, sports complex, and hostels.",
              style: GoogleFonts.inter(fontSize: 13,fontWeight:FontWeight.w400),
            ),
          ),

          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left:15),
                child:Text('Read more',style:GoogleFonts.inter(fontWeight:FontWeight.w500,color:const Color(0xff1E40AF))),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded,color:Color(0xff1E40AF),),
            ],
          ),
          const SizedBox(height:10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Contact Info", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height:4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,color:Color(0xff1E40AF),size:20,),
                    const SizedBox(height: 5),
                    Expanded(child: Text("19,Knowledge Park-II, Institutional Area, Greater Noida, Uttar Pradesh 201306", style: GoogleFonts.inter(fontSize: 13,fontWeight: FontWeight.w400))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone,color:Color(0xff1E40AF),size:18,),
                    const SizedBox(width:4,),
                    Text("+91 120 2328050", style: GoogleFonts.inter(fontSize: 13,fontWeight:FontWeight.w400)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.message_outlined,color:Color(0xff1E40AF),size:18,),
                    const SizedBox(width:5,),
                    Text("info@niet.co.in", style: GoogleFonts.inter(fontSize: 13,fontWeight:FontWeight.w400)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.language,color:Color(0xff1E40AF),size:19,),
                    const SizedBox(width:5,),
                    InkWell(
                      onTap: () => launchUrl(Uri.parse("https://www.niet.co.in")),
                      child: Text("www.niet.co.in", style: GoogleFonts.inter(fontSize: 13,fontWeight:FontWeight.w400)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height:10,),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left:10),
                child: Text('Connect With Us',style:GoogleFonts.inter(fontWeight:FontWeight.w600,fontSize:18)),
              ),
            ],
          ),
          const SizedBox(height:5,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                socialIcon(FontAwesomeIcons.linkedin, 'https://linkedin.com',0xff0077B5),
                socialIcon(FontAwesomeIcons.instagram, 'https://instagram.com',0xffE1306C),
                socialIcon(FontAwesomeIcons.xTwitter, 'https://twitter.com',0xff1DA1F2),
                socialIcon(FontAwesomeIcons.youtube, 'https://youtube.com',0xffFF0000),
                socialIcon(FontAwesomeIcons.facebook, 'https://facebook.com',0xff4267B2),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo),
                    onPressed: () {},
                    child: Text("Apply Now", style: GoogleFonts.inter(fontWeight:FontWeight.w500)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Text("Contact Us", style: GoogleFonts.inter(fontWeight:FontWeight.w500)),
                  ),
                ),
                const SizedBox(width:10,),
                Container(
                    width:45,
                    height:45,
                    decoration:BoxDecoration(
                      borderRadius:BorderRadius.circular(22.5),
                      color:const Color(0xff1E40AF),
                    ),
                    child:const Icon(FontAwesomeIcons.facebookMessenger,color:Colors.white,)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget chip(String text) {
    return Chip(
      label: Row(
        children: [
          const Icon(Icons.verified_outlined,color:Color(0xff1E40AF),size:20,),
          const SizedBox(width:6,),
          Text(text, style: GoogleFonts.inter(fontSize: 12,fontWeight:FontWeight.w500)),
        ],
      ),
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget socialIcon(IconData icon, String url,int color) {
    return Container(
      margin:const EdgeInsets.only(right:10),
      width:40,
      height:40,
      decoration:BoxDecoration(
        borderRadius:BorderRadius.circular(20),
        color:Color(color),
      ),
      child: IconButton(
        onPressed: () => launchUrl(Uri.parse(url)),
        icon: Icon(icon),
        color: Colors.white,
      ),
    );
  }
}

