#import "TweakController.h"

@implementation TweakController {
    double deltaX;
    double deltaY;
    double deltaZ;
    NSDictionary *defs;
    BOOL startedOnce;

}

@synthesize targetX;
@synthesize targetY;
@synthesize targetZ;
@synthesize isActive;
@synthesize isReady;
@synthesize prefs;

//iOS 8
- (id)initWithPrefs:(NSDictionary*)_prefs {

    if( self = [super init] )
    {
        prefs = _prefs;
    }

    return self;

}

- (void)logCoordinates {
    NSLog(@"coords: %f, %f, %f", targetX, targetY, targetZ);
    if (isActive) { 
        NSLog(@"Controller active");
    }
    NSLog(@"Controller inactive");
    NSLog(@"Defaults are: %@", [defs description]);

}

- (void)updateTargets {
    //if (not valid coordinates OR bad plist)
    //   return
    NSLog(@"Defaults are: %@", [defs description]);
   //targetX = [defs doubleForKey:@"Latitude"];
   //targetY = [defs doubleForKey:@"Longitude"];
   //targetZ = [defs doubleForKey:@"Altitude"];
}

- (void)updatePrefs {
    // Check if system app (all system apps have this as their home directory). This path may change but it's unlikely.
    BOOL isSystem = [NSHomeDirectory() isEqualToString:@"/var/mobile"];
    // Retrieve preferences
    prefs = nil;
    if(isSystem) {
        CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("co.jalby.iteleport"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        if(keyList) {
            prefs = (NSDictionary *)CFPreferencesCopyMultiple(keyList, CFSTR("co.jalby.iteleport"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
            if(!prefs) prefs = [NSDictionary new];
            CFRelease(keyList);
        }
    }else {
        prefs = [NSDictionary dictionaryWithContentsOfFile:@"/User/Library/Preferences/co.jalby.iteleport.plist"];
    }
    NSLog(@" Controller received call to reloadPrefs.");
    if (prefs == nil)
        NSLog(@" Controller failed to set prefs.");
    else
        NSLog(@" Prefs was updated. Dictionary is as follows: %@", [prefs description]);
}



@end

