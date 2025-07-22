import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:http/http.dart' as http;

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'https://www.googleapis.com/auth/calendar.events', // Required scope
  ],
);

Future<String?> authenticateUser() async {
  try {
    final GoogleSignInAccount? account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? auth = await account?.authentication;
    return auth?.accessToken; // Returns the access token
  } catch (e) {
    print("Authentication error: $e");
    return null;
  }
}

Future<String?> createGoogleMeetLink(String accessToken) async {
  final client = http.Client();
  final authenticatedClient = AuthenticatedClient(client, accessToken);

  final calendarApi = CalendarApi(authenticatedClient);

  final event = Event()
    ..summary = "Instant Meeting"
    ..start = EventDateTime(dateTime: DateTime.now().toUtc())
    ..end = EventDateTime(
        dateTime: DateTime.now().toUtc().add(const Duration(hours: 1)))
    ..conferenceData = ConferenceData(
      createRequest: CreateConferenceRequest(
        requestId: "unique-request-id",
        conferenceSolutionKey: ConferenceSolutionKey(type: "hangoutsMeet"),
      ),
    );

  try {
    final createdEvent = await calendarApi.events.insert(
      event,
      "primary",
      conferenceDataVersion: 1,
    );
    return createdEvent
        .conferenceData?.entryPoints?.first.uri; // Google Meet link
  } catch (e) {
    print("Error creating Google Meet link: $e");
    return null;
  } finally {
    client.close();
  }
}

class AuthenticatedClient extends http.BaseClient {
  final http.Client _inner;
  final String _accessToken;

  AuthenticatedClient(this._inner, this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _inner.send(request);
  }
}


  // Future<void> generateMeetLink() async {
  //   final accessToken = await authenticateUser();
  //   if (accessToken != null) {
  //     final meetLink = await createGoogleMeetLink(accessToken);
  //     if (meetLink != null) {
  //       print("Google Meet Link: $meetLink");
  //     } else {
  //       print("Failed to create Google Meet link.");
  //     }
  //   } else {
  //     print("Failed to authenticate user.");
  //   }
  // }