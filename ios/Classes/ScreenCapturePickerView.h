//
//  ScreenCapturePickerView.h
//  flutter_webrtc
//
//  Created by Karzan on 2/19/22.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@interface ScreenCapturePickerViewFactory : NSObject <FlutterPlatformViewFactory>
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
@end

@interface ScreenCapturePickerView : NSObject <FlutterPlatformView>

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;

- (UIView*)view;

@end
