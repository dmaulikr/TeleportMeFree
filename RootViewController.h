#import <CoreLocation/CoreLocation.h>

typedef enum {
    LATITUDE,
    LONGITUDE,
    ALTITUDE
} COORDINATE_TYPE;

@interface RootViewController: UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate> {
    UILabel*helloLabel;
    UITableView*tableView;
    UISwitch*onSwitch;
}

@property (readonly, nonatomic) BOOL validLatitude;
@property (readonly, nonatomic) BOOL validLongitude;
@property (readonly, nonatomic) BOOL validAltitude;
@property (readonly, nonatomic) BOOL teleportReady;

@property (readonly, nonatomic) double latitude;
@property (readonly, nonatomic) double longitude;
@property (readonly, nonatomic) double altitude;

@property (nonatomic, assign) CLLocationManager *locationManager;

- (void)resetDefaults;


@end
