// Copyright (c) 2024 Tencent. All rights reserved.
// Author: rickwrwang

#import "TUIMultimediaPlugin.h"

#import <TUICore/TUIThemeManager.h>
#import <TUIChat/MultimediaRecorder.h>
#import <TUIChat/AlbumPicker.h>
#import <TUICore/TUICore.h>
#import "TUIMultimediaSignatureChecker.h"
#import "TUIMultimediaRecorder.h"
#import "TUIMultimediaProcessor.h"
#import "TUIMultimediaAlbumPicker.h"
#import <TUICore/TUILogin.h>
@interface TUIMultimediaPlugin ()<V2TIMSDKListener> {

}

@end

@implementation TUIMultimediaPlugin : NSObject

+ (instancetype)shareInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
+ (void)load {
    TUIRegisterThemeResourcePath(TUIMultimediaPluginThemePath, TUIThemeModuleMultimedia);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLoginSucceeded) name:TUILoginSuccessNotification object:nil];
    [TUIMultimediaPlugin shareInstance];
}

+ (void)onLoginSucceeded {
    [V2TIMManager.sharedInstance addIMSDKListener:[TUIMultimediaPlugin shareInstance]];
    [[TUIMultimediaPlugin shareInstance] updateSignature];
}


- (void)onConnectSuccess {
    [[TUIMultimediaPlugin shareInstance] updateSignature];
}

- (void)updateSignature {
    __auto_type onUpdateSignatureSuccess = ^(void) {
        NSLog(@"TUIMultimediaPlugin onUpdateSignatureSuccess");
        [MultimediaRecorder registerAdvancedVideoRecorder:(id)[[TUIMultimediaRecorder alloc] init]];
        [AlbumPicker registerAdvancedAlbumPicker:(id)[[TUIMultimediaAlbumPicker alloc] init]];
    };
    [[TUIMultimediaSignatureChecker shareInstance] startUpdateSignature:onUpdateSignatureSuccess];
}
@end