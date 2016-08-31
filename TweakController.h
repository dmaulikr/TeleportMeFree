@interface TweakController : NSObject {
    // Protected instance variables (not recommended)
}

@property (nonatomic) double targetX;
@property (nonatomic) double targetY;
@property (nonatomic) double targetZ;

@property (nonatomic, readonly) BOOL teleportOn;

- (void)logCoordinates;
- (void)updateTargets;
//- (void)updatePrefs;

@end