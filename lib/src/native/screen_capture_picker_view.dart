import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef CapturePickerViewCreatedCallback = void Function(IOSScreenCapturePickerController controller);

class IOSScreenCapturePickerView extends StatelessWidget {
  const IOSScreenCapturePickerView({Key? key, required this.onCapturePickerViewCreatedCallback}) : super(key: key);
  final CapturePickerViewCreatedCallback onCapturePickerViewCreatedCallback;
  @override
  Widget build(BuildContext context) {
    // This is used in the platform side to register the view.
    const viewType = 'systemBroadcastPickerView';
    // Pass parameters to the platform side.
    final creationParams = <String, dynamic>{};

    return UiKitView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: (int id) {
        onCapturePickerViewCreatedCallback(IOSScreenCapturePickerController.getInstance());
      },
    );
  }
}

class IOSScreenCapturePickerController {
  IOSScreenCapturePickerController() {
    _channel.setMethodCallHandler((MethodCall call) {
      if (call.method == 'broadcastStarted') {
        onBroadcastStarted?.call();
        return Future.value(true);
      } else if (call.method == 'broadcastStopped') {
        onBroadcastStopped?.call();
        return Future.value(true);
      }
      return Future.value(false);
    });
  }
  static final IOSScreenCapturePickerController _instance = IOSScreenCapturePickerController();
  static IOSScreenCapturePickerController getInstance() {
    return _instance;
  }

  VoidCallback? onBroadcastStarted;
  VoidCallback? onBroadcastStopped;

  final MethodChannel _channel = MethodChannel('FlutterWebRTCRecord.Method');

  void show() {
    _channel.invokeMethod('show');
  }

  void stop() {
    _channel.invokeMethod('stop');
  }
}
