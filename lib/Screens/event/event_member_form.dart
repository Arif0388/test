import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventMemberFormCard extends ConsumerStatefulWidget {
  final TextEditingController memberNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController collegeController;
  final TextEditingController descriptionController;

  const EventMemberFormCard({
    super.key,
    required this.memberNameController,
    required this.emailController,
    required this.phoneController,
    required this.collegeController,
    required this.descriptionController,
  });

  @override
  ConsumerState<EventMemberFormCard> createState() => _MemberFormState();
}

class _MemberFormState extends ConsumerState<EventMemberFormCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Team Member',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue, // Change color as needed
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Name* -',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue, // Change color as needed
              ),
            ),
            TextFormField(
              controller: widget.memberNameController,
              decoration: const InputDecoration(
                hintText: 'Name',
                hintStyle: TextStyle(fontSize: 15),
              ),
              keyboardType: TextInputType.text,
              maxLength: 50,
            ),
            const Text(
              'Email* -',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue, // Change color as needed
              ),
            ),
            TextFormField(
              controller: widget.emailController,
              decoration: const InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(fontSize: 15),
              ),
              keyboardType: TextInputType.emailAddress,
              maxLength: 50,
            ),
            const Text(
              'Contact no.* -',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue, // Change color as needed
              ),
            ),
            TextFormField(
              controller: widget.phoneController,
              decoration: const InputDecoration(
                hintText: 'Contact number',
                hintStyle: TextStyle(fontSize: 15),
              ),
              keyboardType: TextInputType.phone,
              maxLength: 10,
            ),
            const Text(
              'College Name* -',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue, // Change color as needed
              ),
            ),
            TextFormField(
              controller: widget.collegeController,
              decoration: const InputDecoration(
                hintText: 'College Name',
                hintStyle: TextStyle(fontSize: 15),
              ),
              keyboardType: TextInputType.text,
              maxLength: 50,
            ),
            const Text(
              'Other details* -',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue, // Change color as needed
              ),
            ),
            TextFormField(
              controller: widget.descriptionController,
              decoration: const InputDecoration(
                hintText: 'like 2nd year B.tech student',
                hintStyle: TextStyle(fontSize: 15),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }
}
