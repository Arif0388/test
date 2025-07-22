import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/api/common/launch_url.dart';
import 'package:learningx_flutter_app/api/model/community_model.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityAboutFragment extends StatefulWidget {
  final Community community;
  const CommunityAboutFragment({super.key, required this.community});

  @override
  State<CommunityAboutFragment> createState() => _CommunityAboutFragmentState();
}

class _CommunityAboutFragmentState extends State<CommunityAboutFragment>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _currentUserId = "";
  bool isAdmin = false;

  @override
  void initState() {
    _loadCurrentUser();
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
      isAdmin = widget.community.admin.any((item) => item.id == _currentUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Call super.build for AutomaticKeepAlive

    return SingleChildScrollView(
        key: const PageStorageKey<String>('communityScroll'),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, top: 8),
                    child: Text(
                      'Description',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.community.description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Divider(
                    color: Color.fromARGB(255, 238, 238, 238),
                    height: 4,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, top: 8),
                    child: Text(
                      'Contact info',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  if (widget.community.email.isNotEmpty)
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.mail_outline,
                                size: 18, color: Colors.grey[700]),
                            const SizedBox(width: 8),
                            Text(
                              widget.community.email,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        )),
                  if (widget.community.website.isNotEmpty)
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.link, size: 18, color: Colors.grey[700]),
                            const SizedBox(width: 8),
                            Flexible(
                                child: GestureDetector(
                                    onTap: () {
                                      LaunchUrl.openUrl(widget.community.website);
                                    },
                                    child: Text(
                                      widget.community.website,
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          overflow: TextOverflow.visible),
                                    ))),
                          ],
                        )),
                  if (widget.community.linkedIn.isNotEmpty)
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/images/linkedin.png',
                              width: 18,
                              height: 18,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                                child: GestureDetector(
                                    onTap: () {
                                      LaunchUrl.openUrl(
                                          widget.community.linkedIn);
                                    },
                                    child: Text(
                                      widget.community.linkedIn,
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          overflow: TextOverflow.visible),
                                    ))),
                          ],
                        )),
                  if (widget.community.instagram.isNotEmpty)
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/images/instagram.png',
                              width: 18,
                              height: 18,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                                child: GestureDetector(
                                    onTap: () {
                                      LaunchUrl.openUrl(
                                          widget.community.instagram);
                                    },
                                    child: Text(
                                      widget.community.instagram,
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          overflow: TextOverflow.visible),
                                    ))),
                          ],
                        )),
                  Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.access_time,
                              size: 18, color: Colors.grey[700]),
                          const SizedBox(width: 8),
                          Text(
                            Utils.getDateString(
                                DateTime.parse(widget.community.createdAt)),
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      )),
                  const Divider(
                    color: Color.fromARGB(255, 238, 238, 238),
                    height: 16,
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
