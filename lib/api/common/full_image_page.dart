import 'package:flutter/material.dart';

class FullImagePage extends StatefulWidget {
  final String url;
  final String? displayName;
  const FullImagePage({super.key, required this.url, this.displayName});

  @override
  State<FullImagePage> createState() => _FullImagePageState();
}

class _FullImagePageState extends State<FullImagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.displayName!),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
      ),
      body: Center(
          child: Image.network(
        widget.url,
      )),
    );
  }
}
