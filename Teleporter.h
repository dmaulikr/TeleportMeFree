@interface Teleporter : NSObject {
    // Protected instance variables (not recommended)
}

@property (nonatomic) double targetX;
@property (nonatomic) double targetY;
@property (nonatomic) double targetZ;
@property (nonatomic, readonly) BOOL isActive;

- (id)initWithLatitude:(double)x Longitude:(double)y Altitude:(double)z;

- (void)logCoordinates;

@end