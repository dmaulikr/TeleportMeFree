///////////////////////////////////////////
//
//    MyAltitude
// 
//    Alters iPhone altitude coordinates to target
//
//
//    Made by Jalby
//    August 20, 2016
//
//
///////////////////////////////////////////
#import "Teleporter.h"
#import <CoreLocation/CLLocation.h>
#import <CoreLocation/CLHeading.h>
#include <stdlib.h>
#include <substrate.h>

#define ARC4RANDOM_MAX	  0x100000000

double deltaX = 0;
double deltaY = 0;
double deltaZ = 0;

double targetZ = 2.012;
double targetX = 37.808472;
double targetY = -122.410119;

BOOL startedOnce = false;

%hook CLHeading

    -(void)setCLHeadingComponentValue:(CLHeadingComponentValue)z {
    CLHeadingComponentValue newZ = 5.43;
	%orig(newZ);
    }

- (CLHeadingComponentValue)x {
	NSLog(@"someone is getting X heading...");
	return %orig;
    }

- (CLHeadingComponentValue)y {
	NSLog(@"someone is getting Y heading...");
	return %orig;
    }
    - (CLHeadingComponentValue)z {
	NSLog(@"someone is getting Z heading...");
	CLHeadingComponentValue modZ = 4.92;
	return modZ;
    }

  - (NSString*)description {
	NSLog(@"someone is getting heading description.");
	return %orig;
    }
%end

@interface CLLocation() 
    - (NSInteger)currentSecond; 
    - (double)fuzzy;
    - (CLLocationCoordinate2D) CLLocationCoordinate2DMake: (CLLocationDegrees)latitude : (CLLocationDegrees)longitude;
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
	   
	     NSLog(@"ret was %f", ret);
	     return ret;
	  }

      - (CLLocationCoordinate2D)coordinate {
	CLLocationCoordinate2D newCoords = %orig;
	if (!startedOnce) {
	    deltaX = targetX - newCoords.latitude;
	    deltaY = targetY - newCoords.longitude;
	    startedOnce = YES;
	}
	
	newCoords.latitude += deltaX;
	newCoords.longitude += deltaY;
	NSLog(@"here are current coordinates:%f and %f", newCoords.latitude, newCoords.longitude);
	//return [self CLLocationCoordinate2DMake: targetX: targetY];
	return newCoords;
    }

    -(void)setAltitude:(CLLocationDistance)altitude {
	 CLLocationDistance setAlt = 4.32;
	 %orig(setAlt);
    }
    
    - (CLLocationDistance)altitude {
	NSInteger current = [self currentSecond];
	if (current  % 12 == 0) {
	   deltaZ = targetZ - %orig;
	}
	CLLocationDistance modAlt = %orig + deltaZ;

	if (modAlt > targetZ + 10.0 || modAlt < targetZ - 10.0)
	    modAlt = targetZ + [self fuzzy];
	if (modAlt < 0)
	    modAlt = modAlt * -1;
	return modAlt;
    }
    
%end

//Here, using Logos's 'hook' construct to access the SpringBoard class. 'Hooking' basically means we want to access this class and modify the methods inside it.
%hook SpringBoard

//Now that logos knows we want to hook the header SpringBoard, we can directly 'hijack' SpringBoard's methods and modify them to run out own code instead of their original code.

//In this example, we are hijacking the method - (void)applicationDidFinishLaunching and making it run our own code. This method takes an argument, (id)application, however, you can rename the argument anything you'd like, such as (id)testName.
-(void)applicationDidFinishLaunching:(id)application {

    //Before we do anything, let's call the original method so SpringBoard knows what to do when it finishes launching. '%orig' basically means 'do whatever you were going to do before I got here'.
    %orig;
    
    
    //Now that SpringBoard has finished launching and everything turned out okay, let's make a UIAlertView to tell us that it finished respringing.
    UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"Welcome"
	message:@"This is a test."
	delegate:self
	cancelButtonTitle:@"Testing"
	otherButtonTitles:nil];
    //Now show that alert
    [alert1 show];
    //And release it. We don't want any memory leaks ;)
    [alert1 release];

}
//This lets logos know we're done hooking this header.
%end
