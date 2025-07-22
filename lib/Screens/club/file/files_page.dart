import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningx_flutter_app/Screens/club/file/file_item.dart';
import 'package:learningx_flutter_app/Screens/club/file/files_link_item.dart';
import 'package:learningx_flutter_app/Screens/common/bottom_sheet_select_filetype.dart';
import 'package:learningx_flutter_app/api/model/channel_model.dart';
import 'package:learningx_flutter_app/api/model/files_model.dart';
import 'package:learningx_flutter_app/api/provider/files_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilesPage extends ConsumerStatefulWidget {
  final Channel channel;
  const FilesPage({super.key, required this.channel});

  @override
  ConsumerState<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends ConsumerState<FilesPage> {
  final ScrollController _scrollController = ScrollController();
  var _currentUserId = "";
  var isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
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

  _loadCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('id') ?? "";
      isAdmin = widget.channel.admin.contains(_currentUserId);
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(filesProvider(widget.channel.id).notifier).fetchFiles();
    }
  }

  void deleteFile(String filesId) {
    ref.read(filesProvider(widget.channel.id).notifier).deleteFile(filesId);
  }

  Future<void> _refresh() async {
    ref.read(filesProvider(widget.channel.id).notifier).refreshFiles();
  }

  @override
  Widget build(BuildContext context) {
    final files = ref.watch(filesProvider(widget.channel.id));
    final isLoading = ref.watch(filesProvider(widget.channel.id)
        .notifier
        .select((state) => state.isLoading));

    return Scaffold(
        body: RefreshIndicator(
            onRefresh: _refresh,
            child: Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : files.isEmpty
                      ? const Text('No files available')
                      : ListView.builder(
                          key: const PageStorageKey<String>('filesList'),
                          controller: _scrollController,
                          itemCount: files.length + (isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == files.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                            Files file = files[index];
                            var canDelete =
                                isAdmin || file.user.id == _currentUserId;
                            if (file.filetype == "link") {
                              return FilesLinkItemWidget(
                                  file: file, isAdmin: canDelete, onDeleteFile: deleteFile);
                            } else {
                              return FileItemCard(
                                  file: file, isAdmin: canDelete, onDeleteFile: deleteFile);
                            }
                          },
                        ),
            )),
        floatingActionButton: Visibility(
          visible: widget.channel.permission == "public" ||
              (widget.channel.permission == "private" && isAdmin),
          child: FloatingActionButton(
            onPressed: () {
              final SelectFiletypeBottomSheet bottomSheet =
                  SelectFiletypeBottomSheet();
              bottomSheet.showBottomSheet(
                  context, "file", null, widget.channel, null, null);
            },
            child: const Icon(Icons.add),
          ),
        ));
  }
}
