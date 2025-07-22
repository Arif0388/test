import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/api/model/community_model.dart';

class CommunityItemWidget extends StatelessWidget {
  final CommunityItem community;

  const CommunityItemWidget({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: GestureDetector(
          onTap: () {
            context.push("/community/${community.id}");
          },
          child: Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  color: Colors.blue,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        width: 100.0,
                        height: 100.0,
                        color: Colors.grey[200],
                        child: Image.network(
                          community.coverImg,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            community.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          if (community.description.isNotEmpty)
                            Text(
                              community.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black54),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))),
    );
  }
}
