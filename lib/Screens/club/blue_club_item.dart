import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/api/model/club_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlueClubItemWidget extends StatefulWidget {
  final ClubItem club;
  const BlueClubItemWidget({super.key, required this.club});
  @override
  State<BlueClubItemWidget> createState() => _BlueClubItemState();
}

class _BlueClubItemState extends State<BlueClubItemWidget> {
  String _currentUserId = "";
  bool isCollegeAdmin = false;
  bool isClubAdmin = false;

  @override
  void initState() {
    _loadCurrentUser();
    super.initState();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString("id") ?? "";
      isClubAdmin = widget.club.admin.contains(_currentUserId);
      if (widget.club.college != null) {
        isCollegeAdmin = widget.club.college!.admin.contains(_currentUserId);
      }
    });
  }

  void navigate() {
    context.push("/club/about/${widget.club.id}");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: navigate,
      child: Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              color: Colors.blue,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    width: 100.0,
                    height: 100.0,
                    color: Colors.grey[200],
                    child: Image.network(
                      widget.club.clubImg,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                              child: Text(
                            widget.club.clubName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          )),
                          const SizedBox(width: 8),
                          if (widget.club.collegeStatus == "verified")
                            const Icon(
                              Icons.verified_outlined,
                              size: 15,
                              color: Colors.blue,
                            ),
                          if ((isCollegeAdmin || isClubAdmin) &&
                              widget.club.collegeStatus == "unverified")
                            const Icon(
                              Icons.verified_user_outlined,
                              size: 15,
                              color: Colors.grey,
                            ),
                          if ((isCollegeAdmin || isClubAdmin) &&
                              widget.club.college != null &&
                              widget.club.collegeStatus == "rejected")
                            Image.asset(
                              "assets/images/under_approval.jpg",
                              height: 32,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (widget.club.councilName != "")
                        Text(
                          widget.club.councilName!,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      if (widget.club.councilName == "")
                        Text(
                          widget.club.category,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      const SizedBox(height: 4),
                      if (widget.club.description.isNotEmpty)
                        Text(
                          widget.club.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black54),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
