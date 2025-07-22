import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learningx_flutter_app/Screens/auth/sign_in.dart';
import 'package:learningx_flutter_app/Screens/chats/chat_page.dart';
import 'package:learningx_flutter_app/Screens/club/about/club_about_activity.dart';
import 'package:learningx_flutter_app/Screens/club/channel/channel_details.dart';
import 'package:learningx_flutter_app/Screens/club/channel/channel_member_page.dart';
import 'package:learningx_flutter_app/Screens/club/club_member_page.dart';
import 'package:learningx_flutter_app/Screens/college/college_page.dart';
import 'package:learningx_flutter_app/Screens/common/download_app.dart';
import 'package:learningx_flutter_app/Screens/common/error_screen.dart';
import 'package:learningx_flutter_app/Screens/common/launch_url_screen.dart';
import 'package:learningx_flutter_app/Screens/council/council_page.dart';
import 'package:learningx_flutter_app/Screens/event/event_info/event_info_page.dart';
import 'package:learningx_flutter_app/Screens/extra/upcoming_reminder.dart';
import 'package:learningx_flutter_app/Screens/fest/fest_page.dart';
import 'package:learningx_flutter_app/Screens/home/home_page.dart';
import 'package:learningx_flutter_app/Screens/home/notification_feed.dart';
import 'package:learningx_flutter_app/Screens/home/post_feed.dart';
import 'package:learningx_flutter_app/Screens/post/post_comment_page.dart';
import 'package:learningx_flutter_app/Screens/post/single_post_screen.dart';
import 'package:learningx_flutter_app/Screens/profile/profile_page.dart';
import 'package:learningx_flutter_app/Screens/search/search_detail_page.dart';
import 'package:learningx_flutter_app/Screens/search/search_screen.dart';
import 'package:learningx_flutter_app/api/common/launch_url.dart';
import 'package:learningx_flutter_app/api/model/channel_model.dart';
import 'package:learningx_flutter_app/api/model/chat_room_model.dart';
import 'package:learningx_flutter_app/api/model/club_model.dart';
import 'package:learningx_flutter_app/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:universal_html/html.dart' as html;
import 'Screens/home/splash_screen.dart';
import 'Screens/profile/profile_screen.dart';

//flutter run -d chrome --web-hostname localhost --web-port 7357

