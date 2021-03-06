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
#import <libcolorpicker/ColorPicker.h>

static NSDictionary *preferences;
BOOL enabled;
BOOL animate;
BOOL userInteraction;
BOOL showRouteButton;
BOOL blur;
BOOL drop;
BOOL statusBar;
BOOL slide;
BOOL label;
double delayTime;
double speed;
double height;
int blurStyle;
UIColor *color;

/*
 * Updates NSDictionary preferences when needed.
 * Called by loadPrefs().
 */
static void initPrefs() {
	CFStringRef appID = CFSTR("me.cgm616.volumebar");
	CFArrayRef keyList = CFPreferencesCopyKeyList(appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (!keyList) {
		HBLogError(@"VolumeBar: There's been an error getting the key list!");
		return;
	}
	preferences = (NSDictionary *)CFPreferencesCopyMultiple(keyList, appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (!preferences) {
		HBLogError(@"VolumeBar: There's been an error getting the preferences dictionary!");
	}
  HBLogInfo(@"VolumeBar: Prefs dictionary has been updated to: %@", preferences);
	CFRelease(keyList);
}

/*
 * Calls updates actual variables for the banner.
 * Calls initPrefs() to get preferences dictionary.
 * Set as callback for preference change notification in ctor.
 */
static void loadPrefs(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  initPrefs();
  NSNumber *key = preferences[@"enabled"];
  enabled = key ? [key boolValue] : 1;

  key = preferences[@"animation"];
  animate = key ? [key boolValue] : 1;

  key = preferences[@"interaction"];
  userInteraction = key ? [key boolValue] : 1;

  key = preferences[@"routebutton"];
  showRouteButton = key ? [key boolValue] : 0;

  key = preferences[@"blur"];
  blur = key ? [key boolValue] : 1;

	key = preferences[@"drop"];
  drop = key ? [key boolValue] : 0;

	key = preferences[@"statusBar"];
	statusBar = key ? [key boolValue] : 0;

	key = preferences[@"slide"];
	slide = key ? [key boolValue] : 1;

	key = preferences[@"label"];
	label = key ? [key boolValue] : 0;

  key = preferences[@"timeon"];
  delayTime = key ? [key doubleValue] : 5.0;

  key = preferences[@"animatetime"];
  speed = key ? [key doubleValue] : 0.2;

	key = preferences[@"height"];
  height = key ? [key doubleValue] : 1.0;

  key = preferences[@"blurstyle"];
  blurStyle = key ? [key intValue] : 2;

	color = LCPParseColorString([preferences objectForKey:@"bannercolor"], @"#ffffff");

	[preferences release];
}

/*
 * Calls loadPrefs() and sets loadPrefs() as callback for prefs notification.
 * Called after respring of device.
 */
%ctor {
  loadPrefs(nil,nil,nil,nil,nil);
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("me.cgm616.volumebar/preferences.changed"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}

/*
 * Allow me to stay DRY with the presentHUDView: and presentHUDView:autoDismissWithDelay:
 */
@interface SBHUDController

-(void)presentVolumeBarWithView:(id)view;

@end

/*
 * Main hook for the tweak.
 * Overrides presentHUDView:autoDismissWithDelay: and presentHUDView: to show banner.
 */
%hook SBHUDController

%new(v@:);
-(void)presentVolumeBarWithView:(id)view {
	VolumeBar *vbar = [VolumeBar sharedInstance];
	vbar.color = color;
	vbar.animate = animate;
	vbar.userInteraction = userInteraction;
	vbar.showRouteButton = showRouteButton;
	vbar.blur = blur;
	vbar.drop = drop;
	vbar.statusBar = statusBar;
	vbar.slide = slide;
	vbar.label = label;
	vbar.brightness = [view isKindOfClass:objc_getClass("SBVolumeHUDView")] ? NO : YES;
	vbar.delayTime = delayTime;
	vbar.speed = speed;
	vbar.height = height;
	vbar.blurStyle = blurStyle;
	[vbar loadHUDWithView:view];
}

-(void)presentHUDView:(id)view autoDismissWithDelay:(double)delay {
  if(([view isKindOfClass:objc_getClass("SBVolumeHUDView")] || [view isKindOfClass:objc_getClass("SBBrightnessHUDView")]) && enabled) {
    [self presentVolumeBarWithView:view];
  }
  else {
    %orig;
  }
}

-(void)presentHUDView:(id)view {
	if(([view isKindOfClass:objc_getClass("SBVolumeHUDView")] || [view isKindOfClass:objc_getClass("SBBrightnessHUDView")]) && enabled) {
    [self presentVolumeBarWithView:view];
  }
  else {
    %orig;
  }
}

%end
