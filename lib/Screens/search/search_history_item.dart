import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HistoryWidget extends StatefulWidget {
  final String query;
  final void Function(String) onRemoved;
  const HistoryWidget(
      {super.key, required this.query, required this.onRemoved});

  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      child: Stack(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.only(left: 10),
            leading: const Icon(
              Icons.history,
              size: 24,
            ),
            title: Text(widget.query),
            onTap: () {
              context.push("/search?query=${widget.query}");
            },
          ),
          Positioned(
            right: 8.0,
            bottom: 8.0,
            child: IconButton(
              icon: const Icon(Icons.close, size: 24),
              onPressed: () async {
                widget.onRemoved(widget.query);
              },
            ),
          )
        ],
      ),
    );
  }
}
