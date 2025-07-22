import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/api/provider/user_provider.dart';

class ActivateAccount extends StatelessWidget {
  final String id;
  const ActivateAccount({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Activate Your Account"),
            backgroundColor: const Color.fromARGB(255, 211, 232, 255),
            titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18)),
        body: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(top: 80),
            child: Column(children: [
              const Text(
                  "You have closed your Account, To Login in your Account. You must Activate. You have 15 days from closing day to reopen your account. Please click on Activate button below."),
              Padding(
                padding: const EdgeInsets.only(top: 32, left: 8, right: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      textStyle: WidgetStateProperty.all(
                          const TextStyle(fontSize: 13)),
                      backgroundColor: WidgetStateProperty.all(
                          Colors.blue), // Active button background color
                      foregroundColor: WidgetStateProperty.all(
                          Colors.white), // Active button text color
                    ),
                    onPressed: () async {
                      await activateAccountApi(context, id);
                    },
                    child: const Text(
                      'Activate Account',
                    ),
                  ),
                ),
              ),
            ])));
  }
}
