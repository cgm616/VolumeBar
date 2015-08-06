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

+(VolumeBar*)sharedInstance { // sharedInstance keeps the same object between views, so no alloc/init in Tweak.xm
  static dispatch_once_t p = 0;
  __strong static id _sharedObject = nil;
  dispatch_once(&p, ^{
    _sharedObject = [[self alloc] init];
  });
  return _sharedObject;
}

-(void)swipeHandler:(UITapGestureRecognizer *)gestureRecognizer { // stops hide timer and calls hideHUD when swiped
  NSLog(@"swipeHandler called");
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideHUD) object:nil];
  [self hideHUD];
}

-(void)ringerSliderAction:(id)sender { // updates volume when ringer slider changed TODO: make less resource instensive
  NSLog(@"ringerSliderAction called");
  UISlider *slider = (UISlider*)sender;
  volumeControl = [NSClassFromString(@"VolumeControl") sharedVolumeControl];
  float delta = slider.value - [volumeControl volume];
  [volumeControl _changeVolumeBy:delta];
  [slider release];
}

-(void)ringerChanged:(NSNotification *)notification { // handles changing slider value when buttons pressed with ringer
  NSLog(@"ringerChanged called");
  NSDictionary *dict = notification.userInfo;
  float value = [[dict objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
  [ringerSlider setValue:value animated:YES];
  // [dict release];
}

-(void)calculateRender { // does frame calculations and creates thumbImage
  NSLog(@"calculateRender called");
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
    sliderY = sliderY + 14;
    bannerHeight = bannerHeight + sliderY;
  }
}

-(void)createHUD { // creates view heirarchy
  NSLog(@"createHUD called");
  [self calculateRender];

  topWindow = [[UIWindow alloc] initWithFrame:CGRectMake(bannerX, bannerY, bannerWidth, bannerHeight)]; // window to display on screen
  topWindow.windowLevel = UIWindowLevelStatusBar;
  topWindow.backgroundColor = [UIColor clearColor];
  [topWindow setUserInteractionEnabled:YES];
  [topWindow makeKeyAndVisible];
  topWindow.hidden = YES;

  mainView = [[UIView alloc] initWithFrame:CGRectMake(bannerX, bannerY, bannerWidth, bannerHeight)]; // top level view for everything else
  [mainView setBackgroundColor:_color];
  [mainView setUserInteractionEnabled:YES];
  [topWindow addSubview:mainView];

  if(_drop) { // create drop shadow then add it to the mainView
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:mainView.bounds];
    mainView.layer.masksToBounds = NO;
    mainView.layer.shadowColor = [UIColor blackColor].CGColor;
    mainView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    mainView.layer.shadowOpacity = 0.5f;
    mainView.layer.shadowPath = shadowPath.CGPath;
  }

  if(_blur) { // create blur view and add to mainView
    [mainView setBackgroundColor:[UIColor clearColor]];

    blurSettings = [_UIBackdropViewSettings settingsForStyle:_blurStyle]; // 0 = light, 2 = default, 1 = dark
    blurView = [[_UIBackdropView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, bannerHeight) autosizesToFitSuperview:YES settings:blurSettings];
    [blurView setBlurRadiusSetOnce:NO];
    [blurView setBlurRadius:10.0];
    [blurView setBlurHardEdges:2];
    [blurView setBlursWithHardEdges:YES];
    [blurView setBlurQuality:@"default"];
    [mainView addSubview:blurView];
    [blurView release];
  }

  if([_view mode] == 1) { // view mode 1 is ringer, 0 is player
    ringerSlider = [[UISlider alloc] initWithFrame:CGRectMake(sliderX, sliderY, sliderWidth, sliderHeight)];
    ringerSlider.continuous = YES;
    ringerSlider.value = [[NSClassFromString(@"VolumeControl") sharedVolumeControl] volume];
    ringerSlider.minimumValue = 0;
    ringerSlider.maximumValue = 1.0;
    [ringerSlider addTarget:self action:@selector(ringerSliderAction:) forControlEvents:UIControlEventValueChanged];
    [ringerSlider setBackgroundColor:[UIColor clearColor]];
    [ringerSlider setUserInteractionEnabled:_userInteraction];
    if(_statusBar) { // add no thumb image
      [ringerSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ringerChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [mainView addSubview:ringerSlider];
  }
  else {
    volumeSlider = [[GMPVolumeView alloc] initWithFrame:CGRectMake(sliderX, sliderY, sliderWidth, sliderHeight)];
    [volumeSlider setBackgroundColor:[UIColor clearColor]];
    [volumeSlider setUserInteractionEnabled:_userInteraction];
    volumeSlider.showsRouteButton = (_showRouteButton || !_statusBar);
    if(_statusBar) { // add no thumb image
      [volumeSlider setVolumeThumbImage:thumbImage forState:UIControlStateNormal];
    }
    [mainView addSubview:volumeSlider];
  }

  if(_slide && !_statusBar) { // set up swipe handler and create handle view, add to mainView
    handle = [[UIView alloc] initWithFrame:CGRectMake((screenWidth / 2) - 16, bannerHeight - 10, 32, 8)];
    [handle setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    handle.layer.cornerRadius = 4;
    handle.layer.masksToBounds = YES;
    [mainView addSubview:handle];
    swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandler:)];
    [swipeRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
  }

  if(_label && !_statusBar) { // add label depending on mode, add to mainView
    label = [[UILabel alloc] initWithFrame:CGRectMake(bannerX, bannerY + 2, bannerWidth, sliderY)];
    [label setBackgroundColor:[UIColor clearColor]];
    label.text = [_view mode] == 1 ? @"Ringer" : @"Player";
    label.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]; // TODO: make text white when needed for contrast

    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12];
    [mainView addSubview:label];
    [label release];
  }

  mainView.frame = CGRectMake(bannerX, (-1 * bannerHeight) - 5, bannerWidth, bannerHeight); // hide frame for animation in

  _alive = YES;
}

-(void)destroyHUD { // release all allocated objects when done with banner
  NSLog(@"destroyHUD called");
  // [ringerSlider release];
  [volumeSlider release];
  [swipeRecognizer release];
  [handle release];
  [mainView release];
  [topWindow release];
  _alive = NO;
}

-(void)showHUD { // animate banner in, set up gestures to work
  NSLog(@"showHUD called");
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

-(void)hideHUD { // animate gestures out, remove gestures, call destroyHUD
  NSLog(@"hideHUD called");
  if(_slide && !_statusBar) {
    [handle removeGestureRecognizer:swipeRecognizer];
    [mainView removeGestureRecognizer:swipeRecognizer];
  }

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

-(void)loadHUDWithView:(id)view { // only method called from Tweak.xm, calls all other methods for setup and hiding
  NSLog(@"loadHUDWithView called");
  if(!_alive) {
    _view = view;
    [self createHUD];
    [self showHUD];

    [self performSelector:@selector(hideHUD) withObject:nil afterDelay:_delayTime];
  }
}

@end
