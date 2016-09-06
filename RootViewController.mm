#import "RootViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation RootViewController {
     NSUserDefaults *defaults;
     NSTimer *_updateUITimer;

     CGFloat screenWidth;
     CGFloat screenHeight;

     CGFloat toolbarHeight;
     CGFloat sidebarWidth;
     CGFloat sidebarHeight;

     UITextField *latitudeText;
     UITextField *longitudeText;
     //UITextField *altitudeText;

     BOOL mapZoom;
}

    @synthesize validLatitude;
    @synthesize validLongitude;
    @synthesize validAltitude;
    @synthesize teleportReady;

    @synthesize latitude;
    @synthesize longitude;
    @synthesize altitude;

    @synthesize mapView;
    @synthesize locationManager;

- (void)resetDefaults
 {
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
	[defs removeObjectForKey:key];
    }
    [defs synchronize];
}

- (void)loadView {
	self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];

    screenWidth = self.view.frame.size.width;
    screenHeight = self.view.frame.size.height;

	self.view.backgroundColor = [UIColor whiteColor];

    validLatitude = validLongitude = teleportReady = NO;
    latitude = longitude = altitude = 0;
    validAltitude = YES;

    defaults = [NSUserDefaults standardUserDefaults];
    if (defaults == nil)
	   NSLog(@"[GUI]WARNING: NSDefaults incorrectly set.");

    NSString *cepheiRefresh = @"co.jalby.iteleport/ReloadPrefs";
    [defaults setObject:cepheiRefresh forKey:@"PostNotification"];
    [defaults setObject:@NO forKey:@"CoordinatesUpdated"];
    [defaults synchronize];

    mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    mapView.delegate = self;

    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager startUpdatingLocation];
    [self.locationManager requestWhenInUseAuthorization];
	//TODO: Lead user to prefs to enable

    //---Add map----
     mapView.showsUserLocation = YES;
    [mapView setMapType:MKMapTypeStandard];
    [mapView setZoomEnabled:YES];
    [mapView setScrollEnabled:YES];
    //[mapView setCenterCoordinate:mapView.userLocation.location.coordinate animated:YES];

    mapZoom = NO;

    [self.view addSubview:mapView];
    [mapView release];

    //--Add center image icon----
    UIImageView *centerPin = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,50,50)];
    centerPin.image = [UIImage imageNamed:@"icon.png"];
    centerPin.center = self.view.center;
    [self.view addSubview:centerPin];
    [centerPin release];

    //---Add box for coordinates and search---
    sidebarWidth = screenWidth/3.7;
    sidebarHeight = screenHeight/4;

    tableView = [[UITableView alloc] initWithFrame:CGRectMake(screenWidth - sidebarWidth,(screenHeight/2) - sidebarHeight, sidebarWidth, sidebarHeight) style:UITableViewStylePlain];

    // must set delegate & dataSource, otherwise the the table will be empty and not responsive
    tableView.delegate = self;
    tableView.dataSource = self;

    tableView.backgroundColor = [UIColor purpleColor];
    tableView.layer.cornerRadius = 5;
    tableView.layer.masksToBounds = YES;
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [tableView addGestureRecognizer:gestureRecognizer];
    [self.view addSubview:tableView];
    [gestureRecognizer release];

    //---Bottom toolbar-----
    toolbarHeight = screenHeight/6;
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight - toolbarHeight, screenWidth, toolbarHeight)];
    bottomView.backgroundColor = [UIColor blueColor];

    onSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(screenWidth/2,screenHeight - toolbarHeight,sidebarWidth,toolbarHeight)];
    [onSwitch setOnTintColor:[UIColor redColor]];
    [onSwitch addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
    onSwitch.enabled = YES;
    [onSwitch setOn:[defaults boolForKey:@"TeleporterOn"]];
    
    [self.view addSubview:bottomView];
    [self.view addSubview:onSwitch];
    [bottomView release];
    [onSwitch release];


}

/*  @name: hideKeyboard
    @param:  none
    @return: Yes?
    hideKeyboard is the function used by the sidebar on the mapView to close the
    text input box if the user taps on a location outside of the current textField
    but still inside the sidebar. 

    TODO: Keyboard closes on all taps outside of the text field, not limited to inside
    the sidebar.

*/

- (void)hideKeyboard
{
    [tableView endEditing:YES];
}

//----Begin mapview stuf----------

- (void)updateUI {
    NSLog(@"[GUI] Update GUI called. Map coordinates: %f, %f", mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude);
    latitudeText.text = [NSString stringWithFormat:@"%.8f", mapView.centerCoordinate.latitude];
    longitudeText.text = [NSString stringWithFormat:@"%.8f", mapView.centerCoordinate.longitude];

    latitude = mapView.centerCoordinate.latitude;
    longitude = mapView.centerCoordinate.longitude;

    [defaults setDouble:latitude forKey:@"Latitude"];
    [defaults setDouble:longitude forKey:@"Longitude"];
    [defaults setObject:@YES forKey:@"CoordinatesUpdated"];
    [defaults synchronize];

    teleportReady = YES;
    onSwitch.enabled = YES;
    validLatitude = validLongitude = YES;

}

