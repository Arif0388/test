
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../api/provider/notification_provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  bool isNotification = false;
  List<Map<String, dynamic>> allNotifications = [
    {
      "title": "Lorem empsum lorem empsum Lorem empsum lorem empsum",
      "time":DateTime.now().subtract(const Duration(minutes: 10)),
      "avatar": null,
    },
    {
      "title": "Lorem empsum lorem empsum Lorem empsum lorem empsum",
      "time": DateTime.now().subtract(const Duration(hours: 1)),
      "avatar": "assets/images/logo1.png",
    },
    {
      "title": "Lorem empsum lorem empsum Lorem empsum lorem empsum",
      "time": DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      "avatar": "assets/images/logo2.png",
    },
    {
      "title": "Lorem empsum lorem empsum Lorem empsum lorem empsum",
      "time": DateTime.now().subtract(const Duration(days: 3)),
      "avatar": null,
    },
    {
      "title": "Lorem empsum lorem empsum Lorem empsum lorem empsum",
      "time":DateTime.now().subtract(const Duration(days: 5)),
      "avatar": "assets/images/person1.png",
    },
    {
      "title": "Lorem empsum lorem empsum Lorem empsum lorem empsum",
      "time":DateTime.now().subtract(const Duration(days: 2)),
      "avatar": null,
    },
    {
      "title": "Lorem empsum lorem empsum Lorem empsum lorem empsum",
      "time":DateTime.now().subtract(const Duration(days: 10)),
      "avatar": "assets/images/person2.png",
    },
    {
      "title": "Lorem empsum lorem empsum Lorem empsum lorem empsum",
      "time":DateTime.now().subtract(const Duration(days: 4)),
      "avatar": "assets/images/person3.png",
    },
  ];

  List<Map<String, dynamic>> get todayNotifications => allNotifications
      .where((n) =>
  n["time"].day == DateTime.now().day &&
      n["time"].month == DateTime.now().month &&
      n["time"].year == DateTime.now().year)
      .toList();

  List<Map<String, dynamic>> get yesterdayNotifications => allNotifications
      .where((n) =>
  n["time"].day == DateTime.now().subtract(const Duration(days: 1)).day &&
      n["time"].month == DateTime.now().month &&
      n["time"].year == DateTime.now().year)
      .toList();

  List<Map<String, dynamic>> get thisWeekNotifications => allNotifications
      .where((n) =>
  n["time"].isBefore(DateTime.now().subtract(const Duration(days: 1))) &&
      n["time"].isAfter(DateTime.now().subtract(const Duration(days: 7))))
      .toList();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    markReadNotificationApi();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationProvider.notifier).fetchNotifications();
    }
  }

  Future<void> _refresh() async {
    ref.read(notificationProvider.notifier).refreshNotifications();
  }

  void handleRemoveItem(String id) {
    ref.read(notificationProvider.notifier).removeNotification(id);
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationProvider);
    final isLoading = ref.watch(
        notificationProvider.notifier.select((state) => state.isLoading));
    return Scaffold(
      appBar:AppBar(
        backgroundColor: const Color.fromARGB(255, 211, 232, 255),
        title:Text('notification',style:GoogleFonts.poppins(fontWeight:FontWeight.w500,fontSize:20)),
        actions: [
          // Switch(value:isNotification, onChanged:(value){
          //   setState(() {
          //     isNotification = value;
          //   });
          // }),
          IconButton(onPressed:(){
            modalBottomSheet(context: context);
          }, icon:const Icon(Icons.more_vert_outlined)),
        ],
      ),
      body:isNotification? ListView(
        children: [
          if (todayNotifications.isNotEmpty) section("Today", todayNotifications,context),
          if (yesterdayNotifications.isNotEmpty)
            section("Yesterday", yesterdayNotifications,context),
          if (thisWeekNotifications.isNotEmpty)
            section("This Week", thisWeekNotifications,context),
        ],
      ) :
      Column(
        mainAxisAlignment:MainAxisAlignment.center,
        children: [
          Container(),
          Image.asset('assets/images/notification_icon.png'),
          const SizedBox(height:20),
          Text('no notification to show',style:GoogleFonts.nunito(fontWeight:FontWeight.w700,color:const Color(0xff3B82F6),fontSize:20)),
          Padding(
              padding:const EdgeInsets.only(left:5),
              child: Text('You currently have no notifications. we will notify',style:GoogleFonts.nunito(fontWeight:FontWeight.w500,color:const Color(0xff6B7280),fontSize:15))),
          Padding(
              padding:const EdgeInsets.only(left:5),
              child: Text('you when something new happens!',style:GoogleFonts.nunito(fontWeight:FontWeight.w500,color:const Color(0xff6B7280),fontSize:15))),
          const SizedBox(height:20),
          Container(
            width:120,
            height:50,
            decoration:BoxDecoration(
              borderRadius:BorderRadius.circular(15),
              color:const Color(0xff3B82F6),
            ),
            child:Center(child: Text('Explore',style:GoogleFonts.poppins(fontWeight:FontWeight.w600,fontSize:18,color:Colors.white))),
          ),
        ],
      ),
    );
  }
}

