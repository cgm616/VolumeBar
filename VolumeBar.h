//
//  VolumeBar.h
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
#import "GMPVolumeView.h"
#import "UIBackdropView.h"
#include <tgmath.h>

@interface VolumeBar : NSObject {
	UIWindow *topWindow;
	UIView *mainView;
	_UIBackdropView *blurView;
	_UIBackdropViewSettings *blurSettings;

	GMPVolumeView *volumeSlider;
  CGFloat screenWidth;
  CGFloat screenHeight;
  CGFloat bannerHeight;
  CGFloat sliderPadding;

	BOOL alive;
}

+(VolumeBar*)sharedInstance;
// -(void)orientationChanged:(NSNotification *)notification;
// -(void)adjustViewsForOrientation:(UIInterfaceOrientation)orientation;
-(void)createHUDWithColor:(UIColor*)color WithInteraction:(BOOL)userInteraction WithRouteButton:(BOOL)showRouteButton WithBlur:(BOOL)blur WithBlurStyle:(int)blurStyle;
-(void)showHUDWithAnimation:(BOOL)animate WithSpeed:(double)speed;
-(void)hideHUDWithAnimation:(BOOL)animate WithSpeed:(double)speed;
-(void)loadHUDWithColor:(UIColor*)color WithInteraction:(BOOL)userInteraction WithRouteButton:(BOOL)showRouteButton WithAnimation:(BOOL)animate WithSpeed:(double)speed WithTime:(double)delayTime WithBlur:(BOOL)blur WithBlurStyle:(int)blurStyle WithView:(id)view;

@end