- (BOOL)mapViewRegionDidChangeFromUserInteraction
{
    UIView *view = self.mapView.subviews.firstObject;
    //  Look through gesture recognizers to determine whether this region change is from user interaction
    for(UIGestureRecognizer *recognizer in view.gestureRecognizers) {
        if(recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateEnded) {
            return YES;
        }
    }

    return NO;
}

static BOOL mapChangedFromUserInteraction = NO;

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    mapChangedFromUserInteraction = [self mapViewRegionDidChangeFromUserInteraction];

    if (mapChangedFromUserInteraction) {
        [self updateUI];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (mapChangedFromUserInteraction) {
        [self updateUI];
    }
}

-(void)mapView:(MKMapView *)theMapView didUpdateUserLocation:(MKUserLocation *)userLocation 
{
    if (mapZoom)
        return;

    MKCoordinateRegion mapRegion;   
    mapRegion.center = theMapView.userLocation.coordinate;
    mapRegion.span.latitudeDelta = 0.2;
    mapRegion.span.longitudeDelta = 0.2;

    [theMapView setRegion:mapRegion animated: YES];
    mapZoom = YES;
}

//--------End MapView stuff---------------

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
	   return 3;
    else return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return sidebarHeight/4;
}

//thank you google.com and stackoverflow, couldn't have done it without u
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifier = @"HistoryCell";

    UITableViewCell *cell = (UITableViewCell*) [theTableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (cell == nil) {
	   cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
				    reuseIdentifier:kCellIdentifier] autorelease];
	   cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        if ([indexPath section] == 0) { //Section for number inputs
            UITextField *playerTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, sidebarWidth, sidebarHeight/4)];
            playerTextField.adjustsFontSizeToFitWidth = YES;
            playerTextField.textColor = [UIColor blackColor];

            switch ([indexPath row]) {
                case 0:
                    playerTextField.placeholder = @"±90";
                    playerTextField.tag = LATITUDE;
                    latitudeText = playerTextField;
                    break;

                case 1:
                    playerTextField.placeholder = @"±180";
                    playerTextField.tag = LONGITUDE;
                    longitudeText = playerTextField;
                    break;

                case 2:
                    playerTextField.placeholder = @"To the moon";
                    playerTextField.tag = ALTITUDE;
                    break;

                case 3:
                    playerTextField.placeholder = @"ERROR";
                    break;

                default:
                    break;

            }
	    
            playerTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            playerTextField.returnKeyType = UIReturnKeyNext;
	        playerTextField.backgroundColor = [UIColor whiteColor];
	        playerTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
	        playerTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
	        playerTextField.textAlignment = UITextAlignmentLeft;

	        playerTextField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
	        [playerTextField setEnabled: YES];
	        [cell.contentView addSubview:playerTextField];
	        playerTextField.delegate = self;
	        [playerTextField addTarget:self action:@selector(checkTextField:) forControlEvents:UIControlEventEditingChanged];

            NSString* coordinateString = nil;

            switch (playerTextField.tag) {
                case LATITUDE:
                    coordinateString = [NSString stringWithFormat:@"%.8f", mapView.userLocation.location.coordinate.latitude];
                    break;
		    
                case LONGITUDE:
		            coordinateString = [NSString stringWithFormat:@"%.8f", mapView.userLocation.location.coordinate.longitude];
                    break;
		    
                case ALTITUDE:
		            coordinateString = [NSString stringWithFormat:@"%.6f", [defaults doubleForKey:@"Altitude"]];
		            break;
		    
                default:
		            break;
	       }
	       
           playerTextField.text = coordinateString;

	       [playerTextField release];
        }
    
    }

return cell;	
}


//------Text Validation Functions-------------------

