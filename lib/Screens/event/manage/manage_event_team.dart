import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/api/model/event_team_model.dart';
import 'package:learningx_flutter_app/api/provider/event_manage_provider.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class EventRegisteredTeams extends ConsumerStatefulWidget {
  final String eventId; // Pass the event ID

  const EventRegisteredTeams({Key? key, required this.eventId})
      : super(key: key);

  @override
  ConsumerState<EventRegisteredTeams> createState() =>
      _EventRegisteredTeamsState();
}

class _EventRegisteredTeamsState extends ConsumerState<EventRegisteredTeams> {
  List<EventTeam> registeredTeams = [];
  final List<Map<String, String>> statusOptions = [
    {"key": "verified", "text": "Verified", "value": "verified"},
    {"key": "unverified", "text": "Not Verified", "value": "unverified"},
    {"key": "eliminated", "text": "Eliminated", "value": "eliminated"},
  ];

  void handleStatusChange(EventTeam team, String newStatus) {
    final updatedTeam = team.copyWith(
        status: newStatus); // Create a new instance with updated status
    setState(() {
      registeredTeams = registeredTeams
          .map((t) => t.id == updatedTeam.id ? updatedTeam : t)
          .toList();
    });
    updateTeamStatus(updatedTeam); // Call API to update status
  }

  Future<void> updateTeamStatus(EventTeam team) async {
    Map<String, String> data = HashMap();
    data['_id'] = team.id;
    data['event'] = team.event;
    data['status'] = team.status;
    await updateRegisteredTeamApi(context, data);
  }

  Future<void> handleExportTeams(List<EventTeam> teams) async {
    try {
      String csvData = dataToCSV(teams);

      // Get the directory for saving the file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/registered_teams.csv";

      // Save the CSV data to a file
      final file = File(filePath);
      await file.writeAsString(csvData);

      // Use shareXFiles with XFile
      final xFile = XFile(filePath);
      await Share.shareXFiles([xFile], text: "Registered Teams CSV");
    } catch (e) {
      debugPrint('Error exporting CSV: $e');
    }
  }

  String dataToCSV(List<EventTeam> teams) {
    final headers = [
      "Serial Number",
      "Team Name",
      "Status",
      "Member Name",
      "College Name",
      "Email",
      "Contact Number",
      "Other Details",
      "Team Lead",
      "Registration Date"
    ].join(",");

    final rows = teams.expand((team) {
      return team.members.map((member) {
        return [
          team.teamNumber,
          team.teamName,
          team.status,
          member.memberName,
          member.college,
          member.email,
          member.phone,
          member.otherDetails,
          team.creator.displayName,
          Utils.formatDate(team.createdAtDate),
        ].join(",");
      });
    });

    return "$headers\n${rows.join("\n")}";
  }

  @override
  Widget build(BuildContext context) {
    final teamsAsyncValue = ref.watch(fetchEventManageTeams(widget.eventId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registered Teams"),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: teamsAsyncValue.when(
          data: (teams) {
            // Only initialize the state when teams are fetched for the first time.
            if (registeredTeams.isEmpty) {
              registeredTeams = teams;
            }
            return Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () => handleExportTeams(registeredTeams),
                  icon: const Icon(Icons.download),
                  label: const Text("Export Teams"),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text("Serial Number")),
                        DataColumn(label: Text("Team Name")),
                        DataColumn(label: Text("Status")),
                        DataColumn(label: Text("Member Name")),
                        DataColumn(label: Text("College Name")),
                        DataColumn(label: Text("Email")),
                        DataColumn(label: Text("Contact Number")),
                        DataColumn(label: Text("Other Details")),
                        DataColumn(label: Text("Creator")),
                        DataColumn(label: Text("Registration Date")),
                      ],
                      rows: registeredTeams.asMap().entries.expand((entry) {
                        final index =
                            entry.key; // Serial number (0-based index)
                        final team = entry.value;

                        return team.members.asMap().entries.map((memberEntry) {
                          final member = memberEntry.value;
                          final isFirstMember = memberEntry.key == 0;

                          return DataRow(cells: [
                            // Serial Number
                            if (isFirstMember)
                              DataCell(Text((index + 1)
                                  .toString())) // Convert to 1-based index
                            else
                              DataCell.empty,
                            if (isFirstMember)
                              DataCell(Text(team.teamName))
                            else
                              DataCell.empty,
                            if (isFirstMember)
                              DataCell(
                                DropdownButton<String>(
                                  value: team.status,
                                  items: statusOptions.map((option) {
                                    return DropdownMenuItem(
                                      value: option["value"],
                                      child: Text(option["text"]!),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      handleStatusChange(team, value);
                                    }
                                  },
                                ),
                              )
                            else
                              DataCell.empty,
                            DataCell(Text(member.memberName)),
                            DataCell(Text(member.college)),
                            DataCell(Text(member.email)),
                            DataCell(Text(member.phone)),
                            DataCell(Text(member.otherDetails)),
                            if (isFirstMember)
                              DataCell(GestureDetector(
                                  onTap: () {
                                    context.push("/profile/${team.creator.id}");
                                  },
                                  child: Text(
                                    team.creator.displayName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )))
                            else
                              DataCell.empty,
                            if (isFirstMember)
                              DataCell(Text(Utils.formatDate(team.createdAtDate)))
                            else
                              DataCell.empty,
                          ]);
                        }).toList();
                      }).toList(),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text('Failed to fetch teams: $error')),
        ),
      ),
    );
  }
}
