#import "RootViewController.h"

@implementation RootViewController
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

	if ([indexPath section] == 0) { //Section for number inputs
	    UITextField *playerTextField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
	    playerTextField.adjustsFontSizeToFitWidth = YES;
	    playerTextField.textColor = [UIColor blackColor];
	    switch ([indexPath row]) {
		case 0:
		    playerTextField.placeholder = @"Latitude";
		    playerTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
		    playerTextField.returnKeyType = UIReturnKeyNext;
            playerTextField.tag = LATITUDE;
		    break;
		case 1:
		    playerTextField.placeholder = @"Longitude";
		    playerTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
		    playerTextField.returnKeyType = UIReturnKeyNext;
            playerTextField.tag = LONGITUDE;
		    break;
		case 2:
		    playerTextField.placeholder = @"Altitude";
		    playerTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            playerTextField.tag = ALTITUDE;
		    break;
		case 3:
		    playerTextField.placeholder = @"ERROR";
		    break;
	    }
	    
	    playerTextField.backgroundColor = [UIColor whiteColor];
	    playerTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
	    playerTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
	    playerTextField.textAlignment = UITextAlignmentLeft;
	    //playerTextField.delegate = self;

	    playerTextField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
	    [playerTextField setEnabled: YES];
	    [cell.contentView addSubview:playerTextField];
	    playerTextField.delegate = self;
        [playerTextField addTarget:self action:@selector(checkTextField:) forControlEvents:UIControlEventEditingChanged];
	    [playerTextField release];
    }
    
        else { //Section for boolean inputs (UISwitches)
	       UISwitch *onSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(120, 10, 185, 30)];
	       [onSwitch setOnTintColor:[UIColor redColor]];
	
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


- (void)checkTextField:(id)sender {
    return;
    /*UITextField *textField = (UITextField *)sender;
    if ([textField.text characterAtIndex:0] == '.')
        textField.text = [@"0" stringByAppendingString: textField.text];*/
}



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

    NSString *checkString = textField.text;
    
    //NSString *zero = @"0";

    //fix checkString if needed
    /*
    if ([checkString characterAtIndex:0] == '.') {
        checkString = [zero stringByAppendingString: checkString];
        NSLog(@"checkstring was changed and is now: %@", checkString);
    }*/

    //check for a valid number
    NSString *expression = @"^(-)?([0-9]{1,5})([,\\.]([0-9]{1,8})?)?$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:checkString options:0 range:NSMakeRange(0,[checkString length])];
    if ( numberOfMatches == 0) {
        NSLog(@"BAD NUMBER DETECTED!");
        //display an error message to the user. need valid number.
        return;
    }

    //otherwise we have a number
    double checkValue = [checkString doubleValue];

    switch (textField.tag) {
        case LATITUDE:
            if ( checkValue < -90 || checkValue > 90 ) {
                NSLog(@"Invalid LATITUDE detected. Need value from -90 to 90 only.");
                //display invalid latitude to user
                return;
            }
            //latitudeValid = YES;
            break;
        case LONGITUDE:
            if ( checkValue < -180 || checkValue > 180) {
                NSLog(@"Invalid LONGITUDE detected. Values range from -180 to 180.");
                //display invalid longitude msg to user
                return;
            }
            //longitudeValid = YES;
            break;
        case ALTITUDE:
            if ( checkValue < -800 || checkValue > 6000) {
                NSLog(@"WARNING: Strange altitudes detected. Travel safely.");
                //warn user that they're being dumb, but don't prevent val
            }
            //altitudeSafe = YES;
            break;
        default:
            NSLog(@"ERROR: untagged text field was edited.");
            break;   
    }

    NSLog(@"Coordinate was valid!");
    //if (latitudeValid && longitudeValid)
    //  transportSwitchEnabled = YES;
    //transportSwitchEnabled = NO;
}


#pragma mark - UITableViewDelegate
// when user tap the row, what action you want to perform
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected %d row", indexPath.row);
}

@end
