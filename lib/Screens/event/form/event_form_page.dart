import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/api/model/event_model.dart';
import 'package:learningx_flutter_app/api/provider/event_feed_provider.dart';
import 'package:learningx_flutter_app/api/provider/event_manage_provider.dart';
import 'package:learningx_flutter_app/api/provider/event_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'basic_details.dart';
import 'registration_details.dart';
import 'rules_regulations.dart';
import 'event_round.dart';
import 'rewards_recognition.dart';

const todoColor = Color(0xffd1d2d7);
const inProgressColor = Colors.blue;
const completeColor = Color.fromARGB(255, 15, 108, 224);

List<String> contestSteps = [
  'Basic Details',
  'Registration Details',
  'Rules & Regulations',
  'Event Rounds',
  'Rewards & Recognition',
];

Color getColor(int index, int currentStep) {
  if (index == currentStep) {
    return inProgressColor;
  } else if (index < currentStep) {
    return completeColor;
  } else {
    return todoColor;
  }
}

class EventFormPage extends ConsumerStatefulWidget {
  final Map<String, String> formData;
  const EventFormPage({super.key, required this.formData});

  @override
  EventFormPageState createState() => EventFormPageState();
}

class EventFormPageState extends ConsumerState<EventFormPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  String eventId = "";
  bool isContestEvent = false;
  String _collegeId = "";

  Map<String, dynamic> eventData = {}; // Store collected data

  // Create GlobalKeys for each step
  final GlobalKey<BasicDetailsState> _basicDetailsKey =
      GlobalKey<BasicDetailsState>();
  final GlobalKey<RegistrationDetailsState> _registrationDetailsKey =
      GlobalKey<RegistrationDetailsState>();
  final GlobalKey<EventDetailsFormState> _eventDetailsKey =
      GlobalKey<EventDetailsFormState>();
  final GlobalKey<EventRoundFormState> _eventRoundKey =
      GlobalKey<EventRoundFormState>();
  final GlobalKey<PrizeFormState> _prizeFormKey = GlobalKey<PrizeFormState>();

  @override
  void initState() {
    if (widget.formData.containsKey('eventId')) {
      setState(() {
        eventId = widget.formData['eventId']!;
        _initialize(widget.formData['eventId']!);
      });
    }
    _loadCurrentUser();
    super.initState();
  }

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _collegeId = prefs.getString("college") ?? "";
    });
  }

  Future<void> _initialize(String eventId) async {
    await ref
        .read(eventManageProvider(eventId).notifier)
        .fetchSelectedEvent(eventId);
    final event = ref.read(eventManageProvider(eventId));
    setState(() {
      isContestEvent = event.eventType == "contest";
    });
  }

  Future<void> updateEvent(Map<String, dynamic> data) async {
    await ref
        .read(eventManageProvider(eventId).notifier)
        .updateEventApi(context, data);
    final eventData = ref.read(eventManageProvider(eventId));
    ref
        .read(eventFeedProvider(_collegeId).notifier)
        .updateEvent(EventItem.fromEvent(eventData));
    setState(() {
      isContestEvent = eventData.eventType == "contest";
    });
    await ref.refresh(selectedEventProvider(eventId).future);
  }

  Future<void> createEvent(Map<String, dynamic> data) async {
    Event event = await createEventApi(context, data);
    ref
        .read(eventFeedProvider(_collegeId).notifier)
        .addEvent(EventItem.fromEvent(event));
    setState(() {
      eventId = event.id;
      isContestEvent = event.eventType == "contest";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color(0xffF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        title: Text(
          contestSteps[_currentStep],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 24),
          onPressed: () {
            if (_currentStep > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );
              setState(() {
                _currentStep--;
              });
            } else {
              Navigator.pop(context);
            }
          },
          padding: const EdgeInsets.all(8.0),
        ),
      ),
      body: Column(
        children: [
          processTimelinePage(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                BasicDetails(
                  key: _basicDetailsKey,
                  formData: widget.formData,
                  onSave: (details) {
                    eventData.clear();
                    eventData.addAll(details);
                  },
                ),
                RegistrationDetails(
                  key: _registrationDetailsKey,
                  eventId: eventId,
                  onSave: (details) {
                    eventData.clear();
                    eventData.addAll(details);
                  },
                ),
                EventDetailsForm(
                  key: _eventDetailsKey,
                  eventId: eventId,
                  onSave: (details) {
                    eventData.clear();
                    eventData.addAll(details);
                  },
                ),
                EventRoundForm(
                  key: _eventRoundKey,
                  eventId: eventId,
                  onSave: (details) {
                    eventData.clear();
                    eventData.addAll(details);
                  },
                ),
                PrizeForm(
                  key: _prizeFormKey,
                  eventId: eventId,
                  onSave: (details) {
                    eventData.clear();
                    eventData.addAll(details);
                  },
                ),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget processTimelinePage() {
    return SizedBox(
      height: 40,
      child: Timeline.tileBuilder(
        theme: TimelineThemeData(
          direction: Axis.horizontal,
          connectorTheme: const ConnectorThemeData(
            space: 12.0,
            thickness: 4.0,
          ),
        ),
        builder: TimelineTileBuilder.connected(
          itemCount: isContestEvent ? 5 : 3,
          connectionDirection: ConnectionDirection.before,
          connectorBuilder: (context, index, type) {
            return SolidLineConnector(
              color: getColor(index, _currentStep),
            );
          },
          indicatorBuilder: (context, index) {
            return DotIndicator(
              size: 32.0,
              color: getColor(index, _currentStep),
              child: index == _currentStep
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 1,
                    )
                  : Icon(
                      index < _currentStep ? Icons.check : Icons.circle,
                      color: Colors.white,
                      size: 12.0,
                    ),
            );
          },
          contentsBuilder: (context, index) {
            return SizedBox(width: isContestEvent ? 80 : 130);
          },
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              if (_currentStep > 0) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
                setState(() {
                  _currentStep--;
                });
              } else {
                Navigator.pop(context);
              }
            },
            child: Text(
              _currentStep == 0 ? 'Cancel' : 'Back',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            // iconAlignment: IconAlignment.end,
            onPressed: () async {
              bool isValid = false;
              // Validate and save data for the current step
              switch (_currentStep) {
                case 0:
                  isValid =
                      await _basicDetailsKey.currentState?.saveDetails() ??
                          false;
                  break;
                case 1:
                  isValid =
                      _registrationDetailsKey.currentState?.saveFormDetails() ??
                          false;
                  break;
                case 2:
                  isValid =
                      _eventDetailsKey.currentState?.saveDetails() ?? false;
                  break;
                case 3:
                  isValid = _eventRoundKey.currentState?.saveDetails() ?? false;
                  break;
                case 4:
                  isValid = _prizeFormKey.currentState?.saveDetails() ?? false;
                  break;
              }

              if (isValid) {
                print(eventData);
                if (eventId == "") {
                  await createEvent(eventData);
                } else {
                  eventData['_id'] = eventId;
                  await updateEvent(eventData);
                }
                if (eventData.containsKey('stepsDone') &&
                    eventData['stepsDone'] == 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Form Submitted Successfully!')),
                  );
                  Navigator.pop(context);
                }
                int totalSteps = isContestEvent ? 5 : 3;
                if (_currentStep < totalSteps - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                  setState(() {
                    _currentStep++;
                  });
                }
              }
            },
            child: Text(
              _currentStep == contestSteps.length - 1
                  ? 'Submit'
                  : 'Save & Continue',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
