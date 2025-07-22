import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/api/provider/event_manage_provider.dart';

final GlobalKey<FormState> prizeKey = GlobalKey<FormState>();

class PrizeForm extends ConsumerStatefulWidget {
  final String eventId;
  final Function(Map<String, dynamic>) onSave;

  const PrizeForm({super.key, required this.eventId, required this.onSave});

  @override
  ConsumerState<PrizeForm> createState() => PrizeFormState();
}

class PrizeFormState extends ConsumerState<PrizeForm> {
  final TextEditingController totalRewardsController = TextEditingController();
  final List<TextEditingController> rankControllers = [];
  final List<TextEditingController> prizeMoneyControllers = [];
  final List<TextEditingController> additionalInfoControllers = [];
  final List<bool> certificateFlags = [];
  final List<Widget> prizeCards = [];
  bool participationCertificate = false;

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
      totalRewardsController.text = eventData.totalRewards;
      participationCertificate = eventData.partCertificate;

      if (eventData.rewards != null && prizeCards.isEmpty) {
        for (int index = 0; index < eventData.rewards!.length; index++) {
          _addNewCard();
          rankControllers[index].text = eventData.rewards![index].rank;
          prizeMoneyControllers[index].text =
              eventData.rewards![index].money.toString();
          additionalInfoControllers[index].text =
              eventData.rewards![index].otherDetails;
          certificateFlags[index] = eventData.rewards![index].certificate;
        }
      }
    });
  }

  /// Method to save all prize details
  bool saveDetails() {
    if (prizeKey.currentState!.validate()) {
      final rewards = List.generate(rankControllers.length, (index) {
        return {
          'rank': rankControllers[index].text,
          'certificate': certificateFlags[index],
          'money': int.tryParse(prizeMoneyControllers[index].text) ?? 0,
          'otherDetails': additionalInfoControllers[index].text,
        };
      });

      final data = {
        'totalRewards': totalRewardsController.text,
        'partCertificate': participationCertificate,
        'rewards': rewards,
        'stepsDone': 6
      };

      widget.onSave(data); // Pass the saved data to the parent widget
      return true;
    }
    return false;
  }

  /// Add a new prize card
  void _addNewCard() {
    setState(() {
      rankControllers.add(TextEditingController());
      prizeMoneyControllers.add(TextEditingController());
      additionalInfoControllers.add(TextEditingController());
      certificateFlags.add(false);
    });
  }

  /// Remove a prize card at a specific index
  void _removeCard(int index) {
    setState(() {
      rankControllers.removeAt(index);
      prizeMoneyControllers.removeAt(index);
      additionalInfoControllers.removeAt(index);
      certificateFlags.removeAt(index);
    });
  }

  /// Build a single prize card
  Widget _buildPrizeCard({required int index}) {
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
                Text("Reward ${index + 1}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w400)),
                IconButton(
                  onPressed: () => _removeCard(index),
                  icon: const Icon(Icons.delete, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: rankControllers[index],
                    decoration: InputDecoration(
                      labelText: 'Rank',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a rank';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    Checkbox(
                      value: certificateFlags[index],
                      onChanged: (bool? newValue) {
                        setState(() {
                          certificateFlags[index] = newValue ?? false;
                        });
                      },
                    ),
                    const Text("Certificate"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Prize Money Field
            TextFormField(
              controller: prizeMoneyControllers[index],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Prize Money',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Prize money is required';
                }
                if (double.tryParse(value) == null) {
                  return 'Enter a valid number';
                }
                if (double.parse(value) < 0) {
                  return 'Prize money cannot be negative';
                }
                return null;
              },
            ),

            const SizedBox(height: 8),
            // Additional Info Field
            TextFormField(
              controller: additionalInfoControllers[index],
              decoration: const InputDecoration(
                labelText: 'Additional Info',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: prizeKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            const Text(
              "Total Rewards",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: totalRewardsController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter total rewards',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Total rewards are required';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            const Text(
              "Participation Certificate",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<bool>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              value: participationCertificate,
              items: const [
                DropdownMenuItem(value: true, child: Text('Yes')),
                DropdownMenuItem(value: false, child: Text('No')),
              ],
              onChanged: (value) {
                setState(() {
                  participationCertificate = value!;
                });
              },
            ),
            const SizedBox(height: 8),
            Column(
              children: List.generate(
                rankControllers.length,
                (index) => _buildPrizeCard(index: index),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _addNewCard,
              child: const Text('Add Reward'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    totalRewardsController.dispose();
    for (var controller in rankControllers) {
      controller.dispose();
    }
    for (var controller in prizeMoneyControllers) {
      controller.dispose();
    }
    for (var controller in additionalInfoControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
