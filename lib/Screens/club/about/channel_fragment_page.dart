import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/club/channel/channel_item.dart';
import 'package:learningx_flutter_app/api/model/channel_model.dart';
import 'package:learningx_flutter_app/api/model/club_model.dart';

class ChannelFragmentPage extends ConsumerStatefulWidget {
  final List<Channel> channels;
  final ClubItem clubItem;
  final Widget page;
  const ChannelFragmentPage(
      {super.key,
      required this.channels,
      required this.clubItem,
      required this.page});
  @override
  ConsumerState<ChannelFragmentPage> createState() =>
      _ChannelFragmentPageState();
}

class _ChannelFragmentPageState extends ConsumerState<ChannelFragmentPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Call super.build for AutomaticKeepAlive

    return CustomScrollView(
      key: const PageStorageKey<String>('channelList'),
      slivers: <Widget>[
        SliverToBoxAdapter(child: widget.page),
        widget.channels.isEmpty
            ? const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No channel available',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    Channel channel = widget.channels[index];
                    return ChannelItemWidget(
                      key: ValueKey(channel.id),
                      channel: channel,
                      clubItem: widget.clubItem,
                    );
                  },
                  childCount: widget.channels.length,
                ),
              ),
      ],
    );
  }
}
