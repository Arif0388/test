import 'package:googleapis/calendar/v3.dart';
import 'package:http/http.dart' as http;

Future<void> addToCalendar(String accessToken) async {
  final client = http.Client();
  final authenticatedClient = AuthenticatedClient(client, accessToken);

  final calendarApi = CalendarApi(authenticatedClient);

  final event = Event()
    ..summary = "Team Meeting" // Event title
    ..description = "Discussion about project updates" // Event description
    ..start = EventDateTime(
      dateTime: DateTime.now().toUtc(),
      timeZone: "UTC",
    )
    ..end = EventDateTime(
      dateTime: DateTime.now().toUtc().add(const Duration(hours: 1)),
      timeZone: "UTC",
    )
    ..conferenceData = ConferenceData(
      createRequest: CreateConferenceRequest(
        requestId: "unique-request-id",
        conferenceSolutionKey: ConferenceSolutionKey(type: "hangoutsMeet"),
      ),
    );

  try {
    final createdEvent = await calendarApi.events.insert(
      event,
      "primary", // Add to the user's primary calendar
      conferenceDataVersion: 1, // Required to generate Google Meet link
    );

    print("Event created: ${createdEvent.htmlLink}"); // Link to the event in the user's calendar
  } catch (e) {
    print("Error adding event to calendar: $e");
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
