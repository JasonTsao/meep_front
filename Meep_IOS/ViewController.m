//
//  ViewController.m
//  AccountSettings
//
//  Created by Jason Tsao on 4/21/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property NSArray *privacy;
@property NSArray *reminders;
@property NSArray *notifications;
@end

@implementation ViewController
    


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

//- (void)checkButtonTapped:(id)sender sectionNumber:(NSInteger)section rowNumber:(NSInteger)row
- (void)privateSwitch:(id)sender
{
    UISwitch *switch_button = sender;
    NSLog(@"Tapped Private Switch! %hhd", switch_button.on);
}

- (void)searchableSwitch:(id)sender
{
    UISwitch *switch_button = sender;
    NSLog(@"Tapped Searchable Switch! %hhd", switch_button.on);
}

- (void)remindersSwitch:(id)sender
{
    UISwitch *switch_button = sender;
    NSLog(@"Tapped Reminders Switch! %hhd", switch_button.on);
}

- (void)notificationsSwitch:(id)sender
{
    UISwitch *switch_button = sender;
    NSLog(@"Tapped Notifications Switch! %hhd", switch_button.on);
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
