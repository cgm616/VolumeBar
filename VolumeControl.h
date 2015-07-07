@class NSMutableSet, NSString;

@interface VolumeControl : NSObject

+(id)sharedVolumeControl;
-(void)_changeVolumeBy:(float)arg1;
-(float)volume;

@end
