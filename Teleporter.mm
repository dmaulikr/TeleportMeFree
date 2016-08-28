#import "Teleporter.h"

@implementation Teleporter {
    double deltaX;
    double deltaY;
    double deltaZ;

    BOOL startedOnce;

}

@synthesize targetX;
@synthesize targetY;
@synthesize targetZ;
@synthesize isActive;

- (id)initWithLatitude:(double)x Longitude:(double)y Altitude:(double)z {

    if( self = [super init] )
    {
        targetX = x;
        targetY = y;
        targetZ = z;
    }
    
    return self;

}


- (void)logCoordinates {
    NSLog(@"coords: %f, %f, %f", targetX, targetY, targetZ);
    if (isActive) { 
        NSLog(@"Teleporter active");
    }
    NSLog(@"Teleporter inactive");
}



@end

