//
//  ScreenCapturePickerView.m
//  flutter_webrtc
//
//  Created by Karzan on 2/19/22.
//

#import "ScreenCapturePickerView.h"
#import "DarwinNotificationsManager.h"
#import <ReplayKit/ReplayKit.h>
NSString* const kRTCScreenSharingExtension = @"RTCScreenSharingExtension";

@implementation ScreenCapturePickerViewFactory {
    NSObject<FlutterBinaryMessenger>* _messenger;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    if (self) {
        _messenger = messenger;
    }
    return self;
}

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                   viewIdentifier:(int64_t)viewId
                                        arguments:(id _Nullable)args {
    
    return [[ScreenCapturePickerView alloc] initWithFrame:frame
                                           viewIdentifier:viewId
                                                arguments:args
                                          binaryMessenger:_messenger];
}

@end

@implementation ScreenCapturePickerView {
    UIView *_view;
    FlutterMethodChannel* channel;
}

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    
    if (self = [super init]) {
        _view = [[UIView alloc] initWithFrame:frame];
        if (@available(iOS 12.0, *)) {
            RPSystemBroadcastPickerView * systemBroadcastPickerView = [[RPSystemBroadcastPickerView alloc] init];
            systemBroadcastPickerView.preferredExtension = self.preferredExtension;
            systemBroadcastPickerView.backgroundColor = UIColor.redColor;
            systemBroadcastPickerView.showsMicrophoneButton = false;
            systemBroadcastPickerView.userInteractionEnabled = false;
            [_view addSubview:systemBroadcastPickerView];
            
            
            channel = [FlutterMethodChannel
                       methodChannelWithName:@"FlutterWebRTCRecord.Method"
                       binaryMessenger:messenger];
            
            
            [[DarwinNotificationsManager sharedInstance] registerForNotificationName:@"iOS_BroadcastStarted" callback:^{
                [self->channel invokeMethod:@"broadcastStarted" arguments:nil];
            }];
            
            [[DarwinNotificationsManager sharedInstance] registerForNotificationName:@"iOS_BroadcastStopped" callback:^{
                [self->channel invokeMethod:@"broadcastStopped" arguments:nil];
            }];
            
            __weak typeof(self) weakSelf = self;
            [channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
                if ([@"show" isEqualToString:call.method]) {
                    UIButton *btn = nil;
                    
                    for (UIView *subview in ((RPSystemBroadcastPickerView *)systemBroadcastPickerView).subviews) {
                        if ([subview isKindOfClass:[UIButton class]]) {
                            btn = (UIButton *)subview;
                        }
                    }
                    if (btn != nil) {
                        [btn sendActionsForControlEvents:UIControlEventTouchUpInside];
                        result(@(true));
                    }else{
                        result(@(false));
                    }
                    
                } else if ([@"stop" isEqualToString:call.method]) {
                    [[DarwinNotificationsManager sharedInstance] postNotificationWithName:@"iOS_STOP_Broadcast"];
                }
                
            }];
        }
    }
    return self;
}

- (UIView *)view {
    return _view;
}

- (NSString *)preferredExtension {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return infoDictionary[kRTCScreenSharingExtension];
}
- (void) dealloc {
    //[[DarwinNotificationsManager sharedInstance] unregister];
}
@end
