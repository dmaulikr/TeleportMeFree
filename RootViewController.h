typedef enum {
    LONGITUDE,
    LATITUDE,
    ALTITUDE
} COORDINATE_TYPE;

@interface RootViewController: UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    UILabel*helloLabel;
    UITableView*tableView;

}

@end
