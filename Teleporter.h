@interface Teleporter : NSObject {
    // Protected instance variables (not recommended)
}

@property (nonatomic) double targetX;
@property (nonatomic) double targetY;
@property (nonatomic) double targetZ;

- (id)initWithLatitude:(double)x Longitude:(double)y Altitude:(double)z;

- (void)drive;

@end