Future modalBottomSheet({required BuildContext context}){
  return showModalBottomSheet(
    context:context,
    builder:(context) {
      return Container(
        width:MediaQuery.of(context).size.width,
        height:MediaQuery.of(context).size.height/4,
        decoration:const BoxDecoration(
          borderRadius:BorderRadius.only(topLeft:Radius.circular(10),topRight:Radius.circular(10)),
          color:Color(0xffFFFFFF),
        ),
        child:Column(
          children: [
            const SizedBox(height:20),
            Text('Clear All',style:GoogleFonts.inter(color:Colors.red,fontSize:16,fontWeight:FontWeight.w500)),
            const SizedBox(height:10),
            const Divider(
              indent:20,
              endIndent:20,
            ),
            const SizedBox(height:10),
            Text('Mark all as read',style:GoogleFonts.inter(color:const Color(0xff6B7280),fontSize:14,fontWeight:FontWeight.w500)),
            const SizedBox(height:20),
            const Divider(
              thickness:4,
              color:Colors.grey,
            ),
            const SizedBox(height:20),
            Text('Cancel',style:GoogleFonts.inter(color:const Color(0xff3C393C),fontSize:16,fontWeight:FontWeight.w600)),
          ],
        ),
      );
    },
  );
}

Widget isNotificationComing({required List<Map<String,dynamic>> notificationData}){
  return Column(
    children: [
      Expanded(
        child: ListView.builder(
          itemCount: notificationData.length,
          itemBuilder: (context, index) {
            final item = notificationData[index];
            return Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                // setState(() {
                //   notificationData.removeAt(index);
                // });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Notification deleted")),
                );
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: ListTile(
                leading: item["avatar"] != null
                    ?  CircleAvatar(
                  backgroundImage:AssetImage(item["avatar"]),
                )
                    :  const CircleAvatar(child: Icon(Icons.person)),
                title:  Text(item["title"]),
                subtitle: Text(item["time"]),
              ),
            );
          },
        ),
      ),
    ],
  );
}

Widget section(String title, List<Map<String, dynamic>> items,BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Text(title, style:GoogleFonts.inter(fontWeight:FontWeight.w500,fontSize:12,color:const Color(0xff6B7280))),
      ),
      ...items.map((item) => buildDismissible(item,context)).toList(),
    ],
  );
}

Widget buildDismissible(Map<String, dynamic> item,BuildContext context) {
  return Dismissible(
    key: UniqueKey(),
    direction: DismissDirection.endToStart,
    onDismissed: (direction) {
      // setState(() {
      //   allNotifications.remove(item);
      // });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notification deleted")),
      );
    },
    background: Container(
      color: Colors.red,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    ),
    child: ListTile(
      leading: item["avatar"] != null
          ? CircleAvatar(backgroundImage: AssetImage(item["avatar"]))
          : const CircleAvatar(child: Icon(Icons.person)),
      title: Text(item["title"],style:GoogleFonts.inter(fontSize:14,fontWeight:FontWeight.w400,color:const Color(0xff6B7280))),
      subtitle: Text(DateFormat('hh:mm a').format(item["time"]),style:GoogleFonts.inter(fontWeight:FontWeight.w400,fontSize:10,color:const Color(0xff6B7280))),
    ),
  );
}


