import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/api/common/launch_url.dart';
import 'package:learningx_flutter_app/api/model/fest_model.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';

class FestAboutFragment extends StatefulWidget {
  final Fest fest;
  final Widget page;
  const FestAboutFragment({super.key, required this.fest, required this.page});

  @override
  State<FestAboutFragment> createState() => _FestAboutFragmentState();
}

class _FestAboutFragmentState extends State<FestAboutFragment> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        widget.page,
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 8.0, top: 8),
                child: Text(
                  'Festival Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color:  Color(0xFF2B3595),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.fest.description,
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
                  'Date & Venue',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color:  Color(0xFF2B3595),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Date: ${Utils.getDateString(DateTime.parse(widget.fest.startDate))} - ${Utils.getDateString(DateTime.parse(widget.fest.endDate))}\nVenue: ',
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
                    color:  Color(0xFF2B3595),
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.mail_outline,
                          size: 18, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        widget.fest.email,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  )),
              if (widget.fest.website.isNotEmpty)
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
                                  LaunchUrl.openUrl(widget.fest.website);
                                },
                                child: Text(
                                  widget.fest.website,
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      overflow: TextOverflow.visible),
                                ))),
                      ],
                    )),
              if (widget.fest.linkedIn.isNotEmpty)
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
                                  LaunchUrl.openUrl(widget.fest.linkedIn);
                                },
                                child: Text(
                                  widget.fest.linkedIn,
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      overflow: TextOverflow.visible),
                                ))),
                      ],
                    )),
              if (widget.fest.instagram.isNotEmpty)
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
                                  LaunchUrl.openUrl(widget.fest.instagram);
                                },
                                child: Text(
                                  widget.fest.instagram,
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      overflow: TextOverflow.visible),
                                ))),
                      ],
                    )),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