Future main() async {
  await dotenv.load(fileName: "development.env");

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  usePathUrlStrategy(); // This will remove the '#' from the URL
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const platform =
      MethodChannel('in.learningx.flutterApp/notifications');

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      String userAgent = getSmartPhoneOrTablet();
      if (userAgent == "desktop") {
        html.window.location.assign("https://www.clubchat.live");
      }
    } else {
      if (Platform.isIOS) {
        clearBadgeCount();
      }
    }
    clearAllNotifications();
  }

  final String appleType = "apple";
  final String androidType = "android";
  final String desktopType = "desktop";

  String getSmartPhoneOrTablet() {
    String userAgent = html.window.navigator.userAgent.toString().toLowerCase();
    // smartphone
    if (userAgent.contains("iphone")) return appleType;
    if (userAgent.contains("android")) return androidType;

    // tablet
    if (userAgent.contains("ipad")) return appleType;
    if (html.window.navigator.platform!.toLowerCase().contains("macintel") &&
        html.window.navigator.maxTouchPoints! > 0) return appleType;

    return desktopType;
  }

  void clearAllNotifications() {
    AwesomeNotifications().cancelAll();
  }

  Future<void> clearBadgeCount() async {
    try {
      await platform.invokeMethod('clearBadgeCount');
    } on PlatformException catch (e) {
      print("Failed to clear badge count: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: "/",
      routes: [
        GoRoute(
          path: '/profile2/:id',
          builder: (context, state) => ProfileScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const SignIn(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) {
            return const MyHomePage();
          },
        ),
        GoRoute(
          path: '/home/:id',
          builder: (context, state) {
            return const MyHomePage();
          },
        ),
        GoRoute(
          path: '/feed',
          builder: (context, state) {
            return const FeedScreen();
          },
        ),
        GoRoute(
          path: '/profile/:id',
          builder: (context, state) =>
              ProfileActivity(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/posts/:id',
          builder: (context, state) =>
              SinglePostScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/posts/:id/comments',
          builder: (context, state) =>
              CommentActivity(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/college/:id',
          builder: (context, state) =>
              CollegeActivity(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/club/fest/:id',
          builder: (context, state) =>
              CollegeFestActivity(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/council/:id',
          builder: (context, state) =>
              CouncilPage(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/club/about/:id',
          builder: (context, state) =>
              AboutClubScreen(clubId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/club/:id/about/:channelId',
          builder: (context, state) =>
              AboutClubScreen(clubId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/club/member/:id',
          builder: (context, state) {
            // Check if 'extra' is missing or is not the correct type
            if (state.extra == null || state.extra is! Map<String, dynamic>) {
              return const ErrorScreen(
                errMsg: "Something went wrong.",
              );
            }

            // Extract values from extra safely
            final Map<String, dynamic> extras =
                state.extra as Map<String, dynamic>;

            // Handle missing parameters in extra
            if (!extras.containsKey('isAdmin')) {
              return const ErrorScreen(
                errMsg: "Incomplete Club data provided.",
              );
            }

            // Proceed if all data is available
            final bool isAdmin = extras['isAdmin'];

            return ClubMemberActivity(
              id: state.pathParameters['id']!,
              isAdmin: isAdmin,
            );
          },
        ),
        GoRoute(
          path: '/channel/member/:id',
          builder: (context, state) {
            // Check if 'extra' is missing or is not the correct type
            if (state.extra == null || state.extra is! Map<String, dynamic>) {
              return const ErrorScreen(
                errMsg: "Something went wrong.",
              );
            }

            // Extract values from extra safely
            final Map<String, dynamic> extras =
                state.extra as Map<String, dynamic>;

            // Handle missing parameters in extra
            if (!extras.containsKey('channel') ||
                !extras.containsKey('clubName')) {
              return const ErrorScreen(
                errMsg: "Incomplete Channel data provided.",
              );
            }

            // Proceed if all data is available
            final Channel channel = extras['channel'];
            final String clubName = extras['clubName'];

            return ChannelMemberActivity(
              channel: channel,
              clubName: clubName,
            );
          },
        ),
        GoRoute(
          path: '/club/:id/discussion/:channelId',
          builder: (context, state) {
            // Check if 'extra' is null or if it's not the correct type
            if (state.extra == null || state.extra is! Map<String, dynamic>) {
              return const ErrorScreen(
                errMsg: "Discussion details not available. Please try again.",
              );
            }

            // Extract values from extra safely
            final Map<String, dynamic> extras =
                state.extra as Map<String, dynamic>;

            // Handle missing parameters in extra
            if (!extras.containsKey('channel') ||
                !extras.containsKey('clubItem')) {
              return const ErrorScreen(
                errMsg: "Incomplete discussion data provided.",
              );
            }

            // Proceed if all data is available
            final Channel channel = extras['channel'];
            final ClubItem clubItem = extras['clubItem'];

            return ChannelInfoScreen(
              channel: channel,
              clubItem: clubItem,
            );
          },
        ),
        GoRoute(
          path: '/events/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final Function? onRemove = state.extra as Function?;
            return EventInfoActivity(id: id, onRemove: onRemove);
          },
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) {
            return const NotificationScreen();
          },
        ),
        GoRoute(
          path: '/chats/:id',
          builder: (context, state) {
            // Check if 'extra' is missing or is not the correct type
            if (state.extra == null || state.extra is! Map<String, dynamic>) {
              return const ErrorScreen(
                errMsg: "Chat details not available. Please try again.",
              );
            }

            // Extract values from extra safely
            final Map<String, dynamic> extras =
                state.extra as Map<String, dynamic>;

            // Handle missing parameters in extra
            if (!extras.containsKey('chatRoom') ||
                !extras.containsKey('receiverAtIndex') ||
                !extras.containsKey('senderAtIndex')) {
              return const ErrorScreen(
                errMsg: "Incomplete chat data provided.",
              );
            }

            // Proceed if all data is available
            final ChatRoom chatRoom = extras['chatRoom'];
            final int receiverAtIndex = extras['receiverAtIndex'];
            final int senderAtIndex = extras['senderAtIndex'];

            return ChatActivity(
              chatRoom: chatRoom,
              receiverAtIndex: receiverAtIndex,
              senderAtIndex: senderAtIndex,
            );
          },
        ),
        GoRoute(
          path: '/reminder',
          builder: (context, state) => const UpcomingReminderScreen(),
        ),
        GoRoute(
          path: '/privacy-policy',
          builder: (context, state) => const LaunchUrlScreen(
            url: "https://www.clubchat.live/privacy-policy",
          ),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) {
            final query = state.uri.queryParameters['query'];
            if (query == null || query.isEmpty) {
              return const SearchActivity();
            } else {
              return SearchPageActivity(query: query);
            }
          },
        ),
        GoRoute(
            path: '/error',
            builder: (context, state) => const ErrorScreen(
                  errMsg: "Something went wrong!",
                )),
        GoRoute(
            path: '/download/apps',
            builder: (context, state) => const DownloadApp()),
      ],
      redirect: (context, state) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

        // Extract the current path from the state
        final currentPath = state.uri.toString();

        // If the user is not logged in and is trying to access any page other than '/', '/events/:id', or '/club/about/:id', redirect to '/'
        final isGoingToLogin = currentPath == '/';
        final isGoingToSignIn = currentPath == '/login';
        final isGoingToDownload = currentPath == '/download/apps';
        final isGoingToCollege =
            RegExp(r'^/college/[\w-]+$').hasMatch(currentPath);
        final isGoingToEvent =
            RegExp(r'^/events/[\w-]+$').hasMatch(currentPath);
        final isGoingToClubAbout =
            RegExp(r'^/club/about/[\w-]+$').hasMatch(currentPath);
        final isGoingToFest =
            RegExp(r'^/club/fest/[\w-]+$').hasMatch(currentPath);

        if (currentPath == "/apps") {
          if (kIsWeb && (defaultTargetPlatform == TargetPlatform.android)) {
            LaunchUrl.openUrl(
                'https://play.google.com/store/apps/details?id=in.learningx.club_app');
            // html.window.location.assign(
            //     "https://play.google.com/store/apps/details?id=in.learningx.club_app");
          }
          if (kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS)) {
            LaunchUrl.openUrl(
                'https://apps.apple.com/in/app/clubchat-academic-club-more/id6612034727');
            // html.window.location.assign(
            //     "https://apps.apple.com/in/app/clubchat-academic-club-more/id6612034727");
          }
          if (kIsWeb) {
            return '/download/apps';
          } else {
            return '/login';
          }
        } else if (!isLoggedIn &&
            !(isGoingToLogin ||
                isGoingToSignIn ||
                isGoingToDownload ||
                isGoingToCollege ||
                isGoingToEvent ||
                isGoingToClubAbout ||
                isGoingToFest)) {
          return '/';
        }

        return null; // Allow the navigation if no redirect is necessary
      },
      routerNeglect: false,
      errorBuilder: (context, state) {
        return const ErrorScreen(errMsg: "Page not found.");
      },
    );
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color.fromARGB(255, 238, 238, 238),
        cardColor: Colors.white,
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color.fromARGB(255, 238, 238, 238),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 56, 114, 220),
          ),
        ),
      ),
      routerConfig: router,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            // Only unfocus if a TextField or input is focused
            if (FocusManager.instance.primaryFocus != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          behavior: HitTestBehavior.opaque,
          child: child,
        );
      },
    );
  }
}
