// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// void main() {
//   runApp(const MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: CalendarScreen(),
//   ));
// }
//
// class CalendarScreen extends StatelessWidget {
//   const CalendarScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     DateTime now = DateTime.now();
//     String currentMonthYear = DateFormat('MMMM yyyy').format(now);
//
//     return Scaffold(
//       backgroundColor:const Color(0xffF9FAFB),
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       const Icon(Icons.arrow_back_ios, size: 20),
//                       const SizedBox(width: 8),
//                       Text(
//                         currentMonthYear,
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const Icon(Icons.keyboard_arrow_down),
//                     ],
//                   ),
//                   const CircleAvatar(
//                     backgroundImage: AssetImage('assets/profile.jpg'), // Replace with your asset
//                   )
//                 ],
//               ),
//             ),
//             const Divider(),
//             Expanded(
//               child: ListView(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 children: [
//                   CalendarDay(
//                     date: DateTime(now.year, 3, 18),
//                     events: const [
//                       Event("Live Music Festival", "10:00 AM - 11:30 AM", "Central Park", Colors.blue),
//                     ],
//                   ),
//                   CalendarDay(
//                     date: DateTime(now.year, 3, 19),
//                     events: const [
//                       Event("Winter Music Festival", "2:00 PM - 3:30 PM", "Central Park", Colors.purple),
//                       Event("Startup Networking Night", "4:00 PM - 5:00 PM", "Central Park", Colors.blueGrey),
//                     ],
//                   ),
//                   CalendarDay(
//                     date: DateTime(now.year, 3, 20),
//                     events: const [
//                       Event("Team Building Event", "1:00 PM - 5:00 PM", "Central Park", Colors.orange),
//                     ],
//                   ),
//                   CalendarDay(
//                     date: DateTime(now.year, 3, 21),
//                     showRange: true,
//                     events: const [
//                       Event("Tech Meetup 2024", "2:00 PM - 3:30 PM", "Central Park", Colors.purple),
//                       Event("Client Presentation", "4:00 PM - 5:00 PM", "Central Park", Colors.blueGrey),
//                     ],
//                   ),
//                   CalendarDay(
//                     date: DateTime(now.year, 3, 25),
//                     events: const [
//                       Event("Client Meeting", "10:30 AM", "Starbucks Downtown", Colors.green),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class CalendarDay extends StatelessWidget {
//   final DateTime date;
//   final List<Event> events;
//   final bool showRange;
//
//   const CalendarDay({
//     super.key,
//     required this.date,
//     required this.events,
//     this.showRange = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     String dayName = DateFormat('EEE').format(date);
//     String day = DateFormat('d').format(date);
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 16),
//         Text(
//           showRange
//               ? '${DateFormat('d').format(date)} - ${DateFormat('d MMM').format(date.add(const Duration(days: 3)))}'
//               : '$dayName $day',
//           style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
//         ),
//         const SizedBox(height: 8),
//         ...events.map((event) => EventTile(event: event)).toList(),
//       ],
//     );
//   }
// }
//
// class Event {
//   final String title;
//   final String time;
//   final String location;
//   final Color color;
//
//   const Event(this.title, this.time, this.location, this.color);
// }
//
// class EventTile extends StatelessWidget {
//   final Event event;
//
//   const EventTile({super.key, required this.event});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: event.color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border(left: BorderSide(color: event.color, width: 4)),
//       ),
//       child: ListTile(
//         title: Text(
//           event.title,
//           style: const TextStyle(fontWeight: FontWeight.w600),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(event.time),
//             Row(
//               children: [
//                 const Icon(Icons.location_on_outlined, size: 14),
//                 const SizedBox(width: 4),
//                 Text(
//                   event.location,
//                   style: const TextStyle(fontSize: 12),
//                 )
//               ],
//             ),
//           ],
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Event {
  final String title;
  final String time;
  final String location;
  final Color color;

  const Event(this.title, this.time, this.location, this.color);
}

class CalendarDay extends StatelessWidget {
  final DateTime date;
  final List<Event> events;
  final bool showRange;

  const CalendarDay({
    super.key,
    required this.date,
    required this.events,
    this.showRange = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            DateFormat('EEEE, MMMM d').format(date),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...events.map((event) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: event.color.withOpacity(0.1),
            border: Border.all(color: event.color),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(event.title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: event.color)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 4),
                  Text(event.time),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  Text(event.location),
                ],
              ),
            ],
          ),
        )),
        if (showRange)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: const [
                Icon(Icons.arrow_downward),
                SizedBox(width: 8),
                Text('Event Range Continues...'),
              ],
            ),
          ),
      ],
    );
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();

  Future<void> _pickMonthYear() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select Month and Year',
      fieldLabelText: 'Month/Year',
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentMonthYear = DateFormat('MMMM yyyy').format(selectedDate);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: _pickMonthYear,
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back_ios, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          currentMonthYear,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down),
                      ],
                    ),
                  ),
                  const CircleAvatar(
                    backgroundImage: AssetImage('assets/profile.jpg'),
                  )
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  CalendarDay(
                    date: DateTime(selectedDate.year, 3, 18),
                    events: const [
                      Event("Live Music Festival", "10:00 AM - 11:30 AM", "Central Park", Colors.blue),
                    ],
                  ),
                  CalendarDay(
                    date: DateTime(selectedDate.year, 3, 19),
                    events: const [
                      Event("Winter Music Festival", "2:00 PM - 3:30 PM", "Central Park", Colors.purple),
                      Event("Startup Networking Night", "4:00 PM - 5:00 PM", "Central Park", Colors.blueGrey),
                    ],
                  ),
                  CalendarDay(
                    date: DateTime(selectedDate.year, 3, 20),
                    events: const [
                      Event("Team Building Event", "1:00 PM - 5:00 PM", "Central Park", Colors.orange),
                    ],
                  ),
                  CalendarDay(
                    date: DateTime(selectedDate.year, 3, 21),
                    showRange: true,
                    events: const [
                      Event("Tech Meetup 2024", "2:00 PM - 3:30 PM", "Central Park", Colors.purple),
                      Event("Client Presentation", "4:00 PM - 5:00 PM", "Central Park", Colors.blueGrey),
                    ],
                  ),
                  CalendarDay(
                    date: DateTime(selectedDate.year, 3, 25),
                    events: const [
                      Event("Client Meeting", "10:30 AM", "Starbucks Downtown", Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
