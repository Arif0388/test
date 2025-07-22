import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:learningx_flutter_app/api/provider/event_manage_provider.dart';

final GlobalKey<FormState> eventRoundKey = GlobalKey<FormState>();

class EventRoundForm extends ConsumerStatefulWidget {
  final String eventId;
  final Function(Map<String, dynamic>) onSave;

  const EventRoundForm(
      {super.key, required this.eventId, required this.onSave});

  @override
  ConsumerState<EventRoundForm> createState() => EventRoundFormState();
}

class EventRoundFormState extends ConsumerState<EventRoundForm> {
  final List<TextEditingController> _roundTitles = [];
  final List<TextEditingController> _startDateTimes = [];
  final List<TextEditingController> _endDateTimes = [];
  final List<TextEditingController> _aboutRounds = [];
  final List<String> _roundTypes = [];
  final List<String> _eliminationRounds = [];

  List<String> startDates = [];
  List<String> startIsoDates = [];
  List<String> endDates = [];
  List<String> endIsoDates = [];

  @override
  void initState() {
    _initialize(widget.eventId);
    super.initState();
  }

  Future<void> _initialize(String eventId) async {
    await ref
        .read(eventManageProvider(eventId).notifier)
        .fetchSelectedEvent(eventId);
    final eventData = ref.read(eventManageProvider(eventId));
    setState(() {
      if (eventData.stages != null) {
        for (int i = 0; i < eventData.stages!.length; i++) {
          _addNewRound();
          _roundTitles[i].text = eventData.stages![i].roundTitle;
          _aboutRounds[i].text = eventData.stages![i].description;
          _roundTypes[i] = eventData.stages![i].roundType;
          _eliminationRounds[i] = eventData.stages![i].eliminator;
          startDates[i] = DateFormat('dd MMM yyyy HH:mm:ss')
              .format(eventData.stages![i].startedAtDate);
          startIsoDates[i] = eventData.stages![i].startDate;
          endDates[i] = DateFormat('dd MMM yyyy HH:mm:ss')
              .format(eventData.stages![i].endedAtDate);
          endIsoDates[i] = eventData.stages![i].endDate;
          _startDateTimes[i].text = startDates[i];
          _endDateTimes[i].text = endDates[i];
        }
      }
    });
  }

  /// Function to add a new round.
  void _addNewRound() {
    setState(() {
      _roundTitles.add(TextEditingController());
      _startDateTimes.add(TextEditingController());
      _endDateTimes.add(TextEditingController());
      _aboutRounds.add(TextEditingController());
      _roundTypes.add('');
      _eliminationRounds.add('');
      startDates.add(DateFormat('dd MMM yyyy HH:mm:ss').format(DateTime.now()));
      startIsoDates.add(DateTime.now().toUtc().toIso8601String());
      endDates.add(DateFormat('dd MMM yyyy HH:mm:ss').format(DateTime.now()));
      endIsoDates.add(DateTime.now().toUtc().toIso8601String());
    });
  }

  /// Function to remove a round by index.
  void _removeRound(int index) {
    setState(() {
      _roundTitles.removeAt(index);
      _startDateTimes.removeAt(index);
      _endDateTimes.removeAt(index);
      _aboutRounds.removeAt(index);
      _roundTypes.removeAt(index);
      _eliminationRounds.removeAt(index);
      startDates.remove(index);
      startIsoDates.remove(index);
      endDates.remove(index);
      endIsoDates.remove(index);
    });
  }

  Future<void> _selectDate(
      BuildContext context, bool isStartDate, int index) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          if (isStartDate) {
            startDates[index] =
                DateFormat('dd MMM yyyy HH:mm:ss').format(pickedDateTime);
            startIsoDates[index] = pickedDateTime.toUtc().toIso8601String();
            _startDateTimes[index].text = startDates[index];
          } else {
            endDates[index] =
                DateFormat('dd MMM yyyy HH:mm:ss').format(pickedDateTime);
            endIsoDates[index] = pickedDateTime.toUtc().toIso8601String();
            _endDateTimes[index].text = endDates[index];
          }
        });
      }
    }
  }

  /// Save round data
  bool saveDetails() {
    if (eventRoundKey.currentState?.validate() ?? false) {
      List<Map<String, dynamic>> roundData = [];
      for (int i = 0; i < _roundTitles.length; i++) {
        roundData.add({
          'round': i + 1,
          'roundTitle': _roundTitles[i].text,
          'startDate': startIsoDates[i],
          'endDate': endIsoDates[i],
          'description': _aboutRounds[i].text,
          'roundType': _roundTypes[i],
          'eliminator': _eliminationRounds[i],
        });
      }
      widget.onSave({'stages': roundData});
      return true;
    }
    return false;
  }

  /// Build a single round card.
  Widget _buildRoundCard({required int index}) {
    return Card(
      key: ValueKey(index),
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Header Row with Title and Delete Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Round ${index + 1}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w400)),
                IconButton(
                  onPressed: () => _removeRound(index),
                  icon: const Icon(Icons.delete, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Round Title Field
            TextFormField(
              controller: _roundTitles[index],
              decoration: const InputDecoration(
                labelText: 'Round Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Round title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            // Start and End Date-Time Fields
            TextFormField(
              controller: _startDateTimes[index],
              onTap: () => _selectDate(context, true, index),
              decoration: const InputDecoration(
                labelText: "Start Date & Time",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a start date';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _endDateTimes[index],
              onTap: () => _selectDate(context, false, index),
              decoration: const InputDecoration(
                labelText: "End Date & Time",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select an end date';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),

            // About Round Field
            TextFormField(
              controller: _aboutRounds[index],
              decoration: const InputDecoration(
                labelText: 'About this Round',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              minLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Details about the round are required';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            // Dropdown for Round Type
            DropdownButtonFormField<String>(
              value: _roundTypes[index].isNotEmpty ? _roundTypes[index] : null,
              decoration: const InputDecoration(
                labelText: 'Round Type',
                border: OutlineInputBorder(),
              ),
              items: ['online', 'offline']
                  .map((type) =>
                      DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) => setState(() {
                _roundTypes[index] = value ?? '';
              }),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Select a round type';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            // Dropdown for Elimination Round
            DropdownButtonFormField<String>(
              value: _eliminationRounds[index].isNotEmpty
                  ? _eliminationRounds[index]
                  : null,
              decoration: const InputDecoration(
                labelText: 'Elimination Round',
                border: OutlineInputBorder(),
              ),
              items: ['yes', 'no']
                  .map((choice) =>
                      DropdownMenuItem(value: choice, child: Text(choice)))
                  .toList(),
              onChanged: (value) => setState(() {
                _eliminationRounds[index] = value ?? '';
              }),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Select Yes or No';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: eventRoundKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            const Text(
              "Add details about each round to guide participants.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Column(
              children: List.generate(
                _roundTitles.length,
                (index) => _buildRoundCard(index: index),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _addNewRound,
              child: const Text('Add Round'),
            ),
          ],
        ),
      ),
    );
  }
}
