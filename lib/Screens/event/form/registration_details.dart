// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:learningx_flutter_app/api/provider/event_manage_provider.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';

class RegistrationDetails extends ConsumerStatefulWidget {
  final String eventId;
  final Function(Map<String, dynamic>) onSave; // Callback to pass form data

  const RegistrationDetails(
      {super.key, required this.eventId, required this.onSave});

  @override
  ConsumerState<RegistrationDetails> createState() =>
      RegistrationDetailsState();
}

class RegistrationDetailsState extends ConsumerState<RegistrationDetails> {
  final GlobalKey<FormState> registrationDetailsKey = GlobalKey<FormState>();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();

  String startDate = DateFormat('dd MMM yyyy HH:mm:ss').format(DateTime.now());
  String startIsoDate = DateTime.now().toUtc().toIso8601String();
  String endDate = DateFormat('dd MMM yyyy HH:mm:ss').format(DateTime.now());
  String endIsoDate = DateTime.now().toUtc().toIso8601String();
  String registrationCharge = "free";
  String participation = "individual";

  String currentVisibilityOption = 'public';
  bool currentRegistrationOption = true;
  String currentPlatformOption = 'on';

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
      currentVisibilityOption =
          (eventData.college != null && eventData.visibility == "private")
              ? "public"
              : eventData.visibility;
      currentRegistrationOption = eventData.takeRegistration;
      currentPlatformOption = eventData.registrationPlace;
      _linkController.text = eventData.registrationLink;
      startDate = DateFormat('dd MMM yyyy HH:mm:ss')
          .format(eventData.registrationStartedAtDate.toLocal());
      startIsoDate = eventData.registrationStartDate;
      _startDateController.text = startDate;
      endDate = DateFormat('dd MMM yyyy HH:mm:ss')
          .format(eventData.registrationEndedAtDate.toLocal());
      endIsoDate = eventData.registrationEndDate;
      _endDateController.text = endDate;
      participation = eventData.participation;
      _feeController.text = eventData.registrationFee.toString();
      registrationCharge = eventData.registrationCharge;
      _minController.text = eventData.minSizeTeam.toString();
      _maxController.text = eventData.maxSizeTeam.toString();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
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
            startDate = Utils.formatDate(pickedDateTime);
            startIsoDate = pickedDateTime.toUtc().toIso8601String();
            _startDateController.text = startDate;
          } else {
            endDate = Utils.formatDate(pickedDateTime);
            endIsoDate = pickedDateTime.toUtc().toIso8601String();
            _endDateController.text = endDate;
          }
        });
      }
    }
  }

  bool saveFormDetails() {
    if (registrationDetailsKey.currentState?.validate() ?? false) {
      final formData = {
        'visibility': currentVisibilityOption,
        'takeRegistration': currentRegistrationOption,
        'registrationPlace': currentPlatformOption,
        'registrationLink': _linkController.text,
        'participation': participation,
        'registrationStartDate': startIsoDate,
        'registrationEndDate': endIsoDate,
        'minSizeTeam': int.tryParse(_minController.text) ?? 1,
        'maxSizeTeam': int.tryParse(_maxController.text) ?? 1,
        'registrationCharge': registrationCharge,
        'registrationFee': int.tryParse(_feeController.text) ?? 0,
      };

      // Pass the form data to the parent widget
      widget.onSave(formData);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final eventData = ref.watch(eventManageProvider(widget.eventId));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: registrationDetailsKey,
        child: ListView(
          children: [
            if (eventData.college != null) const Text('Visibility'),
            if (eventData.college != null)
              Row(
                children: [
                  Radio(
                    value: 'public',
                    groupValue: currentVisibilityOption,
                    onChanged: (value) {
                      setState(() {
                        currentVisibilityOption = value!;
                      });
                      saveFormDetails();
                    },
                  ),
                  const Text('Public'),
                  Radio(
                    value: 'college',
                    groupValue: currentVisibilityOption,
                    onChanged: (value) {
                      setState(() {
                        currentVisibilityOption = value!;
                      });
                      saveFormDetails();
                    },
                  ),
                  const Text('Only in Campus'),
                ],
              ),
            const SizedBox(height: 8),
            const Text('Take registrations for this Event?'),
            Row(
              children: [
                Radio(
                  value: true,
                  groupValue: currentRegistrationOption,
                  onChanged: (value) {
                    setState(() {
                      currentRegistrationOption = value!;
                    });
                    saveFormDetails();
                  },
                ),
                const Text('Yes'),
                Radio(
                  value: false,
                  groupValue: currentRegistrationOption,
                  onChanged: (value) {
                    setState(() {
                      currentRegistrationOption = value!;
                    });
                    saveFormDetails();
                  },
                ),
                const Text('No'),
              ],
            ),
            if (currentRegistrationOption)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Registration Platform?'),
                  Row(
                    children: [
                      Radio(
                        value: 'out',
                        groupValue: currentPlatformOption,
                        onChanged: (value) {
                          setState(() {
                            currentPlatformOption = value!;
                          });
                          saveFormDetails();
                        },
                      ),
                      const Text('External Platform'),
                      Radio(
                        value: 'on',
                        groupValue: currentPlatformOption,
                        onChanged: (value) {
                          setState(() {
                            currentPlatformOption = value!;
                          });
                          saveFormDetails();
                        },
                      ),
                      const Text('On App'),
                    ],
                  ),
                  if (currentPlatformOption == "out")
                    TextFormField(
                      controller: _linkController,
                      decoration: const InputDecoration(
                        labelText: 'Registration Link',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => saveFormDetails(),
                    ),
                  const SizedBox(height: 8),
                  const Text('Registration Start Date'),
                  TextFormField(
                    controller: _startDateController,
                    onTap: () => _selectDate(context, true),
                    decoration: const InputDecoration(
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
                  const Text('Registration End Date'),
                  TextFormField(
                    controller: _endDateController,
                    onTap: () => _selectDate(context, false),
                    decoration: const InputDecoration(
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
                  const Text('Does the event have a participation fee?'),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: registrationCharge,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: ['free', 'paid']
                        .map((label) => DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        registrationCharge = value.toString();
                      });
                    },
                    elevation: 4,
                  ),
                  const SizedBox(height: 8),
                  if (registrationCharge == "paid")
                    const Text('Participation Fee'),
                  if (registrationCharge == "paid") const SizedBox(height: 4),
                  if (registrationCharge == "paid")
                    TextFormField(
                      controller: _feeController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  const SizedBox(height: 8),
                  const Text('Participation Type'),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: participation,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: ['individual', 'team']
                        .map((label) => DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        participation = value.toString();
                      });
                    },
                    elevation: 4,
                  ),
                  const SizedBox(height: 8),
                  if (participation == "team")
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _minController,
                            decoration: const InputDecoration(
                              labelText: 'Team Size Min',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.elliptical(10, 10),
                                  bottomLeft: Radius.elliptical(10, 10),
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _maxController,
                            decoration: const InputDecoration(
                              labelText: 'Team Size Max',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.elliptical(10, 10),
                                  bottomRight: Radius.elliptical(10, 10),
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
