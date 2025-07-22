import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/api/common/launch_url.dart';
import 'package:learningx_flutter_app/api/model/council_model.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CouncilAboutFragment extends StatefulWidget {
  final Council council;
  const CouncilAboutFragment({super.key, required this.council});

  @override
  State<CouncilAboutFragment> createState() => _CouncilAboutFragmentState();
}

class _CouncilAboutFragmentState extends State<CouncilAboutFragment>
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
      isAdmin = widget.council.admin.any((item) => item.id == _currentUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Call super.build for AutomaticKeepAlive

    return SingleChildScrollView(
        key: const PageStorageKey<String>('councilScroll'),
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
                      widget.council.description,
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
                  if (widget.council.email.isNotEmpty)
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.mail_outline,
                                size: 18, color: Colors.grey[700]),
                            const SizedBox(width: 8),
                            Text(
                              widget.council.email,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        )),
                  if (widget.council.website.isNotEmpty)
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
                                      LaunchUrl.openUrl(widget.council.website);
                                    },
                                    child: Text(
                                      widget.council.website,
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          overflow: TextOverflow.visible),
                                    ))),
                          ],
                        )),
                  if (widget.council.linkedIn.isNotEmpty)
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
                                          widget.council.linkedIn);
                                    },
                                    child: Text(
                                      widget.council.linkedIn,
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          overflow: TextOverflow.visible),
                                    ))),
                          ],
                        )),
                  if (widget.council.instagram.isNotEmpty)
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
                                          widget.council.instagram);
                                    },
                                    child: Text(
                                      widget.council.instagram,
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
                                DateTime.parse(widget.council.createdAt)),
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
