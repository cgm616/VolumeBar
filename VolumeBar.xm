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
@synthesize statusBar = _statusBar;
@synthesize slide = _slide;
@synthesize label = _label;
@synthesize delayTime = _delayTime;
@synthesize speed = _speed;
@synthesize height = _height;
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
  [slider release];
}

-(void)ringerChanged:(NSNotification *)notification {
  NSDictionary *dict = notification.userInfo;
  float value = [[dict objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
  [ringerSlider setValue:value animated:YES];
  NSLog(@"Ringer changed with buttons, currently: %f", value);
  [dict release];
}

-(void)calculateRender {
  NSLog(@"calculateRender");

  CGRect screenRect = [[UIScreen mainScreen] bounds];
  screenWidth = screenRect.size.width;
  screenHeight = screenRect.size.height;

  bannerX = 0;
  bannerWidth = screenWidth;
	bannerY = 0;
  bannerHeight = 40 * _height;

  sliderX = screenWidth / 16;
  sliderWidth = screenWidth - (2 * sliderX);
  sliderY = 0;

  if(_statusBar) {
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    float statusBarHeight = MIN(statusBarSize.width, statusBarSize.height);
    bannerHeight = statusBarHeight > 20 ? statusBarHeight : 20;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(2, 2), NO, 0.0);
    thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
  }

  sliderHeight = bannerHeight;

  if(_slide && !_statusBar) {
    bannerHeight = bannerHeight + 12;
  }

  if(_label && !_statusBar) {
    sliderY = 14;
    bannerHeight = bannerHeight + sliderY;
  }
}

-(void)createHUD {
  NSLog(@"createHUD");

  [self calculateRender];

  // create window to show when HUD fires
  topWindow = [[UIWindow alloc] initWithFrame:CGRectMake(bannerX, bannerY, bannerWidth, bannerHeight)];
  topWindow.windowLevel = UIWindowLevelStatusBar;
  topWindow.backgroundColor = [UIColor clearColor];
  [topWindow setUserInteractionEnabled:YES];
  [topWindow makeKeyAndVisible];
  topWindow.hidden = YES;

  // create the superview for everything else
  mainView = [[UIView alloc] initWithFrame:CGRectMake(bannerX, bannerY, bannerWidth, bannerHeight)];
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
    [blurView release];
  }

  if([_view mode] == 1) {
    NSLog(@"view mode = 1, showing ringer slider");
    ringerSlider = [[UISlider alloc] initWithFrame:CGRectMake(sliderX, sliderY, sliderWidth, sliderHeight)];
    ringerSlider.continuous = YES;
    ringerSlider.value = [[NSClassFromString(@"VolumeControl") sharedVolumeControl] volume];
    ringerSlider.minimumValue = 0;
    ringerSlider.maximumValue = 1.0;
    [ringerSlider addTarget:self action:@selector(ringerSliderAction:) forControlEvents:UIControlEventValueChanged];
    [ringerSlider setBackgroundColor:[UIColor clearColor]];
    [ringerSlider setUserInteractionEnabled:_userInteraction];
    if(_statusBar) {
      [ringerSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ringerChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [mainView addSubview:ringerSlider];
  }
  else {
    NSLog(@"view mode = 0, showing GMPVolumeView");
    volumeSlider = [[GMPVolumeView alloc] initWithFrame:CGRectMake(sliderX, sliderY, sliderWidth, sliderHeight)];
    [volumeSlider setBackgroundColor:[UIColor clearColor]];
    [volumeSlider setUserInteractionEnabled:_userInteraction];
    volumeSlider.showsRouteButton = (_showRouteButton || !_statusBar);
    if(_statusBar) {
      [volumeSlider setVolumeThumbImage:thumbImage forState:UIControlStateNormal];
    }
    [mainView addSubview:volumeSlider];
  }

  if(_slide && !_statusBar) {
    handle = [[UIView alloc] initWithFrame:CGRectMake((screenWidth / 2) - 16, bannerHeight - 10, 32, 8)];
    [handle setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    handle.layer.cornerRadius = 4;
    handle.layer.masksToBounds = YES;
    [mainView addSubview:handle];
    swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
  }

  if(_label && !_statusBar) {
    label = [[UILabel alloc] initWithFrame:CGRectMake(bannerX, bannerY + 2, bannerWidth, sliderY)];
    [label setBackgroundColor:[UIColor clearColor]];
    label.text = [_view mode] == 1 ? @"Ringer" : @"Player";
    label.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];

    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12];
    [mainView addSubview:label];
    [label release];
  }

  mainView.frame = CGRectMake(bannerX, (-1 * bannerHeight) - 5, bannerWidth, bannerHeight);

  _alive = YES;
}

-(void)destroyHUD {
  [ringerSlider release];
  [volumeSlider release];
  [swipeRecognizer release];
  [handle release];
  [mainView release];
  [topWindow release];
  _alive = NO;
}

-(void)showHUD {
  NSLog(@"showHUD");
  topWindow.hidden = NO;
  if(_animate) {
    [UIView animateWithDuration:_speed
	    delay:0
	    options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
	    animations:^ {
	      mainView.frame = CGRectMake(bannerX, bannerY, bannerWidth, bannerHeight);
	    }
	    completion:^(BOOL finished) {
	    }
    ];
  }
  else {
    mainView.frame = CGRectMake(bannerX, bannerY, bannerWidth, bannerHeight);
  }

  if(_slide && !_statusBar) {
    [handle addGestureRecognizer:swipeRecognizer];
    [mainView addGestureRecognizer:swipeRecognizer];
  }
}

-(void)hideHUD {

  if(_slide && !_statusBar) {
    [handle removeGestureRecognizer:swipeRecognizer];
    [mainView removeGestureRecognizer:swipeRecognizer];
  }

  NSLog(@"hideHUD");
  if(_animate) {
    [UIView animateWithDuration:_speed
	    delay:0
	    options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
	    animations:^ {
	      mainView.frame = CGRectMake(bannerX, (-1 * bannerHeight) - 5, bannerWidth, bannerHeight);
	    }
	    completion:^(BOOL finished) {
	      [mainView removeFromSuperview];
	      topWindow.hidden = YES;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
        [self destroyHUD];
	    }
    ];
  }
  else {
    mainView.frame = CGRectMake(bannerX, (-1 * bannerHeight) - 5, bannerWidth, bannerHeight);
    [mainView removeFromSuperview];
    topWindow.hidden = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [self destroyHUD];
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
