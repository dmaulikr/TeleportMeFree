typedef enum {
    LONGITUDE,
    LATITUDE,
    ALTITUDE
} COORDINATE_TYPE;

@interface RootViewController: UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    UILabel*helloLabel;
    UITableView*tableView;
    UISwitch*onSwitch;

}

@property (readonly, nonatomic) BOOL validLatitude;
@property (readonly, nonatomic) BOOL validLongitude;
@property (readonly, nonatomic) BOOL transportReady;

@end
