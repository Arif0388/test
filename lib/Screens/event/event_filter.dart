import 'package:flutter/material.dart';

class EventFiltersScreen extends StatelessWidget {
  const EventFiltersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Filters'),
          backgroundColor: const Color.fromARGB(255, 211, 232, 255),
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
          elevation: 0,
        ),
        body: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 1),
              Divider(height: 1, color: Colors.black),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event type :- ',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    Row(
                      children: [
                        Radio(value: 0, groupValue: 0, onChanged: null),
                        Text('All'),
                        Radio(value: 1, groupValue: 0, onChanged: null),
                        Text('Contest'),
                        Radio(value: 2, groupValue: 0, onChanged: null),
                        Text('Entertainment'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Payment :- ',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    Row(
                      children: [
                        Radio(value: 0, groupValue: 0, onChanged: null),
                        Text('All'),
                        Radio(value: 1, groupValue: 0, onChanged: null),
                        Text('Paid'),
                        Radio(value: 2, groupValue: 0, onChanged: null),
                        Text('Free'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Location :- ',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    Row(
                      children: [
                        Radio(value: 0, groupValue: 0, onChanged: null),
                        Text('All'),
                        Radio(value: 1, groupValue: 0, onChanged: null),
                        Text('Online'),
                        Radio(value: 2, groupValue: 0, onChanged: null),
                        Text('Offline'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Team size :- ',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    Row(
                      children: [
                        Radio(value: 0, groupValue: 0, onChanged: null),
                        Text('All'),
                        Radio(value: 1, groupValue: 0, onChanged: null),
                        Text('1'),
                        Radio(value: 2, groupValue: 0, onChanged: null),
                        Text('2'),
                        Radio(value: 3, groupValue: 0, onChanged: null),
                        Text('2+'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Eligibility',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RadioListTile(
                          value: 0,
                          groupValue: 0,
                          onChanged: null,
                          title: Text('Everyone'),
                        ),
                        RadioListTile(
                          value: 1,
                          groupValue: 0,
                          onChanged: null,
                          title: Text('College Students'),
                        ),
                        RadioListTile(
                          value: 2,
                          groupValue: 0,
                          onChanged: null,
                          title: Text('Only female'),
                        ),
                        RadioListTile(
                          value: 3,
                          groupValue: 0,
                          onChanged: null,
                          title: Text('Only male'),
                        ),
                        RadioListTile(
                          value: 4,
                          groupValue: 0,
                          onChanged: null,
                          title: Text('Professionals'),
                        ),
                        RadioListTile(
                          value: 5,
                          groupValue: 0,
                          onChanged: null,
                          title: Text('School Students'),
                        ),
                        RadioListTile(
                          value: 6,
                          groupValue: 0,
                          onChanged: null,
                          title: Text('Startups'),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Category',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      children: [
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Article Writing')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Coding challenge')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('College festival')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Conclave')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Conference')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Dance')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Data Analytics')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Data science')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Debates')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Designing')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Dj concert')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Dramatics')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Entrepreneurship')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Fashion')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Fellowship')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Finance')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Hackathon')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Human Resource')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Literary')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Marketing')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Music')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Online trading')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Panel discussion')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Poetry')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Photography')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Presentation')),
                        CheckboxListTile(
                            value: false, onChanged: null, title: Text('Quiz')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Robotics')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Scholarship')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Social Media & Digital')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Sports')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Stand-up comedy')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Startup fair')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Treasure hunt')),
                        CheckboxListTile(
                            value: false,
                            onChanged: null,
                            title: Text('Workshop')),
                      ],
                    ),
                    SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  child: const Text('Reset Filter',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.blue),
                  ),
                  child: const Text('Apply',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ));
  }
}
