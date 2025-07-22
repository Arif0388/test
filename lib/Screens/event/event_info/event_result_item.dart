import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:learningx_flutter_app/api/common/open_file.dart';
import 'package:learningx_flutter_app/api/model/event_model.dart';
import 'package:universal_html/html.dart' as html;

class ResultItemCard extends StatefulWidget {
  final Result result;

  const ResultItemCard({super.key, required this.result});

  @override
  State<ResultItemCard> createState() => _ResultItemCardState();
}

class _ResultItemCardState extends State<ResultItemCard> {
  double _progress = 0;
  bool _isDownloading = false;

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _progress = 0;
    });

    await openFile(widget.result.file, (progress) {
      setState(() {
        _progress = progress;
      });
    });

    setState(() {
      _isDownloading = false;
    });
  }

  void openWebFile() {
    // ignore: unused_local_variable
    html.AnchorElement anchorElement =
        html.AnchorElement(href: widget.result.file)
          ..setAttribute('download', '')
          ..click();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(0),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            color: Colors.blue,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.image,
                size: 40,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.result.filename,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'round ${widget.result.round}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                  icon: _isDownloading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: _progress / 100,
                          ),
                        )
                      : const Icon(Icons.download),
                  onPressed: () async {
                    if (kIsWeb) {
                      openWebFile();
                    } else {
                      if (!_isDownloading) {
                        await _startDownload();
                      }
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