// checkTextField gets the final input value of a text field and makes sure that it's 
// correct. If it's not valid for our purposes, an error icon is displayed to the user.
// Otherwise, the we update the View Controller's Latitude, Longitude, and/or Altitude
// properties.
- (void)checkTextField:(id)sender {
    NSLog(@"[GUI] checkTextField called.");

    teleportReady = NO;

    UITextField *textField = (UITextField *)sender;
    NSString *checkString = textField.text;

    NSLog(@"[GUI]checkString is: %@", checkString);

    //check for a valid number
    NSString *expression = @"^(-)?([0-9]{1,5})?([,\\.]([0-9]{1,8})?)?$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:checkString options:0 range:NSMakeRange(0,[checkString length])];
    if ( numberOfMatches == 0 || !checkString.length) {
	   
       NSLog(@"[GUI] BAD NUMBER DETECTED!");
       onSwitch.enabled = NO;
	   return;
    }
    //otherwise we have a valid number
    NSString *fixedCheck = [checkString stringByReplacingOccurrencesOfString:@"," withString:@"."];
    double checkValue = [fixedCheck doubleValue];


    NSLog(@"[GUI] Editing textField with tag: %ld", (long)textField.tag);
    NSLog(@"[GUI] checkValue is: %f.", checkValue);
    switch (textField.tag) {
	case LATITUDE:
	    if ( checkValue < -90 || checkValue > 90 ) { 
            NSLog(@"[GUI] Latitude value was: %f which is invalid, not storing. Flagging invalid coordinates.", checkValue);
            validLatitude = NO;
            if (!onSwitch.isOn)
                onSwitch.enabled = NO;
            return;

	    }
	    validLatitude = YES;
	    latitude = checkValue;
	    [defaults setDouble:latitude forKey:@"Latitude"];
	    NSLog(@"[GUI] Stored %f in dictionary for LATITUDE.",latitude);
	    break;

	case LONGITUDE:
	    if ( checkValue < -180 || checkValue > 180) {
            NSLog(@"[GUI] Longitude value was: %f which is invalid, not storing. Flagging invalid coordinates.", checkValue);
            if (!onSwitch.isOn)
                onSwitch.enabled = NO;
            return;
	    }
	    validLongitude = YES;
	    longitude = checkValue;
	    [defaults setDouble:longitude forKey:@"Longitude"];
	    NSLog(@"[GUI] Stored %f in dictionary for LONGITUDE.",longitude);
	    break;

	case ALTITUDE:
	    validAltitude = YES;
	    altitude = checkValue;
	    [defaults setDouble:altitude forKey:@"Altitude"];
	    [defaults synchronize];
	    NSLog(@"[GUI] Stored %f in dictionary for ALTITUDE.", altitude);
	    break;
	    
	default:
	    NSLog(@"[GUI] ERROR: untagged text field was edited.");
	    break;   
    }

    [defaults setBool:YES forKey:@"CoordinatesUpdated"];
    [defaults synchronize];
    //NSLog(@"Dictionary is: %@", [defaults dictionaryRepresentation]);

    if (validLatitude && validLongitude && validAltitude) {
        NSLog(@"[GUI] All coordinates valid. Teleport ready");
       onSwitch.enabled = teleportReady = YES;
	   [defaults synchronize];
	   return;
    }

    NSLog(@"[GUI] Teleport not enabled for the following reasons: ");
    if (!validLatitude)
        NSLog(@"[GUI] Invalid latitude");
    if (!validLongitude)
        NSLog(@"[GUI] Invalid longitude");
    if (!validAltitude)
        NSLog(@"[GUI] Invalid altitude");

    onSwitch.enabled = teleportReady = NO;
}


// Makes sure that all inputted values in the text fields conform to what we expect them to be,
// i.e. decimal numbers with magnitudes of hundreds or thousands.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //Undo bug crash check
    if(range.length + range.location > textField.text.length)
    {
	return NO;
    }

    if (string.length > 15)
	return NO;

    NSString *checkString = [textField.text stringByReplacingCharactersInRange:range withString:string];

    //empty field OK
    if (!checkString.length)
	return YES;

    if ([checkString isEqualToString:@"-"])
	return YES;

    NSString *expression = nil;

    switch (textField.tag) {
	case LATITUDE:
	    expression = @"^(-)?([0-9]{1,2})?([,\\.]([0-9]{1,8})?)?$";
	    break;
	case LONGITUDE:
	    expression = @"^(-)?([0-9]{1,3})?([,\\.]([0-9]{1,8})?)?$";
	    break;
	case ALTITUDE:
	    expression = @"^(-)?([0-9]{1,5})?([,\\.]([0-9]{1,8})?)?$";
	    break;
	default:
	    NSLog(@"ERROR: Invalid textfield. Maybe no tag?");
	    return NO;
	    break;
    }

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:checkString options:0 range:NSMakeRange(0,[checkString length])];

    if (numberOfMatches == 0)
	return NO;

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {

}

//------End text validation------

- (void)setState:(id)sender 
{
    BOOL state = [sender isOn];
    
    if (!teleportReady && !state)
	   onSwitch.enabled = NO;
    
    if (state) {
	   NSLog(@"[GUI] set buttonOn to YES");
	   [defaults setBool:YES forKey:@"TeleporterOn"];

       NSLog(@"[GUI] Teleported with coordinates: %f, %f, %f", latitude, longitude, [defaults doubleForKey:@"Altitude"]);
    }
    else{
	   [defaults setBool:NO forKey:@"TeleporterOn"];
	   NSLog(@"[GUI] set buttonOn to NO");
    }

    [defaults synchronize];
}


#pragma mark - UITableViewDelegate
// when user tap the row, what action you want to perform
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected %ld row", (long)indexPath.row);
}

@end
