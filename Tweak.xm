///////////////////////////////////////////
//
//    teleportTweak
// 
//    Alters iPhone altitude coordinates to target
//
//
//    Made by Jalby
//    August 20, 2016
//
//
///////////////////////////////////////////
#import <CoreLocation/CLLocation.h>
#import <CoreLocation/CLHeading.h>
#import <Cephei/HBPreferences.h>
#include <stdlib.h>

#define ARC4RANDOM_MAX    0x100000000

double deltaX, deltaY, deltaZ;
double targetX, targetY, targetZ;

BOOL enabled = false;
BOOL updated = false;
BOOL startedOnce = false;

static NSString *const kHBCBPreferencesDomain = @"co.jalby.iteleport";
static NSString *const kHBCBPreferencesEnabledKey = @"TeleporterOn";
static NSString *const kHBCBPreferencesLatitudeKey = @"Latitude";
static NSString *const kHBCBPreferencesLongitudeKey = @"Longitude";
static NSString *const kHBCBPreferencesAltitudeKey = @"Altitude";
static NSString *const kHBCBPreferencesUpdatedKey = @"CoordinatesUpdated";

HBPreferences *preferences;

%ctor {
    deltaX = deltaY = deltaZ = targetX = targetY = targetZ = 0;

    preferences = [[HBPreferences alloc] initWithIdentifier:kHBCBPreferencesDomain];

    [preferences registerDefaults:@{
        kHBCBPreferencesEnabledKey: @NO,
        kHBCBPreferencesUpdatedKey: @NO,
        kHBCBPreferencesLatitudeKey: @0,
        kHBCBPreferencesLongitudeKey: @0,
        kHBCBPreferencesAltitudeKey: @0
    }];

    enabled = [preferences boolForKey:kHBCBPreferencesEnabledKey];
    [preferences registerBool:&updated default:NO forKey:kHBCBPreferencesUpdatedKey];
    [preferences registerDouble:&targetX default:0 forKey:kHBCBPreferencesLatitudeKey];
    [preferences registerDouble:&targetY default:0 forKey:kHBCBPreferencesLongitudeKey];
    [preferences registerDouble:&targetZ default:0 forKey:kHBCBPreferencesAltitudeKey];
}

@interface CLLocation() 
    - (NSInteger)currentSecond; 
    - (double)fuzzy;
@end

%hook CLLocation
     %new 
    - (NSInteger)currentSecond {
        NSDate *today = [NSDate date];
        NSCalendar *gregorian = [[[NSCalendar alloc]
             initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
        NSDateComponents *components =
            [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:today];

        return [components second];
    }

    %new
    - (double)fuzzy {
        double max = 0.7;
        double min = -0.7;
        double range = max - min;

        double ret = ((double) arc4random()/ARC4RANDOM_MAX) * range + min;

        return ret;
      }

    - (CLLocationCoordinate2D)coordinate {
        if (enabled) {NSLog(@"buttonOn");}
        else
            NSLog(@"buttonOff");
        NSLog(@"[TWEAK] Coordinates from prefs (variables): %f, %f, %f", targetX, targetY, targetZ);
        NSLog(@"[TWEAK] Coordinates from prefs (RAW): %f, %f, %f", [preferences doubleForKey:kHBCBPreferencesLatitudeKey], [preferences doubleForKey:kHBCBPreferencesLongitudeKey], [preferences doubleForKey:kHBCBPreferencesAltitudeKey]);
        if (![preferences boolForKey:kHBCBPreferencesEnabledKey]) {
            NSLog(@"[TWEAK] Tweak detected BUTTON OFF.");
            return %orig;
        }

         CLLocationCoordinate2D newCoords = %orig;

         if ([preferences boolForKey:kHBCBPreferencesUpdatedKey] || !startedOnce) {
            NSLog(@"[TWEAK] Tweak detected new coordinates. Updating deltas...");
            deltaX = [preferences doubleForKey:kHBCBPreferencesLatitudeKey] - newCoords.latitude;
            deltaY = [preferences doubleForKey:kHBCBPreferencesLongitudeKey] - newCoords.longitude;
            [preferences setBool:NO forKey:kHBCBPreferencesUpdatedKey];
            startedOnce = true;
        }
        else
            NSLog(@"[TWEAK] Tweak didn't detect coordinates need updating.");

        NSLog(@"[TWEAK] Tweak deltas are: %f, %f", deltaX, deltaY);
        newCoords.latitude += deltaX;
        newCoords.longitude += deltaY;
        NSLog(@"here are current coordinates:%f and %f", newCoords.latitude, newCoords.longitude);
        return newCoords;
    }
    
    - (CLLocationDistance)altitude {
        if (![preferences boolForKey:kHBCBPreferencesEnabledKey])
            return %orig;

        NSInteger current = [self currentSecond];
        if (current  % 12 == 0) {
            //deltaZ = controller.targetZ - %orig;
        }
        CLLocationDistance modAlt = %orig + deltaZ;

        if (modAlt > targetZ + 10.0 || modAlt < targetZ - 10.0)
            modAlt = targetZ + [self fuzzy];
        if (modAlt < 0)
            modAlt = modAlt * -1;
        return modAlt;
    }
    
%end
