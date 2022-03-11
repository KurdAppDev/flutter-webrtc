import 'dart:core';

import 'package:flutter/foundation.dart' show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc/src/native/screen_capture_picker_view.dart';
import 'src/data_channel_sample.dart';
import 'src/get_display_media_sample.dart';
import 'src/get_user_media_sample.dart' if (dart.library.html) 'src/get_user_media_sample_web.dart';
import 'src/loopback_sample.dart';
import 'src/route_item.dart';

void main() {
  if (WebRTC.platformIsDesktop) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  } else if (WebRTC.platformIsAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    startForegroundService();
  }
  runApp(MyApp());
}

Future<bool> startForegroundService() async {
  final androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: 'Title of the notification',
    notificationText: 'Text of the notification',
    notificationImportance: AndroidNotificationImportance.Default,
    notificationIcon: AndroidResource(name: 'background_icon', defType: 'drawable'), // Default is ic_launcher from folder mipmap
  );
  await FlutterBackground.initialize(androidConfig: androidConfig);
  return FlutterBackground.enableBackgroundExecution();
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late List<RouteItem> items;
  late IOSScreenCapturePickerController controller;
  @override
  void initState() {
    super.initState();
    _initItems();
  }

  ListBody _buildRow(context, item) {
    return ListBody(children: <Widget>[
      ListTile(
        title: Text(item.title),
        onTap: () => item.push(context),
        trailing: Icon(Icons.arrow_right),
      ),
      Divider()
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('Flutter-WebRTC example'),
          ),
          body: Column(
            children: [
              /* Expanded(child: ScreenCapturePickerView(
                onCapturePickerViewCreatedCallback: (IOSScreenCapturePickerController controller) {
                  this.controller = controller;
                },
              )),*/
              ElevatedButton(
                  onPressed: () {
                    controller.show();
                  },
                  child: Text('show')),
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(0.0),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      return _buildRow(context, items[i]);
                    }),
              ),
            ],
          )),
    );
  }

  void _initItems() {
    items = <RouteItem>[
      RouteItem(
          title: 'GetUserMedia',
          push: (BuildContext context) {
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => GetUserMediaSample()));
          }),
      RouteItem(
          title: 'GetDisplayMedia',
          push: (BuildContext context) {
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => GetDisplayMediaSample()));
          }),
      RouteItem(
          title: 'LoopBack Sample',
          push: (BuildContext context) {
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => LoopBackSample()));
          }),
      RouteItem(
          title: 'DataChannel',
          push: (BuildContext context) {
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => DataChannelSample()));
          }),
    ];
  }
}
