import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/event/event_item.dart';
import 'package:learningx_flutter_app/api/model/event_model.dart';
import 'package:learningx_flutter_app/api/provider/event_provider.dart';

class EventFragmentPage extends ConsumerStatefulWidget {
  final String query;
  final Widget page;

  const EventFragmentPage({super.key, required this.query, required this.page});

  @override
  ConsumerState<EventFragmentPage> createState() => _EventFragmentPageState();
}

class _EventFragmentPageState extends ConsumerState<EventFragmentPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  Future<void> _refresh() async {
    await ref.read(eventProvider(widget.query).notifier).refreshEvent();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 200 &&
        notification is ScrollUpdateNotification) {
      ref.read(eventProvider(widget.query).notifier).fetchEvents();
    }
    return false; // Returning false allows the notification to continue bubbling up.
  }

  void onRemove(String eventId) {
    ref.read(eventProvider(widget.query).notifier).removeEvent(eventId);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Call super.build for AutomaticKeepAlive

    final events = ref.watch(eventProvider(widget.query));
    final isLoading = ref.watch(eventProvider(widget.query)
        .notifier
        .select((state) => state.isLoading));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: CustomScrollView(
            key: const PageStorageKey<String>('eventList'),
            slivers: [
              SliverToBoxAdapter(
                child: widget.page, // Fixed content at the top
              ),
              if (events.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == events.length) {
                        return isLoading
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            : const SizedBox.shrink();
                      }
                      EventItem event = events[index];
                      return EventItemCard(
                        key: ValueKey(event.id),
                        event: event,
                        onRemove: onRemove,
                        isNietCollegeAdmin: false,
                      );
                    },
                    childCount: events.length + (isLoading ? 1 : 0),
                  ),
                ),
              if (events.isEmpty && !isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No events available',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
