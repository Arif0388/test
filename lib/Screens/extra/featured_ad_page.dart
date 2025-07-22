import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/extra/featured_item.dart';
import 'package:learningx_flutter_app/api/model/featured_ad_model.dart';
import 'package:learningx_flutter_app/api/provider/featured_ad_provoder.dart';

class FeaturedAdScreen extends ConsumerWidget {
  const FeaturedAdScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adAsyncValue = ref.watch(featuredAdProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Featured oppurtunies'),
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        elevation: 0,
      ),
      body: Center(
        child: adAsyncValue.when(
          data: (ads) {
            return ListView.builder(
              itemCount: ads.length,
              itemBuilder: (context, index) {
                FeaturedAd ad = ads[index];
                return AdvertisementCard(
                  ad: ad,
                );
              },
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Failed to fetch ads: $error'),
        ),
      ),
    );
  }
}
