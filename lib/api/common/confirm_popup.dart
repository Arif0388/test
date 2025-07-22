import 'package:flutter/material.dart';

Future<void> confirmPopup(
    BuildContext context, Future<void> Function() onConfirm, String type) async {
  try {
    // Use a boolean to track the dialog state
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Are you sure?"),
          content: Text("Do you want to $type?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Use dialogContext to pop
              },
            ),
            TextButton(
              child: Text(type),
              onPressed: () async {
                await onConfirm();
                Navigator.of(dialogContext).pop(); // Use dialogContext to pop
              },
            ),
          ],
        );
      },
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: ${e.toString()}")),
    );
  }
}
