//
//  Tweak.xm
//  VolumeBar
//
//  Created by cgm616.
//  Copyright (c) 2015 cgm616. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import "VolumeBar.h"
#import "GMPVolumeView.h"
#include <tgmath.h>
#import <SpringBoard/SBVolumeHUDView.h>

extern "C" UIColor *colorFromDefaultsWithKey(NSString *defaults, NSString *key, NSString *fallback);

static NSDictionary *preferences;
BOOL enabled;
BOOL animateOn;
BOOL interaction;
BOOL routeButton;
BOOL blur;
double timeOnScreen;
double animateTime;
int blurStyle;
UIColor *bannerColor;

static void initPrefs() {
	[preferences release];
	CFStringRef appID = CFSTR("me.cgm616.volumebar");
	CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (!keyList) {
		NSLog(@"There's been an error getting the key list!");
		return;
	}
	preferences = (NSDictionary *)CFPreferencesCopyMultiple(keyList, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (!preferences) {
		NSLog(@"There's been an error getting the preferences dictionary!");
	}
  NSLog(@"VolumeBar prefs dictionary has been updated to: %@", preferences);
	CFRelease(keyList);
}

static void loadPrefs(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  initPrefs();
  NSNumber *key = preferences[@"enabled"];
  enabled = key ? [key boolValue] : 1;
  key = preferences[@"animation"];
  animateOn = key ? [key boolValue] : 1;
  key = preferences[@"interaction"];
  interaction = key ? [key boolValue] : 1;
  key = preferences[@"routebutton"];
  routeButton = key ? [key boolValue] : 0;
  key = preferences[@"blur"];
  blur = key ? [key boolValue] : 1;
  key = preferences[@"timeon"];
  timeOnScreen = key ? [key doubleValue] : 5.0;
  key = preferences[@"animatetime"];
  animateTime = key ? [key doubleValue] : 0.2;
  key = preferences[@"blurstyle"];
  blurStyle = key ? [key intValue] : 2;
  bannerColor = colorFromDefaultsWithKey(@"me.cgm616.volumebar", @"bannercolor", @"#ffffff");
}

%ctor {
  loadPrefs(nil,nil,nil,nil,nil);
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("me.cgm616.volumebar/preferences.changed"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}

%hook SBHUDController

-(void)presentHUDView:(id)view autoDismissWithDelay:(double)delay {
  %log;
  if([view isKindOfClass:objc_getClass("SBVolumeHUDView")] && enabled) {
    [[VolumeBar sharedInstance] loadHUDWithColor:bannerColor WithInteraction:interaction WithRouteButton:routeButton WithAnimation:animateOn WithSpeed:animateTime WithTime:timeOnScreen WithBlur:blur WithBlurStyle:blurStyle WithView:view];
    NSLog(@"view mode: %ld", (long)[view mode]);
  }
  else {
    %orig;
  }
}

-(void)presentHUDView:(id)view {
  %log;
  if([view isKindOfClass:objc_getClass("SBVolumeHUDView")] && enabled) {
    [[VolumeBar sharedInstance] loadHUDWithColor:bannerColor WithInteraction:interaction WithRouteButton:routeButton WithAnimation:animateOn WithSpeed:animateTime WithTime:timeOnScreen WithBlur:blur WithBlurStyle:blurStyle WithView:view];
    NSLog(@"view mode: %ld", (long)[view mode]);
  }
  else {
    %orig;
  }
}

%end
