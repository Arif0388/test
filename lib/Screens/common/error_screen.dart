import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorScreen extends StatefulWidget {
  final String errMsg;
  const ErrorScreen({super.key, required this.errMsg});

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Page not Found"),
          backgroundColor: const Color.fromARGB(255, 211, 232, 255),
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
          elevation: 0,
        ),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            widget.errMsg,
          ),
          const SizedBox(
            height: 16,
          ),
          OutlinedButton(
              onPressed: () {
                context.go("/home");
              },
              child: const Text("Go to Home"))
        ])));
  }
}
