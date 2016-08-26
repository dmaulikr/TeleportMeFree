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
		    playerTextField.keyboardType = UIKeyboardTypeDecimalPad;
		    playerTextField.returnKeyType = UIReturnKeyNext;
            playerTextField.tag = LATITUDE;
		    break;
		case 1:
		    playerTextField.placeholder = @"Longitude";
		    playerTextField.keyboardType = UIKeyboardTypeDefault;
		    playerTextField.keyboardType = UIKeyboardTypeDecimalPad;
		    playerTextField.returnKeyType = UIReturnKeyNext;
            playerTextField.tag = LONGITUDE;
		    break;
		case 2:
		    playerTextField.placeholder = @"Altitude";
		    playerTextField.keyboardType = UIKeyboardTypeDecimalPad;
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
	    playerTextField.tag = 0;
	    //playerTextField.delegate = self;

	    playerTextField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
	    [playerTextField setEnabled: YES];
	    [cell.contentView addSubview:playerTextField];
	    playerTextField.delegate = self;
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *expression = @"^([0-9]*)(\\.([0-9]+)?)?$";
    NSString *newStr = textField.text;

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger noOfMatches = [regex numberOfMatchesInString:newStr options:0 range:NSMakeRange(0,[newStr length])];

    if (noOfMatches==0)
    {
        return NO;
    }

    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    if ([newStr containsString:@"."])
    {
        return newLength <= 6;
    }
    return newLength <= 3;

    //  return YES;
    //NSUInteger newLength = [textField.text length] + [string length] - range.length;
    //if (newLength > 12)
	//return NO;

     //if more than one decimal
     //     return NO;


     return YES;
}
#pragma mark - UITableViewDelegate
// when user tap the row, what action you want to perform
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected %d row", indexPath.row);
}

@end
