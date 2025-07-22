import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:learningx_flutter_app/api/model/event_model.dart';
import 'package:learningx_flutter_app/api/model/event_team_model.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class EventTicket extends StatefulWidget {
  final Event event;
  final EventTeam team;

  const EventTicket({
    Key? key,
    required this.event,
    required this.team,
  }) : super(key: key);

  @override
  State<EventTicket> createState() => _EventTicketState();
}

class _EventTicketState extends State<EventTicket> {
  final GlobalKey _ticketKey = GlobalKey();

  Future<void> _shareTicketAsImage() async {
    try {
      // Capture the widget image
      RenderRepaintBoundary boundary = _ticketKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to a temporary file
      final tempDir = await getTemporaryDirectory();
      final file =
          await File('${tempDir.path}/${widget.event.eventTitle}_ticket.png')
              .create();
      await file.writeAsBytes(pngBytes);

      // Share the file
      await Share.shareXFiles([XFile(file.path)],
          text: "Here is my event ticket!");
    } catch (e) {
      print("Error sharing ticket: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Ticket"),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareTicketAsImage,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: RepaintBoundary(
          key: _ticketKey, // Assign the GlobalKey to RepaintBoundary
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Event Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.event.eventImg,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Event Details
                  Text(
                    widget.event.eventTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Date & Time: ${Utils.formatDate(DateTime.parse(widget.event.eventStartDate))}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Team Details
                  if (widget.event.participation == "team")
                    Text(
                      '${widget.team.teamNumber}. ${widget.team.teamName}',
                      style: const TextStyle(fontSize: 18),
                    ),
                  if (widget.event.participation == "team")
                    const SizedBox(height: 16),
                  if (widget.event.participation == "team")
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.team.members
                          .map((member) => Text("• ${member.memberName}"))
                          .toList(),
                    ),

                  // Individual Details
                  if (widget.event.participation == "individual")
                    Text(
                      '${widget.team.teamNumber}. ${widget.team.members[0].memberName}',
                      style: const TextStyle(fontSize: 18),
                    ),

                  // Footer Note
                  const SizedBox(height: 16),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Please carry your College ID",
                      style: TextStyle(
                        fontStyle: FontStyle.normal,
                        color: Colors.redAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
