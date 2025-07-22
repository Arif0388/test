import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/club/about/faqs_form_item.dart';
import 'package:learningx_flutter_app/api/provider/club_provider.dart';

class ClubForm3Screen extends ConsumerStatefulWidget {
  final String clubId;
  const ClubForm3Screen({super.key, required this.clubId});

  @override
  ConsumerState<ClubForm3Screen> createState() => _ClubForm3State();
}

class _ClubForm3State extends ConsumerState<ClubForm3Screen> {
  var faqSize = 3;
  List<TextEditingController> questionControllers = [];
  List<TextEditingController> answerControllers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final clubData = ref.watch(selectedClubProvider(widget.clubId));
      setState(() {
        if (clubData.faqs != null) {
          faqSize = clubData.faqs!.length;
          for (int i = 0; i < faqSize; i++) {
            questionControllers.add(TextEditingController());
            answerControllers.add(TextEditingController());
            questionControllers[i].text = clubData.faqs![i].question;
            answerControllers[i].text = clubData.faqs![i].answer;
          }
        } else {
          // Initialize the controllers
          for (int i = 0; i < faqSize; i++) {
            questionControllers.add(TextEditingController());
            answerControllers.add(TextEditingController());
          }
        }
      });
    });
  }

  void addFaqClicked() {
    setState(() {
      faqSize += 1;
      questionControllers.add(TextEditingController());
      answerControllers.add(TextEditingController());
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added!')),
    );
  }

  void nextBtnClicked() async {
    // Collect data from text controllers
    List<Map<String, String>> faqs = [];
    for (int i = 0; i < faqSize; i++) {
      faqs.add({
        'question': questionControllers[i].text,
        'answer': answerControllers[i].text,
      });
    }
    Map<String, dynamic> data = HashMap();
    data['faqs'] = faqs;
    data['_id'] = widget.clubId;
    await ref
        .read(selectedClubProvider(widget.clubId).notifier)
        .updateClubApi(context, data);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Club updated!')),
    );
  }

  @override
  void dispose() {
    for (var controller in questionControllers) {
      controller.dispose();
    }
    for (var controller in answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Text("FAQs"),
              const Spacer(),
              ElevatedButton(
                onPressed: addFaqClicked,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Add one more..',
                  style: TextStyle(
                    fontSize: 12.0,
                    textBaseline: TextBaseline.alphabetic,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 211, 232, 255),
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: faqSize,
                    itemBuilder: (BuildContext context, int index) {
                      return QuestionAnswerWidget(
                        index: index,
                        questionController: questionControllers[index],
                        answerController: answerControllers[index],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.skip_next,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  label: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: nextBtnClicked,
                  icon: const Icon(
                    Icons.navigate_next,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  label: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
