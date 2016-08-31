#import "TweakController.h"
#import <Cephei/HBPreferences.h>

//--------Class Constants---------
static NSString *const kHBCBPreferencesDomain = @"co.jalby.iteleport";
static NSString *const kHBCBPreferencesEnabledKey = @"isReady";
static NSString *const kHBCBPreferencesLatitudeKey = @"Latitude";
static NSString *const kHBCBPreferencesSwitchLabelsKey = @"SwitchLabels";
static NSString *const kHBCBPreferencesButtonKey= @"ButtonOn";

@implementation TweakController {
    double deltaX;
    double deltaY;
    double deltaZ;

    BOOL testBool;

    HBPreferences *preferences;
}

@synthesize targetX;
@synthesize targetY;
@synthesize targetZ;

@synthesize teleportOn;


- (id)init {
    preferences = [[HBPreferences alloc] initWithIdentifier:kHBCBPreferencesDomain];

    [preferences registerDefaults:@{
        kHBCBPreferencesEnabledKey: @NO,
       // kHBCBPreferencesSwitchesKey: @[ /* ... */ ],
        kHBCBPreferencesLatitudeKey: @YES,
        kHBCBPreferencesSwitchLabelsKey: @YES,
        kHBCBPreferencesButtonKey: @NO
    }];

    [preferences registerBool:&teleportOn default:NO forKey:@"isReady"];
    [preferences registerBool:&testBool default:NO forKey:kHBCBPreferencesButtonKey];

    return self;
}

- (void)logCoordinates {
    NSLog(@"coords: %f, %f, %f", targetX, targetY, targetZ);
    if (teleportOn) { 
        NSLog(@"Controller active");
    }
    NSLog(@"Controller inactive");
    NSLog(@"Defaults are: %@", [preferences description]);

}

- (void)updateTargets {
    NSLog(@"[CONTROLLER]Printing HBPreferences LATITUDE: %f", [preferences doubleForKey:kHBCBPreferencesLatitudeKey]);
    if (!preferences[@"fubaz"])
        NSLog(@"[CONTROLLER]prefs didn't have fubaz(expected)");

    if (teleportOn)
        NSLog(@"[CONTROLLER]Detected teleport online");
    else
        NSLog(@"[CONTROLLER]Detected teleport offline");

    if (testBool)
        NSLog(@"[CONTROLLER]Detected button ON (testBool)");
    else
        NSLog(@"[CONTROLLER]Detected button OFF (testBool)");

    if ([preferences boolForKey:kHBCBPreferencesButtonKey])
        NSLog(@"[CONTROLLER] Raw check for button on was YES");
    else
        NSLog(@"[CONTROLLER] Raw check for button on was NO");
    /*
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
        NSLog(@"[CONTROLLER]there was no isReady in the dictionary");*/
       
}

/*
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
        NSLog(@" Prefs was updated. Dictionary is as follows: %@", [preferences description]);
}*/



@end

