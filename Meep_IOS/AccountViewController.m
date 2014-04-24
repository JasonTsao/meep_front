//
//  ViewController.m
//  AccountSettings
//
//  Created by Jason Tsao on 4/21/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "AccountViewController.h"
#import "MEEPhttp.h"

@interface AccountViewController ()

@property NSArray *privacy;
@property NSArray *reminders;
@property NSArray *notifications;
@property(nonatomic, strong) NSMutableData * data;
@end

@implementation AccountViewController
    


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
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
    NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"user", field, @"field", value_string, @"value",nil];
    NSLog(@"request url %@", requestURL);
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
    NSLog(@"Handling data");
    NSLog(@"%@",jsonResponse);
    //NSArray * upcoming = jsonResponse[@"upcoming_events"];
    //NSArray * owned = jsonResponse[@"owned_upcoming_events"];
}

//- (void)checkButtonTapped:(id)sender sectionNumber:(NSInteger)section rowNumber:(NSInteger)row
- (void)privateSwitch:(id)sender
{
    UISwitch *switch_button = sender;
    NSLog(@"Tapped Private Switch! %hhd", switch_button.on);
    [self updateAccountSettingfieldName: @"private" valueName:switch_button.on];
    
}

- (void)searchableSwitch:(id)sender
{
    UISwitch *switch_button = sender;
    NSLog(@"Tapped Searchable Switch! %hhd", switch_button.on);
    [self updateAccountSettingfieldName: @"searchable" valueName:switch_button.on];
}

- (void)remindersSwitch:(id)sender
{
    UISwitch *switch_button = sender;
    NSLog(@"Tapped Reminders Switch! %hhd", switch_button.on);
    [self updateAccountSettingfieldName: @"reminder_on" valueName:switch_button.on];
}

- (void)notificationsSwitch:(id)sender
{
    UISwitch *switch_button = sender;
    NSLog(@"Tapped Notifications Switch! %hhd", switch_button.on);
    [self updateAccountSettingfieldName: @"vibrate_on_notification" valueName:switch_button.on];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    //initWithFrame:CGRectMake(cell.bounds.size.width-10,-10,23,23) == top right
    UISwitch *newSwitch=[[UISwitch alloc]initWithFrame:CGRectMake(
                                                                  cell.bounds.size.width-(cell.bounds.size.width/5.0),
                                                                  (cell.bounds.size.height/6.0),
                                                                  23,
                                                                  23)];
    [cell addSubview:newSwitch];
        
    if (indexPath.section == 0){
        cell.textLabel.text = self.privacy[indexPath.row];
        
        if (indexPath.row == 0){
            [newSwitch addTarget:self action:@selector(privateSwitch:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if(indexPath.row == 1){
            [newSwitch addTarget:self action:@selector(searchableSwitch:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    else if (indexPath.section == 1){
        cell.textLabel.text = self.reminders[indexPath.row];
        if (indexPath.row == 0){
            newSwitch.on = YES;
            [newSwitch addTarget:self action:@selector(remindersSwitch:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    else if (indexPath.section == 2){
        cell.textLabel.text = self.notifications[indexPath.row];
        if (indexPath.row == 0){
            newSwitch.on = YES;
            [newSwitch addTarget:self action:@selector(notificationsSwitch:) forControlEvents:UIControlEventTouchUpInside];
        }
        
    }
    
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.privacy = @[@"Private", @"Searchable"];
    self.reminders = @[@"Reminder"];
    self.notifications = @[@"Vibrate On Notification"];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
