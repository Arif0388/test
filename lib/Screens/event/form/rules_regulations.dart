import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/api/provider/event_manage_provider.dart';

final GlobalKey<FormState> eventDetailsKey = GlobalKey<FormState>();

class EventDetailsForm extends ConsumerStatefulWidget {
  final String eventId;
  final Function(Map<String, dynamic>) onSave;

  const EventDetailsForm(
      {super.key, required this.eventId, required this.onSave});

  @override
  ConsumerState<EventDetailsForm> createState() => EventDetailsFormState();
}

class EventDetailsFormState extends ConsumerState<EventDetailsForm> {
  final List<TextEditingController> _rulesControllers = [];
  final TextEditingController _descriptionController = TextEditingController();

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
      _descriptionController.text = eventData.description;
      if (eventData.guidelines.isNotEmpty) {
        for (int i = 0; i < eventData.guidelines.length; i++) {
          _rulesControllers.add(TextEditingController());
          _rulesControllers[i].text = eventData.guidelines[i].guideline;
        }
      } else {
        // Initialize the controllers
        _rulesControllers.add(TextEditingController());
      }
    });
  }

  /// Method to save the form data
  bool saveDetails() {
    final event = ref.watch(eventManageProvider(widget.eventId));
    if (eventDetailsKey.currentState?.validate() ?? false) {
      // Collect the form data
      List<Map<String, String>> rules = _rulesControllers
          .map((controller) => {"guideline": controller.text})
          .where((rule) => rule.isNotEmpty)
          .toList();

      String description = _descriptionController.text;

      // Prepare the data to send to the parent
      Map<String, dynamic> formData = {
        'description': description,
        'guidelines': rules,
        if (event.eventType == "entertainment") 'stepsDone': 6
      };

      // Call the parent's onSave method
      widget.onSave(formData);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: eventDetailsKey,
        child: ListView(
          children: [
            const Text(
              'Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              minLines: 3,
              decoration: InputDecoration(
                hintText:
                    'This field helps you to mention the details of the opportunity you are listing. '
                    'It is better to include rules, eligibility, process, format, etc. In order to get the opportunity approved. The more details, the better!',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Rules & Guidelines',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _rulesControllers.add(TextEditingController());
                    });
                  },
                  icon: const Icon(Icons.add_circle),
                  alignment: const AlignmentDirectional(1, 1),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Display rules fields
            Column(
              children: _rulesControllers.asMap().entries.map((entry) {
                int index = entry.key;
                TextEditingController controller = entry.value;
                return Padding(
                  key: ValueKey(index),
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TextFormField(
                    controller: controller,
                    maxLines: 2,
                    minLines: 1,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _rulesControllers.removeAt(index);
                          });
                        },
                        icon: const Icon(Icons.cancel),
                      ),
                      labelText: 'Add Rules & Guidelines',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Rule is required';
                      }
                      return null;
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    for (var controller in _rulesControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
