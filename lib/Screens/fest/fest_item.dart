import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learningx_flutter_app/api/model/fest_model.dart';
import 'package:learningx_flutter_app/api/utils/utils.dart';

class FestItemCard extends StatelessWidget {
  final Fest fest;
  const FestItemCard({super.key, required this.fest});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: GestureDetector(
          onTap: () {
            context.push("/club/fest/${fest.id}");
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
                          fest.festImg,
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
                            fest.festName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                Utils.getDateString(fest.startedAtDate),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (fest.description.isNotEmpty)
                            Text(
                              fest.college.collegeName,
                              maxLines: 2,
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
