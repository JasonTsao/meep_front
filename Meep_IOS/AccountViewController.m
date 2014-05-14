//
//  ViewController.m
//  AccountSettings
//
//  Created by Jason Tsao on 4/21/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "AccountViewController.h"
#import "MEEPhttp.h"
#import "AccountSettings.h"
#import "MEPAppDelegate.h"
#import "DjangoAuthClient.h"

@interface AccountViewController ()

@property NSArray *privacy;
@property NSArray *reminders;
@property NSArray *notifications;
@property(nonatomic, strong) NSMutableData * data;
@property(nonatomic, strong) AccountSettings * user_account_settings;
@property(nonatomic, strong) DjangoAuthClient * authClient;

@property BOOL privacy_allowed;
@property BOOL search_allowed;
@property BOOL reminders_allowed;
@property BOOL vibrate_on_notification;
@end

@implementation AccountViewController

- (IBAction)backToMain:(id)sender {
    [self.delegate backToCenterFromAccountSettings:self];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *header;
    if (section == 0){
        header = @"Privacy";
    }
    else if(section == 1){
        header = @"Reminders";
    }
    else if(section == 2){
        header = @"Notifications";
    }
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 1;
    if (section == 0){
        numRows = [self.privacy count];
    }
    else if(section == 1){
        numRows = [self.reminders count];
    }
    else if(section == 2){
        numRows = [self.notifications count];
    }
    else if(section == 3){
        numRows = 1;
    }
    return numRows;
}

- (void) updateAccountSettingfieldName:(NSString *)field valueName:(BOOL) value
{
    NSString * requestURL = [NSString stringWithFormat:@"%@settings/update",[MEEPhttp accountURL]];
    NSLog(@"field: %@", field);
    NSLog(@"value: %hhd", value);
    NSString * value_string;

    if (value){
        value_string = @"true";
    }
    else{
        value_string = @"false";
    }
    //[NSNumber numberWithBool:value]
    //NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"user", field, @"field", value_string, @"value",nil];
    NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:field, @"field", value_string, @"value",nil];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    _data = [[NSMutableData alloc] init]; // _data being an ivar
}
-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    [_data appendData:data];
}
-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    // Handle the error properly
    NSLog(@"Call Failed");
}
-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    [self handleData]; // Deal with the data
}


-(void)handleData{
    NSError* error;
    NSDictionary * jsonResponse = [NSJSONSerialization JSONObjectWithData:_data options:0 error:&error];

    //NSArray * upcoming = jsonResponse[@"upcoming_events"];
    //NSArray * owned = jsonResponse[@"owned_upcoming_events"];
}

//- (void)checkButtonTapped:(id)sender sectionNumber:(NSInteger)section rowNumber:(NSInteger)row
- (void)privateSwitch:(id)sender
{
    UISwitch *switch_button = sender;
    _user_account_settings.user_is_private = switch_button.on;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_user_account_settings];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"account_settings"];
    [NSUserDefaults resetStandardUserDefaults];
    [self updateAccountSettingfieldName: @"private" valueName:switch_button.on];
    
}

- (void)searchableSwitch:(id)sender
{
    UISwitch *switch_button = sender;
    _user_account_settings.searchable = switch_button.on;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_user_account_settings];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"account_settings"];
    [NSUserDefaults resetStandardUserDefaults];
    [self updateAccountSettingfieldName: @"searchable" valueName:switch_button.on];
}

- (void)remindersSwitch:(id)sender
{
    UISwitch *switch_button = sender;
    _user_account_settings.reminders = switch_button.on;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_user_account_settings];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"account_settings"];
    [NSUserDefaults resetStandardUserDefaults];
    [self updateAccountSettingfieldName: @"reminder_on" valueName:switch_button.on];
}

- (void)notificationsSwitch:(id)sender
{
    UISwitch *switch_button = sender;
    _user_account_settings.vibrate_on_notification = switch_button.on;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_user_account_settings];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"account_settings"];
    [NSUserDefaults resetStandardUserDefaults];
    [self updateAccountSettingfieldName: @"vibrate_on_notification" valueName:switch_button.on];
}

- (void) logoutSelect
{
    NSLog(@"selected logout");
    NSData *authenticated = [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_client"];
    _authClient = [NSKeyedUnarchiver unarchiveObjectWithData:authenticated];

    _authClient.enc_serverDidAuthenticate = NO;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_authClient];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"auth_client"];
    [NSUserDefaults resetStandardUserDefaults];

    //[_delegate logout:self];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"clicked button at index");
    switch (popup.tag) {
        case 1: {
            NSLog(@"case 1");
            NSLog(@"button index: %i", buttonIndex);
            switch (buttonIndex) {
                case 0:
                    NSLog(@"case 0");
                    [self logoutSelect];
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 3){
        if(indexPath.row == 0){
            NSLog(@"logout");
            UIActionSheet *logoutPopup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Logout", nil];
            logoutPopup.tag = 1;
            [logoutPopup showInView:self.view];
            
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    //initWithFrame:CGRectMake(cell.bounds.size.width-10,-10,23,23) == top right
    
    if (indexPath.section != 3){
        UISwitch *newSwitch=[[UISwitch alloc]initWithFrame:CGRectMake(
                                                                      cell.bounds.size.width-(cell.bounds.size.width/5.0),
                                                                      (cell.bounds.size.height/6.0),
                                                                      23,
                                                                      23)];
        [cell addSubview:newSwitch];
        
        if (indexPath.section == 0){
            cell.textLabel.text = self.privacy[indexPath.row];
            
            if (indexPath.row == 0){
                newSwitch.on = _user_account_settings.user_is_private;
                [newSwitch addTarget:self action:@selector(privateSwitch:) forControlEvents:UIControlEventTouchUpInside];
            }
            else if(indexPath.row == 1){
                newSwitch.on = _user_account_settings.searchable;
                [newSwitch addTarget:self action:@selector(searchableSwitch:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        else if (indexPath.section == 1){
            cell.textLabel.text = self.reminders[indexPath.row];
            if (indexPath.row == 0){
                //newSwitch.on = YES;
                newSwitch.on =  _user_account_settings.reminders;
                [newSwitch addTarget:self action:@selector(remindersSwitch:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        else if (indexPath.section == 2){
            cell.textLabel.text = self.notifications[indexPath.row];
            if (indexPath.row == 0){
                //newSwitch.on = YES;
                newSwitch.on =  _user_account_settings.vibrate_on_notification;
                [newSwitch addTarget:self action:@selector(notificationsSwitch:) forControlEvents:UIControlEventTouchUpInside];
            }
            
        }
    }
    
        
    
    else if (indexPath.section == 3){
        cell.textLabel.text= @"Logout";
    }
    
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.privacy = @[@"Private", @"Searchable"];
    self.reminders = @[@"Reminder"];
    self.notifications = @[@"Vibrate On Notification"];

    NSLog(@"Settings from archive");
    NSData *settingsData = [[NSUserDefaults standardUserDefaults] objectForKey:@"account_settings"];
    _user_account_settings = [NSKeyedUnarchiver unarchiveObjectWithData:settingsData];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
