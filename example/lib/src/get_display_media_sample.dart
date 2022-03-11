import 'dart:async';
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc/src/native/screen_capture_picker_view.dart';

/*
 * getDisplayMedia sample
 */
class GetDisplayMediaSample extends StatefulWidget {
  static String tag = 'get_display_media_sample';

  @override
  _GetDisplayMediaSampleState createState() => _GetDisplayMediaSampleState();
}

class _GetDisplayMediaSampleState extends State<GetDisplayMediaSample> {
  MediaStream? _localStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  late IOSScreenCapturePickerController controller;
  bool _inCalling = false;
  Timer? _timer;
  var _counter = 0;

  @override
  void initState() {
    super.initState();
    initRenderers();
  }

  @override
  void deactivate() {
    super.deactivate();
    if (_inCalling) {
      _stop();
    }
    _timer?.cancel();
    _localRenderer.dispose();
  }

  Future<void> initRenderers() async {
    await _localRenderer.initialize();
  }

  void handleTimer(Timer timer) async {
    setState(() {
      _counter++;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _makeCall() async {
    final mediaConstraints = <String, dynamic>{'audio': true, 'video': true};

    try {
      var stream = await createStream(true);
      stream.getVideoTracks()[0].onEnded = () {
        print('By adding a listener on onEnded you can: 1) catch stop video sharing on Web');
      };

      _localStream = stream;
      _localRenderer.srcObject = _localStream;
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    setState(() {
      _inCalling = true;
    });

    _timer = Timer.periodic(Duration(milliseconds: 100), handleTimer);
  }

  Future<MediaStream> createStream(bool userScreen) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': userScreen ? false : true,
      'video': userScreen
          ? true
          : {
              'mandatory': {
                'minWidth': '640', // Provide your own width, height and frame rate here
                'minHeight': '480',
                'minFrameRate': '30',
              },
              'facingMode': 'user',
              'optional': [],
            }
    };

    MediaStream stream =
        userScreen ? await navigator.mediaDevices.getDisplayMedia(mediaConstraints) : await navigator.mediaDevices.getUserMedia(mediaConstraints);
    return stream;
  }

  Future<void> _stop() async {
    try {
      if (kIsWeb) {
        _localStream?.getTracks().forEach((track) => track.stop());
      }
      await _localStream?.dispose();
      _localStream = null;
      _localRenderer.srcObject = null;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _hangUp() async {
    await _stop();
    setState(() {
      _inCalling = false;
    });
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GetDisplayMedia API Test'),
        actions: [],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Stack(children: <Widget>[
              Center(
                child: Text('counter: ' + _counter.toString()),
              ),
              Column(
                children: [
                  SizedBox(
                    width: 0,
                    height: 0,
                    child: IOSScreenCapturePickerView(
                      onCapturePickerViewCreatedCallback: (IOSScreenCapturePickerController controller) {
                        this.controller = controller;
                        this.controller.onBroadcastStarted = () {
                          print('this.controller.onBroadcastStarted');
                        };

                        this.controller.onBroadcastStopped = () {
                          print('this.controller.onBroadcastStopped');
                        };
                      },
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        controller.show();
                      },
                      child: Text('show')),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(color: Colors.black54),
                      child: RTCVideoView(_localRenderer),
                    ),
                  ),
                ],
              )
            ]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _inCalling ? _hangUp : _makeCall,
        tooltip: _inCalling ? 'Hangup' : 'Call',
        child: Icon(_inCalling ? Icons.call_end : Icons.phone),
      ),
    );
  }
}
