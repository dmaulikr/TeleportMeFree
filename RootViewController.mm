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

        UISwitch *onSwitch = [[UISwitch alloc] initWithFrame: CGRectZero];
        [self.view addSubview:onSwitch];

// init table view
    tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];

    // must set delegate & dataSource, otherwise the the table will be empty and not responsive
    tableView.delegate = self;
    tableView.dataSource = self;

    tableView.backgroundColor = [UIColor cyanColor];

    // add to canvas
    [self.view addSubview:tableView];
}

#pragma mark - UITableViewDataSource
// number of section(s), now I assume there is only 1 section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

// number of row in the section, I assume there is only 1 row
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

/* the cell will be returned to the tableView
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"HistoryCell";
 
    UITableViewCell *cell = (UITableViewCell *)[theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    // Just want to test, so I hardcode the data
    cell.textLabel.text = @"Testing";

    return cell;
}*/

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifier = @"HistoryCell";

    UITableViewCell *cell = (UITableViewCell*) [theTableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                   reuseIdentifier:kCellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;

        if ([indexPath section] == 0) { //Starting a new section
            UITextField *playerTextField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
            playerTextField.adjustsFontSizeToFitWidth = YES;
            playerTextField.textColor = [UIColor blackColor];
            switch ([indexPath row]) {
                case 0:
                    playerTextField.placeholder = @"Latitude";
                    playerTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                    playerTextField.returnKeyType = UIReturnKeyNext;
                    break;
                case 1:
                    playerTextField.placeholder = @"Longitude";
                    playerTextField.keyboardType = UIKeyboardTypeDefault;
                    playerTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                    playerTextField.returnKeyType = UIReturnKeyNext;
                    break;
                case 2:
                    playerTextField.placeholder = @"Altitude";
                    playerTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
                    break;
                default:
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

            [playerTextField release];
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
else { // Login button section
    cell.textLabel.text = @"Log in";
}
return cell;    
}


#pragma mark - UITableViewDelegate
// when user tap the row, what action you want to perform
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected %d row", indexPath.row);
}

@end
