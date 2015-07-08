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

@synthesize color = _color;
@synthesize animate = _animate;
@synthesize userInteraction = _userInteraction;
@synthesize showRouteButton = _showRouteButton;
@synthesize blur = _blur;
@synthesize drop = _drop;
@synthesize slide = _slide;
@synthesize delayTime = _delayTime;
@synthesize speed = _speed;
@synthesize blurStyle = _blurStyle;

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

-(void)swipeHandler:(UITapGestureRecognizer *)gestureRecognizer {
  NSLog(@"swipeHandler called");
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideHUD) object:nil];
  [self hideHUD];
}

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

-(void)createHUD {
  NSLog(@"createHUD");
  // get size of screen, then calculate banner size
  CGRect screenRect = [[UIScreen mainScreen] bounds];
  screenWidth = screenRect.size.width;
  screenHeight = screenRect.size.height;
  bannerHeight = _slide ? screenHeight / 9 : screenHeight / 12;
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
  [mainView setBackgroundColor:_color];
  [mainView setUserInteractionEnabled:YES];
  [topWindow addSubview:mainView];

  if(_drop) {
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:mainView.bounds];
    mainView.layer.masksToBounds = NO;
    mainView.layer.shadowColor = [UIColor blackColor].CGColor;
    mainView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    mainView.layer.shadowOpacity = 0.5f;
    mainView.layer.shadowPath = shadowPath.CGPath;
  }

  if(_blur) {
    [mainView setBackgroundColor:[UIColor clearColor]]; // if blurred, change color to clear

    blurSettings = [_UIBackdropViewSettings settingsForStyle:_blurStyle]; // set up blur depending on prefs, 0 = light, 2 = default, 1 = dark
    blurView = [[_UIBackdropView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, bannerHeight) autosizesToFitSuperview:YES settings:blurSettings];
    [blurView setBlurRadiusSetOnce:NO];
    [blurView setBlurRadius:10.0];
    [blurView setBlurHardEdges:2];
    [blurView setBlursWithHardEdges:YES];
    [blurView setBlurQuality:@"default"];
    [mainView addSubview:blurView];
  }

  if([_view mode] == 1) {
    NSLog(@"view mode = 1, showing ringer slider");
    // if ringer, create UISlider and have it call volume change method
    ringerSlider = [[UISlider alloc] initWithFrame:CGRectMake(sliderPadding, 0, screenWidth - (2 * sliderPadding), bannerHeight)];
    ringerSlider.continuous = YES;
    ringerSlider.value = [[NSClassFromString(@"VolumeControl") sharedVolumeControl] volume];
    ringerSlider.minimumValue = 0.0625;
    ringerSlider.maximumValue = 1.0;
    [ringerSlider addTarget:self action:@selector(ringerSliderAction:) forControlEvents:UIControlEventValueChanged];
    [ringerSlider setBackgroundColor:[UIColor clearColor]];
    [ringerSlider setUserInteractionEnabled:_userInteraction];
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
    [volumeSlider setUserInteractionEnabled:_userInteraction];
    volumeSlider.showsRouteButton = _showRouteButton;
    [mainView addSubview:volumeSlider];
  }

  mainView.frame = CGRectMake(0, (-1 * bannerHeight) - 10, screenWidth, bannerHeight); // hide mainView so animation can pull in

  if(_slide) {
    [_view mode] == 1 ? [ringerSlider setFrame:CGRectMake(sliderPadding, 0, screenWidth - (2 * sliderPadding), screenHeight / 12)] : [volumeSlider setFrame:CGRectMake(sliderPadding, 0, screenWidth - (2 * sliderPadding), screenHeight / 12)];
    handle = [[UIView alloc] initWithFrame:CGRectMake((screenWidth / 2) - (screenWidth / 16), screenHeight / 11.5, screenWidth / 8, (screenHeight / 9.5) - (screenHeight / 11.5))];
    [handle setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]]; // medium alpha black
    handle.layer.cornerRadius = screenWidth / 52;
    handle.layer.masksToBounds = YES;
    [mainView addSubview:handle];

    swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
  }

  _alive = YES;
}

-(void)showHUD {
  NSLog(@"showHUD");
  topWindow.hidden = NO;
  if(_animate) {
    [UIView animateWithDuration:_speed
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

  if(_slide) {
    [handle addGestureRecognizer:swipeRecognizer];
    [mainView addGestureRecognizer:swipeRecognizer];
  }
}

-(void)hideHUD {
  NSLog(@"hideHUD");
  if(_animate) {
    [UIView animateWithDuration:_speed
	    delay:0
	    options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
	    animations:^ {
	      mainView.frame = CGRectMake(0, (-1 * bannerHeight) - 10, screenWidth, bannerHeight);
	    }
	    completion:^(BOOL finished) {
	      [mainView removeFromSuperview];
	      topWindow.hidden = YES;
        _alive = NO;
	    }
    ];
  }
  else {
    mainView.frame = CGRectMake(0, (-1 * bannerHeight) - 10, screenWidth, bannerHeight);
    [mainView removeFromSuperview];
    topWindow.hidden = YES;
    _alive = NO;
  }
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                                object:nil];

  if(_slide) {
    [handle removeGestureRecognizer:swipeRecognizer];
    [mainView removeGestureRecognizer:swipeRecognizer];
  }
}

-(void)loadHUDWithView:(id)view {
  // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];

  if(!_alive) {
    NSLog(@"loadHUD, currently dead");

    _view = view;
    [self createHUD];
    [self showHUD];

    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:_delayTime];
  }
  else {
    NSLog(@"loadHUD, currently alive");
  }
}

@end
