import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthDialog {
  static void showUnauthDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("You need to be signed in to do that."),
          content: const Text("Please either login or register to Club-Chat."),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Go to Login Page"),
              onPressed: () async {
                context.go("/apps");
              },
            ),
          ],
        );
      },
    );
  }
}
