#include <dlfcn.h>
#include <notify.h>
#include <stdio.h>
#include <stdlib.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>


int main(int argc, char **argv, char **envp) {

    NSLog(@"[DAEMON]Daemon started");

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //CLLocationManager *locationManager = [[CLLocationManager alloc] init];


    [pool release];

    NSLog(@"[DAEMON]Finished Everything, now closing");


return 0;

}

// vim:ft=objc
