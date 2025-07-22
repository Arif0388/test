import 'package:url_launcher/url_launcher.dart';

class LaunchUrl {
  static Future<void> openUrl(String data) async {
    if (!data.contains("https")) {
      data = "https://$data";
    }
    final Uri url = Uri.parse(data);
    if (!await launchUrl(
      url,
    )) {
      throw Exception('Could not launch $url');
    }
  }
}
