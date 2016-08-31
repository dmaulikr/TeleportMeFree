@interface TweakController : NSObject {
    // Protected instance variables (not recommended)
}

@property (nonatomic) double targetX;
@property (nonatomic) double targetY;
@property (nonatomic) double targetZ;

@property (nonatomic, retain) NSDictionary* prefs;
@property (nonatomic, readonly) BOOL isReady;
@property (nonatomic, readonly) BOOL isActive;

- (void)logCoordinates;
- (void)updateTargets;
- (void)updatePrefs;

@end