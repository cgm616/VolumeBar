//
//  VolumeBar.mm
//  VolumeBar
//
//  Created by cgm616.
//  Copyright (c) 2015 cgm616. All rights reserved.
//
//

#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>
#import <libcolorpicker/ColorPicker.h>
#import <libcolorpicker/PFColorAlert.h>
#import <libcolorpicker/UIColor+PFColor.h>
#import <UIKit/UIKit.h>

static BOOL settingsChanged;

@protocol PreferencesTableCustomView
- (id)initWithSpecifier:(id)arg1;

@optional
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1;
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 inTableView:(id)arg2;
@end

@interface PSTableCell ()
- (id)initWithStyle:(int)style reuseIdentifier:(id)arg2;
@end

@interface VolumeBarListController: PSListController {
}
@end

@implementation VolumeBarListController {
}

-(void)respring {
  system("killall -9 backboardd");
}

-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)spec {
	[super setPreferenceValue:value specifier:spec];
	if (!settingsChanged) {
		settingsChanged = YES;
    [self settingsChanged];
	}
}

-(id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"VolumeBar" target:self] retain];
	}
	return _specifiers;
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

	if(settingsChanged) {
		[self settingsChanged];
	}
}

-(void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

-(void)settingsChanged {
  UIBarButtonItem *respringButton([[UIBarButtonItem alloc] initWithTitle:@"Respring" style:UIBarButtonItemStyleDone target:self action:@selector(respring)]);
  [[self navigationItem] setLeftBarButtonItem:respringButton];
  [respringButton release];
}

@end

@interface VBSettingsListController: PSListController {
}
@end

@implementation VBSettingsListController

-(void)githubButton {
  NSString *user = @"cgm616/VolumeBar";
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://github.com/" stringByAppendingString:user]]];
}

-(void)githubButton2 {
  NSString *user = @"cgm616";
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://github.com/" stringByAppendingString:user]]];
}

-(void)twitterButton {
  NSString *user = @"cgm616";
  if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]]];

  else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:user]]];

  else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:user]]];

  else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:user]]];

  else
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]]];
}

-(void)twitterButton3 {
  NSString *user = @"bolencki13";
  if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]]];

  else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:user]]];

  else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:user]]];

  else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:user]]];

  else
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]]];
}

-(void)twitterButton4 {
  NSString *user = @"uroboro845";
  if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]]];

  else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:user]]];

  else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:user]]];

  else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:user]]];

  else
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]]];
}

-(void)twitterButton5 {
  NSString *user = @"stijn_d3sign";
  if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]]];

  else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:user]]];

  else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:user]]];

  else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:user]]];

  else
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]]];
}

-(void)libColorPicker {
  HBLogDebug(@"libColorPickerAlert called");

  CFPropertyListRef color = CFPreferencesCopyAppValue(CFSTR("bannercolor"), CFSTR("me.cgm616.volumebar"));

  if(!color)
    HBLogError(@"Error getting color value from prefs, using fallback");

  UIColor *startColor = LCPParseColorString((NSString*)color, @"#FFFFFF");

  PFColorAlert *alert = [PFColorAlert colorAlertWithStartColor:startColor showAlpha:YES];

  [alert displayWithCompletion:
    ^void (UIColor *pickedColor){
      NSString *hexString = [UIColor hexFromColor:pickedColor];
      hexString = [hexString stringByAppendingFormat:@":%g", pickedColor.alpha];

      CFPreferencesSetAppValue(CFSTR("bannercolor"), hexString, CFSTR("me.cgm616.volumebar"));
    }
  ];

  settingsChanged = YES;
}

-(void)setPreferenceValue:(id)value specifier:(PSSpecifier *)spec {
	[super setPreferenceValue:value specifier:spec];
	if (!settingsChanged) {
		settingsChanged = YES;
	}
}

@end

@interface VolumeBarTitleCell : PSTableCell <PreferencesTableCustomView> {
    UILabel *tweakTitle;
    UILabel *tweakSubtitle;
}

@end

@implementation VolumeBarTitleCell

-(id)initWithSpecifier:(PSSpecifier *)specifier {
  self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];

  if(self) {
		int width = [[UIScreen mainScreen] bounds].size.width;

		CGRect frame = CGRectMake(0, -30, width, 60);
		CGRect subtitleFrame = CGRectMake(0, 5, width, 60);

		tweakTitle = [[UILabel alloc] initWithFrame:frame];
		[tweakTitle setNumberOfLines:1];
		[tweakTitle setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:48]];
		[tweakTitle setText:@"VolumeBar"];
		[tweakTitle setBackgroundColor:[UIColor clearColor]];
		[tweakTitle setTextColor:[UIColor blackColor]];
		[tweakTitle setTextAlignment:NSTextAlignmentCenter];

		tweakSubtitle = [[UILabel alloc] initWithFrame:subtitleFrame];
		[tweakSubtitle setNumberOfLines:1];
		[tweakSubtitle setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:25]];
		[tweakSubtitle setText:@"By cgm616"];
		[tweakSubtitle setBackgroundColor:[UIColor clearColor]];
		[tweakSubtitle setTextColor:[UIColor blackColor]];
		[tweakSubtitle setTextAlignment:NSTextAlignmentCenter];

		[self addSubview:tweakTitle];
		[self addSubview:tweakSubtitle];
  }

  return self;
}

@end
// vim:ft=objc
