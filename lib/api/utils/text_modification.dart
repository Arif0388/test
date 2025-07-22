import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/api/common/launch_url.dart';

class TextModification {
  static Widget displayMessage(
      BuildContext context, String message, bool isSelf) {
    final List<TextSpan> children = [];
    int startIndex = 0;

    while (true) {
      final int linkIndex = message.indexOf("http", startIndex);
      final int mentionIndex =
          message.indexOf("@<a href=\"profile://", startIndex);
      int nextIndex =
          linkIndex != -1 && (mentionIndex == -1 || linkIndex < mentionIndex)
              ? linkIndex
              : mentionIndex;

      if (nextIndex == -1) {
        children.add(TextSpan(
          text: message.substring(startIndex),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16.0,
          ),
        ));
        break;
      }

      if (nextIndex > startIndex) {
        children.add(TextSpan(
          text: message.substring(startIndex, nextIndex),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16.0,
          ),
        ));
      }

      if (nextIndex == linkIndex) {
        int endLinkIndex = message.indexOf(" ", linkIndex);
        if (endLinkIndex == -1) {
          endLinkIndex = message.length;
        }
        final String link = message.substring(linkIndex, endLinkIndex);
        children.add(
          TextSpan(
            text: link,
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 16.0,
              decoration: TextDecoration.none,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                LaunchUrl.openUrl(link);
              },
          ),
        );
        startIndex = endLinkIndex;
      } else if (nextIndex == mentionIndex) {
        final int userIdStartIndex =
            mentionIndex + "@<a href=\"profile://".length;
        final int userIdEndIndex = message.indexOf("\">", userIdStartIndex);

        if (userIdEndIndex != -1) {
          final String userId =
              message.substring(userIdStartIndex, userIdEndIndex);
          final int mentionStartIndex = userIdEndIndex + "\">".length;
          final int mentionEndIndex =
              message.indexOf("</a>", mentionStartIndex);

          if (mentionEndIndex != -1) {
            final String mention =
                message.substring(mentionStartIndex, mentionEndIndex);
            children.add(
              TextSpan(
                text: mention,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 16.0,
                  decoration: TextDecoration.none,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    context.push("/profile/$userId");
                  },
              ),
            );
            startIndex = mentionEndIndex + "</a>".length;
          } else {
            children.add(TextSpan(
              text: message.substring(startIndex),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16.0,
              ),
            ));
            break;
          }
        } else {
          children.add(TextSpan(
            text: message.substring(startIndex),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16.0,
            ),
          ));
          break;
        }
      }
    }

    return RichText(
      text: TextSpan(children: children),
      overflow: TextOverflow.visible,
      softWrap: true,
    );
  }

  static Widget displayLinks(String message) {
    final List<TextSpan> children = [];
    int startIndex = 0;

    while (true) {
      final int linkIndex = message.indexOf("http", startIndex);
      if (linkIndex == -1) {
        // No more links found, append the remaining text and break
        children.add(TextSpan(
          text: message.substring(startIndex),
          style: const TextStyle(color: Colors.black, fontSize: 16.0),
        ));
        break;
      }

      // Append the non-link text before the link
      if (linkIndex > startIndex) {
        children.add(TextSpan(
          text: message.substring(startIndex, linkIndex),
          style: const TextStyle(color: Colors.black, fontSize: 16.0),
        ));
      }

      // Find the end of the link (we assume a space or the end of the message marks the end of the link)
      int endLinkIndex = message.indexOf(" ", linkIndex);
      if (endLinkIndex == -1) {
        endLinkIndex = message.length;
      }

      final String link = message.substring(linkIndex, endLinkIndex);
      children.add(
        TextSpan(
          text: link,
          style: const TextStyle(
              color: Colors.blue,
              fontSize: 16.0,
              decoration: TextDecoration.none),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              LaunchUrl.openUrl(link);
            },
        ),
      );

      // Update startIndex to search for the next link
      startIndex = endLinkIndex;
    }

    return Flexible(
        child: RichText(
      text: TextSpan(children: children),
      overflow: TextOverflow.visible,
      softWrap: true,
    ));
  }

  static displayMentions(BuildContext context, String message) {
    final List<TextSpan> children = [];
    int startIndex = 0;

    while (true) {
      final int mentionIndex =
          message.indexOf("@<a href=\"profile://", startIndex);
      if (mentionIndex == -1) {
        // No more mentions found, append the remaining text and break
        children.add(TextSpan(
          text: message.substring(startIndex),
          style: const TextStyle(color: Colors.black, fontSize: 16.0),
        ));
        break;
      }

      // Append the non-mention text before the mention
      if (mentionIndex > startIndex) {
        children.add(TextSpan(
          text: message.substring(startIndex, mentionIndex),
          style: const TextStyle(color: Colors.black, fontSize: 16.0),
        ));
      }

      // Find the userId and mention
      final int userIdStartIndex =
          mentionIndex + "@<a href=\"profile://".length;
      final int userIdEndIndex = message.indexOf("\">", userIdStartIndex);
      if (userIdEndIndex != -1) {
        final String userId =
            message.substring(userIdStartIndex, userIdEndIndex);

        final int mentionStartIndex = userIdEndIndex + "\">".length;
        final int mentionEndIndex = message.indexOf("</a>", mentionStartIndex);
        if (mentionEndIndex != -1) {
          final String mention =
              message.substring(mentionStartIndex, mentionEndIndex);

          // Create a TextSpan for the mention
          children.add(
            TextSpan(
              text: mention,
              style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 16.0,
                  decoration: TextDecoration.none),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  context.push("/profile/$userId");
                },
            ),
          );

          // Update startIndex to search for the next mention
          startIndex = mentionEndIndex + "</a>".length;
        } else {
          // Mention not properly closed, break the loop
          children.add(TextSpan(
            text: message.substring(startIndex),
            style: const TextStyle(color: Colors.black, fontSize: 16.0),
          ));
          break;
        }
      } else {
        // Invalid format, break the loop
        children.add(TextSpan(
          text: message.substring(startIndex),
          style: const TextStyle(color: Colors.black, fontSize: 16.0),
        ));
        break;
      }
    }

    return Flexible(
        child: RichText(
      text: TextSpan(children: children),
      overflow: TextOverflow.visible,
      softWrap: true,
    ));
  }

  String getHtmlText(TextEditingController controller) {
    final text = controller.text;

    // Manually parse the text and create HTML
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      if (char == '@') {
        // Example: Wrap mentions with <a> tag
        int mentionEnd = text.indexOf(' ', i);
        if (mentionEnd == -1) mentionEnd = text.length;
        final mention = text.substring(i, mentionEnd);
        buffer.write('<a href="profile://$mention">$mention</a>');
        i = mentionEnd - 1;
      } else {
        buffer.write(char);
      }
    }

    String htmlText = buffer.toString();
    // Remove unwanted tags if necessary
    htmlText = htmlText
        .replaceAll("<u>", "")
        .replaceAll("</u>", "")
        .replaceAll("<br>", "")
        .trim();

    return htmlText;
  }
}
