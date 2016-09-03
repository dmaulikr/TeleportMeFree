#import "RootViewController.h"
@implementation RootViewController {
     NSUserDefaults *defaults;
    
}

    @synthesize validLatitude;
    @synthesize validLongitude;
    @synthesize validAltitude;
    @synthesize teleportReady;

    @synthesize latitude;
    @synthesize longitude;
    @synthesize altitude;

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
	self.view.backgroundColor = [UIColor whiteColor];
	helloLabel = [[UILabel alloc] initWithFrame:CGRectMake(21,0,self.view.frame.size.width,44)];
	helloLabel.text = @"Latitude";
	helloLabel.backgroundColor = [UIColor clearColor];
	helloLabel.textAlignment = UITextAlignmentLeft;
	[self.view addSubview:helloLabel];

    // init table view
    tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];

    // must set delegate & dataSource, otherwise the the table will be empty and not responsive
    tableView.delegate = self;
    tableView.dataSource = self;

    tableView.backgroundColor = [UIColor purpleColor];

    // add to canvas
    [self.view addSubview:tableView];

    validLatitude = validLongitude = validAltitude =  teleportReady = NO;
    latitude = longitude = altitude = 0;

    defaults = [NSUserDefaults standardUserDefaults];
    if (defaults == nil)
	NSLog(@"[GUI]WARNING: NSDefaults incorrectly set.");

    NSString *cepheiRefresh = @"co.jalby.iteleport/ReloadPrefs";
   // NSString *authMessage = @"Allow iTeleport location? Not required, but makes things easier.";
    [defaults setObject:cepheiRefresh forKey:@"PostNotification"];
    [defaults setObject:@NO forKey:@"CoordinatesUpdated"];
    [defaults synchronize];

   // [[NSBundle mainBundle] setObject:authMessage forKey:@"NSLocationWhenInUseUsageDescription"];
   // [[NSBundle mainBundle] synchronize];

    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    [self.locationManager startUpdatingLocation];
    [self.locationManager requestWhenInUseAuthorization];
    //TODO: Lead user to prefs to enable
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
	   return 3;
    else return 1;
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
	    UITextField *playerTextField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
	    playerTextField.adjustsFontSizeToFitWidth = YES;
	    playerTextField.textColor = [UIColor blackColor];
	    switch ([indexPath row]) {
		case 0:
		    playerTextField.placeholder = @"±90";
	        playerTextField.tag = LATITUDE;
		    break;
		case 1:
		    playerTextField.placeholder = @"±180";
	        playerTextField.tag = LONGITUDE;
		    break;
		case 2:
		    playerTextField.placeholder = @"To the moon";
	        playerTextField.tag = ALTITUDE;
		    break;
		case 3:
		    playerTextField.placeholder = @"ERROR";
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
        
        NSNumber* coordinateReplace = nil;
        if ([defaults boolForKey:@"TeleporterOn"]) {
            switch (playerTextField.tag) {
                case LATITUDE:
                    coordinateReplace = [NSNumber numberWithDouble:[defaults doubleForKey:@"Latitude"]];
                    break;
                case LONGITUDE:
                    coordinateReplace = [NSNumber numberWithDouble:[defaults doubleForKey:@"Longitude"]];
                    break;
                case ALTITUDE:
                    coordinateReplace = [NSNumber numberWithDouble:[defaults doubleForKey:@"Altitude"]];
                    break;
                default:
                    break;
            }
            playerTextField.text = [coordinateReplace stringValue];
        }

	    [playerTextField release];
    }
    
	else { //Section for boolean inputs (UISwitches)
	       onSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(120, 10, 185, 30)];
	       [onSwitch setOnTintColor:[UIColor redColor]];
	   [onSwitch addTarget:self action:@selector(setState:) forControlEvents:UIControlEventValueChanged];
	   [defaults boolForKey:@"TeleporterOn"] ? onSwitch.enabled = YES : onSwitch.enabled = NO;
       [onSwitch setOn:[defaults boolForKey:@"TeleporterOn"]];
	
	    if ([indexPath row] == 0) {
	       cell.textLabel.text = @"Teleport!";
	    }
	    else {
	       cell.textLabel.text = @"ERROR!!";
	    }

	[cell.contentView addSubview:onSwitch];
	[onSwitch release];
	}
    }

    if ([indexPath section] == 0) { // Latitude and Longitude
	switch ([indexPath row]) {
	    case 0: 
	       cell.textLabel.text = @"Latitude"; 
	       break;
	    case 1: 
	       cell.textLabel.text = @"Longitude"; 
	       break;
	   case 2: 
	       cell.textLabel.text = @"Altitude"; 
	       break;
	   default:
	       cell.textLabel.text = @"ERROR";
	       break;
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
    UITextField *textField = (UITextField *)sender;
    NSString *checkString = textField.text;
    teleportReady = NO;

    if (!onSwitch.isOn)
	onSwitch.enabled = NO;

    //check for a valid number
    NSString *expression = @"^(-)?([0-9]{1,5})?([,\\.]([0-9]{1,8})?)?$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:checkString options:0 range:NSMakeRange(0,[checkString length])];
    if ( numberOfMatches == 0 || !checkString.length) {
	NSLog(@"BAD NUMBER DETECTED!");
	return;
    }
    //otherwise we have a valid number
    NSString *fixedCheck = [checkString stringByReplacingOccurrencesOfString:@"," withString:@"."];
    double checkValue = [fixedCheck doubleValue];

    //default to error state
    textField.rightViewMode = UITextFieldViewModeAlways;
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 12, 32, 32)];
    imageView.image = [UIImage imageNamed:@"error.png"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    textField.rightView = imageView;

    NSLog(@"Editing textField with tag: %ld", (long)textField.tag);
    switch (textField.tag) {
	case LATITUDE:
	    if ( checkValue < -90 || checkValue > 90 ) { 
		validLatitude = NO;
		return;
	    }
	    validLatitude = YES;
	    latitude = checkValue;
	    [defaults setDouble:latitude forKey:@"Latitude"];
	    NSLog(@"Stored %f in dictionary for LATITUDE.",latitude);
	    break;

	case LONGITUDE:
	    if ( checkValue < -180 || checkValue > 180) {
		validLongitude = NO;
		return;
	    }
	    validLongitude = YES;
	    longitude = checkValue;
	    [defaults setDouble:longitude forKey:@"Longitude"];
	    NSLog(@"Stored %f in dictionary for LONGITUDE.",longitude);
	    break;

	case ALTITUDE:
	    validAltitude = YES;
	    altitude = checkValue;
	    [defaults setDouble:altitude forKey:@"Altitude"];
	    [defaults synchronize];
	    NSLog(@"Stored %f in dictionary for ALTITUDE.", altitude);
	    break;
	    
	default:
	    NSLog(@"ERROR: untagged text field was edited.");
	    break;   
    }

    [defaults setBool:YES forKey:@"CoordinatesUpdated"];
    [defaults synchronize];
    //NSLog(@"Dictionary is: %@", [defaults dictionaryRepresentation]);
    
    //clear error image if we made it out alive
    textField.rightViewMode = UITextFieldViewModeNever;
    textField.rightView = nil;

    if (validLatitude && validLongitude && validAltitude) {
	teleportReady = onSwitch.enabled = YES;
	[defaults synchronize];
	return;
    }

    teleportReady = NO;
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
    NSLog(state ? @"Button ON" : @"Button OFF");
    if (!teleportReady && !state)
	onSwitch.enabled = NO;
    if (state) {
	NSLog(@"[GUI] set buttonOn to YES");
	[defaults setBool:YES forKey:@"TeleporterOn"];
    }
    else{
	[defaults setBool:NO forKey:@"TeleporterOn"];
	NSLog(@"[GUI] set buttonOn to NO");
    }

    [defaults synchronize];
    /*
    if (validLatitude){NSLog(@"Latitude Valid");}
    if (validLongitude){NSLog(@"Longitude Valid");}
    if (validAltitude){NSLog(@"Altitude valid");}
    if (transportReady){NSLog(@"Transport ready");}*/
}


#pragma mark - UITableViewDelegate
// when user tap the row, what action you want to perform
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected %ld row", (long)indexPath.row);
}

@end
