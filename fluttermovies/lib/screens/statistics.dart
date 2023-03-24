import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:duration/duration.dart';
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late SharedPreferences prefs;
  List<String> watched = [];
  List<String> toWatch = [];

  int runtimeWatched = 0;
  int runtimeToWatch = 0;
  late Uint8List _imageFile;
  late final tempDir;
  bool isShare = true;

  ScreenshotController screenshotController = ScreenshotController();

  init() async {
    prefs = await SharedPreferences.getInstance().then((value) {
      setState(() {
        runtimeWatched = value.getInt('runtime_watched') ?? 0;
        runtimeToWatch = value.getInt('runtime_watchlist') ?? 0;

        watched = value.getStringList('watched')??[];
        toWatch = value.getStringList('watchlist')??[];

      });
      return value;
    });
    tempDir = await getTemporaryDirectory();
    screenshotController.capture().then((image) {
      setState(() {
        _imageFile = image!;
      });
    });
  }

  @override
  initState() {
    // TODO: implement initState
    init();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Statistics"),
          actions: [
            Visibility(
              visible: isShare,
              child: IconButton(
                  onPressed: () async {
                    setState(() {
                      isShare = false;
                    });

                      setState(() {
                        isShare = true;
                      });
                      var path = "${tempDir.path}/image.png";
                      File file = await File("${tempDir.path}/image.png").create();
                      file.writeAsBytesSync(_imageFile);
                      Share.shareFiles([path]);


                  },
                  icon: const Icon(Icons.share)
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Movies (Watched) ", style: TextStyle(fontSize: 20),),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(watched.length.toString(), style: const TextStyle(fontSize: 40),),
                      Text("Watched")
                    ],
                  ),
                  Text('${prettyDuration(Duration(minutes: runtimeWatched),abbreviated: false )} Watched')
                ],
              ),
              const Divider(),
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Movies (On Watch List) ", style: TextStyle(fontSize: 20),),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(toWatch.length.toString(), style: const TextStyle(fontSize: 40),),
                      Text("To Watch")
                    ],
                  ),
                  Text('${prettyDuration(Duration(minutes: runtimeToWatch),abbreviated: false )} to Watch')
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
