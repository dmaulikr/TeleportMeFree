#import "Teleporter.h"

@implementation Teleporter {
    // Private instance variables
    //double val;
}

@synthesize targetX;
@synthesize targetY;
@synthesize targetZ;

- (id)initWithLatitude:(double)x Longitude:(double)y Altitude:(double)z {

    if( self = [super init] )
    {
        targetX = x;
        targetY = y;
        targetZ = z;
    }
    
    return self;

}


- (void)drive {
    NSLog(@"coords: %f, %f, %f", targetX, targetY, targetZ);
}

@end