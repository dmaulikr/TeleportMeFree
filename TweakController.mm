#import "TweakController.h"
#import <Cephei/HBPreferences.h>
static NSString *const kHBCBPreferencesDomain = @"co.jalby.iteleport";
static NSString *const kHBCBPreferencesEnabledKey = @"Enabled";
//static NSString *const kHBCBPreferencesSwitchesKey = @"Switches";
static NSString *const kHBCBPreferencesLatitudeKey = @"Latitude";
static NSString *const kHBCBPreferencesSwitchLabelsKey = @"SwitchLabels";


@implementation TweakController {
    double deltaX;
    double deltaY;
    double deltaZ;
    NSDictionary *defs;
    BOOL startedOnce;

    HBPreferences *preferences;

}

@synthesize targetX;
@synthesize targetY;
@synthesize targetZ;
@synthesize isActive;
@synthesize isReady;
@synthesize prefs;


 /*
- (id)initWithPrefs:(NSDictionary*)_prefs {

    if( self = [super init] )
    {
        prefs = _prefs;
    }

    return self;

}*/

- (id)init {
    preferences = [[HBPreferences alloc] initWithIdentifier:kHBCBPreferencesDomain];

    [preferences registerDefaults:@{
        kHBCBPreferencesEnabledKey: @YES,
       // kHBCBPreferencesSwitchesKey: @[ /* ... */ ],
        kHBCBPreferencesLatitudeKey: @YES,
        kHBCBPreferencesSwitchLabelsKey: @YES
    }];

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
    NSLog(@"[CONTROLLER]Printing HBPreferences LATITUDE: %f", [preferences doubleForKey:kHBCBPreferencesLatitudeKey]);
    if (!prefs[@"fubaz"])
        NSLog(@"[CONTROLLER]prefs didn't have fubaz(expected)");

    if (prefs[@"isReady"] && [prefs[@"isReady"] boolValue]) {
        NSLog(@"[CONTROLLER]dictionary has isready!");
        targetX = [[prefs objectForKey:@"Latitude"] doubleValue];
        targetY = [[prefs objectForKey:@"Longitude"] doubleValue];
        targetZ = [[prefs objectForKey:@"Altitude"] doubleValue];

        NSLog(@"[CONTROLLER]TargetX,Y,Z: %f, %f, %f", targetX, targetY, targetZ);
    }
    else if (![prefs[@"isReady"] boolValue])
        NSLog(@"[CONTROLLER]transporter wasn't ready");
    else 
        NSLog(@"[CONTROLLER]there was no isReady in the dictionary");
       
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

