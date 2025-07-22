import 'package:flutter/material.dart';

class AccordionWidget extends StatefulWidget {
  final String question;
  final String answer;

  const AccordionWidget({super.key, required this.question, required this.answer});

  @override
  State<AccordionWidget> createState() => _AccordionWidgetState();
}

class _AccordionWidgetState extends State<AccordionWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          child: Row(
            children: [
              Icon(
                _expanded
                    ? Icons.keyboard_arrow_down
                    : Icons.keyboard_arrow_right,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Visibility(
          visible: _expanded,
          child: Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Text(
              widget.answer,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8,)
      ],
    );
  }
}
