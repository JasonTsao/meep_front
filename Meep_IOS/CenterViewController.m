//
//  CenterViewController.m
//  Navigation
//
//  Created by Tammy Coron on 1/19/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import "CenterViewController.h"
#import "MEEPhttp.h"
#import "Event.h"


@interface CenterViewController () <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *upcomingEventsTable;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellMain;
@property (weak, nonatomic) IBOutlet UITableView *upcomingEvents;

@property(nonatomic, strong) NSMutableArray * eventArray;

@property(nonatomic, strong) NSMutableData * data;

@end

@implementation CenterViewController

- (void)closeCreatorModal
{
    [_delegate movePanelToOriginalPosition];
}

- (void)openAccountSettings
{
    [_delegate openAccountPage];
}

- (void)openFriendsListPage
{
    [_delegate openFriendsListPage];
}

- (void)openCreateEventPage
{
    [_delegate openCreateEventPage];
}

- (void)openGroupsPage
{
    [_delegate openGroupsPage];
}


#pragma mark -
#pragma mark View Did Load/Unload
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_eventArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*static NSString *cellMainNibID = @"EventCell";
    NSLog(@"HI");
    _cellMain = [_upcomingEventsTable dequeueReusableCellWithIdentifier:cellMainNibID];
    
    if (_cellMain == nil) {
        [[NSBundle mainBundle] loadNibNamed:cellMainNibID owner:self options:nil];
    }
    
    UILabel *title = (UILabel *)[_cellMain viewWithTag:1];
    UILabel *description = (UILabel *)[_cellMain viewWithTag:2];
    if ([_eventArray count] > 0)
    {
        Event *currentRecord = [self.eventArray objectAtIndex:indexPath.row];
        NSLog(@"%@",currentRecord.description);
        NSLog(@"%@",currentRecord.name);
        
        title.text = [NSString stringWithFormat:@"%@", currentRecord.name];
        description.text = [NSString stringWithFormat:@"%@", currentRecord.description];
    }
    [self.upcomingEventsTable registerClass:[UITableViewCell class] forCellReuseIdentifier:cellMainNibID];
    return _cellMain;*/
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"upcomingEvent" forIndexPath:indexPath];
    Event *upcomingEvent = [_eventArray objectAtIndex:indexPath.row];
    cell.textLabel.text = upcomingEvent.description;
    
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
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *currentRecord = [self.eventArray objectAtIndex:indexPath.row];

    NSLog(@"displaying event: %@", currentRecord);
    [_delegate displayEventPage:currentRecord];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.eventArray = [[NSMutableArray alloc] init];
    [self getUpcomingEvents];
}

- (void) getUpcomingEvents {
    NSString * requestURL = [NSString stringWithFormat:@"%@upcoming/1",[MEEPhttp eventURL]];
    NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"user", nil];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark -
#pragma mark View Will/Did Appear

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

#pragma mark -
#pragma mark View Will/Did Disappear

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Button Actions

- (IBAction)btnMovePanelRight:(id)sender{
    UIButton * button = sender;
    switch(button.tag) {
        case 0: {
            [_delegate movePanelToOriginalPosition];
            break;
        }
            
        case 1: {
            [_delegate movePanelRight];
            break;
        }
        
        default:
            break;
    }
}

- (IBAction)openCreateEvent:(id)sender {
    [_delegate openCreateEventPage];
}

- (IBAction)openCreateEventPage:(id)sender {
    [_delegate openCreateEventPage];
}

- (IBAction)btnMovePanelLeft:(id)sender
{
    UIButton * button = sender;
    switch(button.tag) {
        case 0: {
            [_delegate movePanelToOriginalPosition];
            break;
        }
        case 1: {
            [_delegate movePanelLeft];
            break;
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark Delagate Method for capturing selected image

/*
 note: typically, you wouldn't create "duplicate" delagate methods, but we went with simplicity.
       doing it this way allowed us to show how to use the #define statement and the switch statement.
*/

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
    [self getUpcomingEvents];
}
-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    [self handleData]; // Deal with the data
}

-(void)handleData{
    NSError* error;
    NSDictionary * jsonResponse = [NSJSONSerialization JSONObjectWithData:_data options:0 error:&error];
    NSArray * upcoming = jsonResponse[@"upcoming_events"];
    NSArray * owned = jsonResponse[@"owned_upcoming_events"];
    for(NSDictionary *eventObj in upcoming) {
        Event * event = [[Event alloc] initWithDescription:eventObj[@"description"] withName:eventObj[@"name"] startTime:eventObj[@"start_time"] eventId:[eventObj[@"id"] integerValue]] ;
        [_eventArray addObject:event];
    }
    /*for(NSString *eventStr in owned) {
        NSString * description = @"empty";
        NSString * name = @"Event";
        NSDictionary * eventObj = [NSJSONSerialization JSONObjectWithData:[eventStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        if(![[eventObj valueForKey:@"name"] isEqualToString:@"\"\""]) {
            name = [eventObj valueForKey:@"name"];
            name = @"Event";
        }
        if(![[eventObj valueForKey:@"description"] isEqualToString:@"\"\""]) {
            description = [eventObj valueForKey:@"description"];
        }
        Event * event = [[Event alloc] initWithDescription:description withName:name startTime:@""];
        [self.eventArray addObject:event];
    }*/
    self.upcomingEvents.dataSource = self;
    self.upcomingEvents.delegate = self;
    [self.upcomingEvents reloadData];
    /*self.upcomingEventsTable.dataSource = self;
    self.upcomingEventsTable.delegate = self;
    [self.upcomingEventsTable reloadData];*/
}

-(void)closeEventModal {
    [_delegate returnToMain];
}

#pragma mark -
#pragma mark Default System Code

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    /*EventPageViewController * eventPage = [segue destinationViewController];
    NSIndexPath *path = [_upcomingEvents indexPathForSelectedRow];
    Event *selected_event = _eventArray[path.row];
    eventPage.currentEvent = selected_event;*/
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
