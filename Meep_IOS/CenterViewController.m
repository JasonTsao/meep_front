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
#import "MEPTextParse.h"


@interface CenterViewController () <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *upcomingEventsTable;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellMain;
@property (weak, nonatomic) IBOutlet UITableView *upcomingEvents;
@property(nonatomic) NSInteger numDates;
@property(nonatomic, strong) NSMutableArray *datesArray;
@property(nonatomic, strong) NSMutableArray *datesSectionCountArray;
@property(nonatomic, strong) NSMutableDictionary *datesSectionCountDictionary;
@property(nonatomic, strong) NSMutableDictionary *dateEventsDictionary;

@property(nonatomic, strong) NSArray * eventArray;

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

- (void)openAddFriendsPage
{
    [_delegate openAddFriendsPage];
}

#pragma mark -
#pragma mark View Did Load/Unload
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_datesArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [_datesArray objectAtIndex:section];
    NSInteger count = [[_datesSectionCountDictionary valueForKey:key] integerValue];
    return count;
    //return [_eventArray count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *dateString;
    dateString = [_datesArray objectAtIndex:section];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *startedDate = [dateFormatter dateFromString:dateString];
    
    [dateFormatter setDateFormat:@"MMM dd"];
    NSString * header = [dateFormatter stringFromDate:startedDate];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"upcomingEvent" forIndexPath:indexPath];
    NSString *dateString = _datesArray[indexPath.section];
    NSMutableArray *eventArray = [_dateEventsDictionary objectForKey:dateString];
    Event *upcomingEvent = eventArray[indexPath.row];
    
    //Event *upcomingEvent = [_eventArray objectAtIndex:indexPath.row];
    UILabel *eventHeader = [[UILabel alloc] initWithFrame:CGRectMake(60, 15, 235, 21)];
    eventHeader.text = upcomingEvent.description;
    [eventHeader setFont:[UIFont systemFontOfSize:18]];
    // cell.textLabel.text = upcomingEvent.description;
    NSTimeInterval startedTime = [upcomingEvent.start_time doubleValue];
    NSDate *startedDate = [[NSDate alloc] initWithTimeIntervalSince1970:startedTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a"];
    NSString * eventDate = [dateFormatter stringFromDate:startedDate];
    // cell.detailTextLabel.text = eventDate;
    UILabel * eventDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 35, 235, 21)];
    eventDetailLabel.text = eventDate;
    [eventDetailLabel setFont:[UIFont systemFontOfSize:12]];
    [cell.contentView addSubview:eventHeader];
    [cell.contentView addSubview:eventDetailLabel];
    NSString * description = upcomingEvent.description;
    NSString * category = [MEPTextParse identifyCategory:description];
    NSString * imageFileName = @"tree60.png";
    if ([category isEqualToString:@"meal"]) {
        imageFileName = @"fork.png";
    }
    else if ([category isEqualToString:@"nightlife"]) {
        imageFileName = @"jumping2.png";
    }
    else if ([category isEqualToString:@"drinks"]) {
        imageFileName = @"glass16";
    }
    else if ([category isEqualToString:@"meeting"]) {
        imageFileName = @"communities.png";
    }
    else if ([category isEqualToString:@"outdoors"]) {
        imageFileName = @"sun23.png";
    }
    // Insert event icon into the cell.
    UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 44, 44)];
    img.image = [UIImage imageNamed:imageFileName];
    [cell.contentView addSubview:img];
    
    return cell;
}


 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }


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
    NSString *dateString = _datesArray[indexPath.section];
    NSMutableArray *eventArray = [_dateEventsDictionary objectForKey:dateString];
    Event *currentRecord = eventArray[indexPath.row];
    //Event *currentRecord = [self.eventArray objectAtIndex:indexPath.row];

    [_delegate displayEventPage:currentRecord];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.eventArray = [[NSMutableArray alloc] init];
    self.eventArray = [[NSArray alloc] init];
    self.datesSectionCountArray = [[NSMutableArray alloc]init];
    self.datesSectionCountDictionary = [[NSMutableDictionary alloc] init];
    self.dateEventsDictionary = [[NSMutableDictionary alloc] init];
    self.numDates = 0;
    [self getUpcomingEvents];
    
}

- (void) getUpcomingEvents {
    //NSString * requestURL = [NSString stringWithFormat:@"%@upcoming/1",[MEEPhttp eventURL]];
    //NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"user", nil];
    NSString * requestURL = [NSString stringWithFormat:@"%@upcoming",[MEEPhttp eventURL]];
    NSDictionary * postDict = [[NSDictionary alloc] init];
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
    NSString *startTime;
    NSMutableArray *unsortedEventArray = [[NSMutableArray alloc] init];
    _datesArray = [[NSMutableArray alloc] init];
    for(NSDictionary *eventObj in upcoming) {
        if( [eventObj[@"start_time"]  isEqual:[NSNull null]]){
            startTime = eventObj[@"created"];
        }
        else{
            startTime = eventObj[@"start_time"];
        }
        
        Event * event = [[Event alloc] initWithDescription:eventObj[@"description"] withName:eventObj[@"name"] startTime:startTime eventId:[eventObj[@"id"] integerValue]] ;
        event.locationName = eventObj[@"location_name"];
        event.locationAddress = eventObj[@"location_address"];
        event.end_time = eventObj[@"end_time"];
        //event.group = eventObj[@"group"];
        
        //getting number of differnt days
        NSTimeInterval startedTime = [startTime doubleValue];
        NSDate *startedDate = [[NSDate alloc] initWithTimeIntervalSince1970:startedTime];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString * eventDate = [dateFormatter stringFromDate:startedDate];
        if (![_datesArray containsObject: eventDate]){
            [_datesArray addObject:eventDate];
            [_datesSectionCountDictionary setValue:@"1" forKey:eventDate];
            
            NSMutableArray *dateEventArray = [[NSMutableArray alloc] init];
            [dateEventArray addObject:event];
            [_dateEventsDictionary setObject:dateEventArray forKey:eventDate];
            
        }
        else{
            NSInteger currentCount = [[_datesSectionCountDictionary valueForKey:eventDate] integerValue];
            currentCount++;
            NSString *newCount = [NSString stringWithFormat:@"%i", currentCount];
            
            [_datesSectionCountDictionary setValue:newCount forKey:eventDate];
            
            [[_dateEventsDictionary valueForKey:eventDate] addObject:event];
        }
        
        //Event * event = [[Event alloc] initWithDescription:eventObj[@"description"] withName:eventObj[@"name"] startTime:startTime eventId:[eventObj[@"id"] integerValue]] ;
        //[unsortedEventArray addObject:event];
    }
    
    NSSortDescriptor* nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start_time" ascending:YES];
    _eventArray = [unsortedEventArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameSortDescriptor]];
    self.upcomingEvents.dataSource = self;
    self.upcomingEvents.delegate = self;
    [self.upcomingEvents reloadData];
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
