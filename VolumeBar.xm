//
//  VolumeBar.xm
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
#import "UIBackdropView.h"
#import "VolumeControl.h"
#include <tgmath.h>

@implementation VolumeBar

// sharedInstance in order to not have to init the VolumeBanner object
+(VolumeBar*)sharedInstance {
  static dispatch_once_t p = 0;
  __strong static id _sharedObject = nil;
  dispatch_once(&p, ^{
    _sharedObject = [[self alloc] init];
  });
  return _sharedObject;
}

/*
-(void)orientationChanged:(NSNotification *)notification {
  NSLog(@"Orientation changed");
  [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

-(void)adjustViewsForOrientation:(UIInterfaceOrientation)orientation {
  switch (orientation)
  {
    case UIInterfaceOrientationPortrait:
    {
      NSLog(@"Orientation portrait");
      topWindow.frame = CGRectMake(0, 0, screenWidth, bannerHeight);
      mainView.frame = CGRectMake(0, 0, screenWidth, bannerHeight);
      volumeSlider.frame = CGRectMake(sliderPadding, 0, screenWidth - (2 * sliderPadding), bannerHeight);
    }
    break;
    case UIInterfaceOrientationPortraitUpsideDown:
    {
      NSLog(@"Orientation portrait upside down");
      topWindow.frame = CGRectMake(screenWidth, screenHeight, 0, screenHeight - bannerHeight);
      mainView.frame = CGRectMake(screenWidth, screenHeight, 0, screenHeight - bannerHeight);
      volumeSlider.frame = CGRectMake(screenWidth - sliderPadding, screenHeight, 2 * sliderPadding, screenHeight - bannerHeight);
    }
    break;
    case UIInterfaceOrientationLandscapeLeft:
    {
      NSLog(@"Orientation landscape left");
      topWindow.frame = CGRectMake(screenHeight, 0, 0, screenWidth - bannerHeight);
      mainView.frame = CGRectMake(screenHeight, 0, 0, screenWidth - bannerHeight);
      volumeSlider.frame = CGRectMake(screenHeight - sliderPadding, 0, 2 * sliderPadding, bannerHeight);
    }
    break;
    case UIInterfaceOrientationLandscapeRight: // TODO: finish doing these orientations
    {
      NSLog(@"Orientation landscape right");
      topWindow.frame = CGRectMake(screenWidth, screenHeight, 0, screenHeight - bannerHeight);
      mainView.frame = CGRectMake(screenWidth, screenHeight, 0, screenHeight - bannerHeight);
      volumeSlider.frame = CGRectMake(screenWidth - sliderPadding, screenHeight, 0 + (2 * sliderPadding), screenHeight - bannerHeight);
    }
    break;
    case UIInterfaceOrientationUnknown:break;
  }
}
*/

-(void)ringerSliderAction:(id)sender {
  UISlider *slider = (UISlider*)sender;
  NSLog(@"Slider value is: %f", slider.value);
  volumeControl = [NSClassFromString(@"VolumeControl") sharedVolumeControl];
  float delta = slider.value - [volumeControl volume];
  [volumeControl _changeVolumeBy:delta];
}

