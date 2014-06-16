//
//  NotificationsTableViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/25/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "NotificationsTableViewController.h"
#import "MEEPhttp.h"
#import "jsonParser.h"
#import "MEPTableCell.h"
#import "EventPageViewController.h"
#import "Event.h"
#import "GroupEventsTableViewController.h"
#import "Group.h"

@interface NotificationsTableViewController ()
@property(nonatomic, strong) NSMutableArray *notifications_list;
@property (nonatomic, strong) EventPageViewController *eventPageViewController;
@property (nonatomic, strong) GroupEventsTableViewController *groupEventsTableViewController;
@property (nonatomic, strong) Group * selectedGroup;
@end

@implementation NotificationsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)backToCenterFromNotifications:(id)sender {
    [_delegate backToCenterFromNotifications:self];
}

- (void)getNotifications
{
    NSString * requestURL = [NSString stringWithFormat:@"%@get",[MEEPhttp notificationsURL]];
    NSLog(@"requesturl: %@", requestURL);
    NSDictionary * postDict = [[NSDictionary alloc] init];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}


- (void)getEvent:(NSString*)event_id
{
    NSString * requestURL = [NSString stringWithFormat:@"%@%@",[MEEPhttp eventURL], event_id];
    NSLog(@"requesturl: %@", requestURL);
    NSDictionary * postDict = [[NSDictionary alloc] init];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void)getGroup:(NSString*)group_id
{
    NSString * requestURL = [NSString stringWithFormat:@"%@group/%@",[MEEPhttp accountURL], group_id];
    NSLog(@"requesturl: %@", requestURL);
    NSDictionary * postDict = [[NSDictionary alloc] init];
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
-(void)connection:(NSURLConnection*)	connection didFailWithError:(NSError*)error
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
    
    if([jsonResponse objectForKey:@"notifications"]){
        NSArray * notifications = jsonResponse[@"notifications"];
        _notifications_list = [jsonParser notificationsArray:notifications];
        [self.tableView reloadData];
    }
    else if([jsonResponse objectForKey:@"event"]){
        Event *event = [jsonParser eventObject:jsonResponse[@"event"]];
        [self displayEventPage:event];
    }
    else if([jsonResponse objectForKey:@"group"]){
        _selectedGroup = [jsonParser groupObject:jsonResponse[@"group"]];
        [self performSegueWithIdentifier:@"groupFromNotifications" sender:self];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Notifications";
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backToCenterFromNotifications:)];
    
    self.navigationItem.leftBarButtonItem = customBarItem;
    _notifications_list = [[NSMutableArray alloc] init];
    
    [self getNotifications];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) backToCenterFromEventPage:(EventPageViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)displayEventPage:(Event *)event{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    self.eventPageViewController = (EventPageViewController *)[storyboard instantiateViewControllerWithIdentifier:@"EventViewController"];
    _eventPageViewController.currentEvent = event;
    NSString *event_id = [NSString stringWithFormat:@"%i", event.event_id];
    
    /* FOR CHANGING THE NOTIFICATON BADGE ICON NUMBER
     NSString *allevents = [NSString stringWithFormat:@"%@", _eventNotifications];
    
    if([_eventNotifications objectForKey:event_id]){
        NSArray *event_notifications = _eventNotifications[event_id];
        
        // set notifications for event page
        _eventPageViewController.notifications = _eventNotifications[event_id];
        
        //code for effectively saying you've viewed these notifications and persist that
        NSInteger numNotificationsForEvent = [_eventNotifications[event_id] count];
        [_eventNotifications removeObjectForKey:event_id];
        
        // remove the event notifications from user defaults
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_eventNotifications];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"eventNotifications"];
        [NSUserDefaults resetStandardUserDefaults];
        [UIApplication sharedApplication].applicationIconBadgeNumber -= numNotificationsForEvent;
    }
    */
    
    [self.eventPageViewController setDelegate:self];
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_eventPageViewController];
    [self presentViewController:navigation animated:YES completion:nil];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MEPTableCell customFriendCellHeight];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [_notifications_list count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Notification * selected = [_notifications_list objectAtIndex:indexPath.row];
    //[_delegate displayEventPage:currentRecord];
    NSLog(@"selected notifications: %@", selected.type);
    if(selected.custom_payload[@"event_id"]){
        Event *event;
        if([selected.type isEqualToString:@"event_chat"]){
            //GO TO EVENT CHAT PAGE
            [self getEvent:selected.custom_payload[@"event_id"]];
        }
        else if([selected.type isEqualToString:@"event_create"] || [selected.type isEqualToString:@"event_update"] ){
            [self getEvent:selected.custom_payload[@"event_id"]];
        }
    }
    
    if([selected.type isEqualToString:@"group_added"]){
        if(selected.custom_payload[@"group_id"]){
            [self getGroup:selected.custom_payload[@"group_id"]];
        }
    }
    
    if([selected.type isEqualToString:@"friend_added"]){
        
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    UITableViewCell *cell;
    
    cell = [MEPTableCell customNotificationcell:_notifications_list[indexPath.row] forTable:tableView selected:NO];
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    GroupEventsTableViewController * groupEvents = [segue destinationViewController];
    //NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    [groupEvents setDelegate:self];
    groupEvents.group = _selectedGroup;
}

@end
