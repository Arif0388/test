import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/api/common/launch_url.dart';

class LaunchUrlScreen extends StatelessWidget {
  final String url;

  const LaunchUrlScreen({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LaunchUrl.openUrl(url);
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
