#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>

typedef enum {
    LATITUDE,
    LONGITUDE,
    ALTITUDE
} COORDINATE_TYPE;

@interface RootViewController: UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate> {
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

@property(nonatomic, retain) MKMapView *mapView;

@property (nonatomic, assign) CLLocationManager *locationManager;

- (void)resetDefaults;


@end