-(void)ringerChanged:(NSNotification *)notification {
  NSDictionary*dict=notification.userInfo;
  float value = [[dict objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
  [ringerSlider setValue:value animated:YES];
  NSLog(@"Ringer changed with buttons, currently: %f", value);
}

-(void)createHUDWithColor:(UIColor*)color WithInteraction:(BOOL)userInteraction WithRouteButton:(BOOL)showRouteButton WithBlur:(BOOL)blur WithBlurStyle:(int)blurStyle WithView:(id)view WithDrop:(BOOL)drop{
  NSLog(@"createHUDWithColor");
  // get size of screen, then calculate banner size
  CGRect screenRect = [[UIScreen mainScreen] bounds];
  screenWidth = screenRect.size.width;
  screenHeight = screenRect.size.height;
  bannerHeight = screenHeight / 12;
  sliderPadding = screenWidth / 16;

  // create window to show when HUD fires
  topWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, screenWidth, bannerHeight)];
  topWindow.windowLevel = UIWindowLevelStatusBar;
  topWindow.backgroundColor = [UIColor clearColor];
  [topWindow setUserInteractionEnabled:YES];
  [topWindow makeKeyAndVisible];
  topWindow.hidden = YES;

  // create the superview for everything else
  mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, bannerHeight)];
  [mainView setBackgroundColor:color];
  [mainView setUserInteractionEnabled:YES];
  [topWindow addSubview:mainView];

  if(drop) {
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:mainView.bounds];
    mainView.layer.masksToBounds = NO;
    mainView.layer.shadowColor = [UIColor blackColor].CGColor;
    mainView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    mainView.layer.shadowOpacity = 0.5f;
    mainView.layer.shadowPath = shadowPath.CGPath;
  }

  if(blur) {
    [mainView setBackgroundColor:[UIColor clearColor]]; // if blurred, change color to clear

    blurSettings = [_UIBackdropViewSettings settingsForStyle:blurStyle]; // set up blur depending on prefs, 0 = light, 2 = default, 1 = dark
    blurView = [[_UIBackdropView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, bannerHeight) autosizesToFitSuperview:YES settings:blurSettings];
    [blurView setBlurRadiusSetOnce:NO];
    [blurView setBlurRadius:10.0];
    [blurView setBlurHardEdges:2];
    [blurView setBlursWithHardEdges:YES];
    [blurView setBlurQuality:@"default"];
    [mainView addSubview:blurView];
  }

  if([view mode] == 1) {
    NSLog(@"view mode = 1, showing ringer slider");
    // if ringer, create UISlider and have it call volume change method
    ringerSlider = [[UISlider alloc] initWithFrame:CGRectMake(sliderPadding, 0, screenWidth - (2 * sliderPadding), bannerHeight)];
    ringerSlider.continuous = YES;
    ringerSlider.minimumValue = 0.0625;
    ringerSlider.maximumValue = 1.0;
    [ringerSlider addTarget:self action:@selector(ringerSliderAction:) forControlEvents:UIControlEventValueChanged];
    [ringerSlider setBackgroundColor:[UIColor clearColor]];
    [ringerSlider setUserInteractionEnabled:userInteraction];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ringerChanged:)
                                                 name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                               object:nil];
    [mainView addSubview:ringerSlider];
  }
  else {
    NSLog(@"view mode = 0, showing GMPVolumeView");
    // if volume, make the MPVolumeView with the frame, make it clear, using GMPVolumeView to fix positioning
    volumeSlider = [[GMPVolumeView alloc] initWithFrame:CGRectMake(sliderPadding, 0, screenWidth - (2 * sliderPadding), bannerHeight)];
    [volumeSlider setBackgroundColor:[UIColor clearColor]];
    [volumeSlider setUserInteractionEnabled:userInteraction];
    volumeSlider.showsRouteButton = showRouteButton;
    [mainView addSubview:volumeSlider];
  }


  mainView.frame = CGRectMake(0, (-1 * bannerHeight) - 10, screenWidth, bannerHeight); // hide mainView so animation can pull in

  alive = YES;
}

-(void)showHUDWithAnimation:(BOOL)animate WithSpeed:(double)speed {
  NSLog(@"showHUDWithAnimation");
  topWindow.hidden = NO;
  if(animate) {
    [UIView animateWithDuration:speed
	    delay:0
	    options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
	    animations:^ {
	      mainView.frame = CGRectMake(0, 0, screenWidth, bannerHeight);
	    }
	    completion:^(BOOL finished) {
	    }
    ];
  }
  else {
    mainView.frame = CGRectMake(0, 0, screenWidth, bannerHeight);
  }
}

-(void)hideHUDWithAnimation:(BOOL)animate WithSpeed:(double)speed {
  NSLog(@"hideHUDWithAnimation");
  if(animate) {
    [UIView animateWithDuration:speed
	    delay:0
	    options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
	    animations:^ {
	      mainView.frame = CGRectMake(0, (-1 * bannerHeight) - 10, screenWidth, bannerHeight);
	    }
	    completion:^(BOOL finished) {
	      [mainView removeFromSuperview];
	      topWindow.hidden = YES;
        alive = NO;
	    }
    ];
  }
  else {
    mainView.frame = CGRectMake(0, (-1 * bannerHeight) - 10, screenWidth, bannerHeight);
    [mainView removeFromSuperview];
    topWindow.hidden = YES;
    alive = NO;
  }
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                                object:nil];
}

-(void)loadHUDWithColor:(UIColor*)color WithInteraction:(BOOL)userInteraction WithRouteButton:(BOOL)showRouteButton WithAnimation:(BOOL)animate WithSpeed:(double)speed WithTime:(double)delayTime WithBlur:(BOOL)blur WithBlurStyle:(int)blurStyle WithView:(id)view WithDrop:(BOOL)drop {
  // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];

  if(!alive) {
    NSLog(@"loadHUDWithColor, currently dead");
    [self createHUDWithColor:color WithInteraction:userInteraction WithRouteButton:showRouteButton WithBlur:blur WithBlurStyle:blurStyle WithView:view WithDrop:drop];
    [self showHUDWithAnimation:animate WithSpeed:speed];

    // after time, hide the banner
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayTime * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      [self hideHUDWithAnimation:animate WithSpeed:speed];
    });
  }
  else {
    NSLog(@"loadHUDWithColor, currently alive");
  }
}

@end
