//
//  GroupEventsTableViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/12/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "GroupEventsTableViewController.h"
#import "GroupsViewController.h"
#import "Event.h"
#import "MEEPhttp.h"

@interface GroupEventsTableViewController ()

@property(nonatomic) NSInteger numDates;
@property(nonatomic, strong) NSMutableArray *datesArray;
@property(nonatomic, strong) NSMutableArray *datesSectionCountArray;
@property(nonatomic, strong) NSMutableDictionary *datesSectionCountDictionary;
@property(nonatomic, strong) NSMutableDictionary *dateEventsDictionary;


@property(nonatomic, strong) NSArray * eventArray;

@end

@implementation GroupEventsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) getUpcomingGroupEvents {
    //NSString * requestURL = [NSString stringWithFormat:@"%@upcoming/1",[MEEPhttp eventURL]];
    //NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"user", nil];
    NSString * requestURL = [NSString stringWithFormat:@"%@group/%i/upcoming",[MEEPhttp eventURL], _group.group_id];
    NSLog(@"upcoming group evente url: %@", requestURL);
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
-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    // Handle the error properly
    NSLog(@"Call Failed");
    [self getUpcomingGroupEvents];
}
-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    [self handleData]; // Deal with the data
}

-(void)handleData{
    NSError* error;
    NSDictionary * jsonResponse = [NSJSONSerialization JSONObjectWithData:_data options:0 error:&error];
    
    NSLog(@"upcoming group events jsonresponse: %@", jsonResponse);
    NSArray * upcoming = jsonResponse[@"upcoming_events"];
    NSArray * owned = jsonResponse[@"owned_upcoming_events"];
    NSString *startTime;
    NSMutableArray *unsortedEventArray = [[NSMutableArray alloc] init];
    NSInteger numRowsInSection = 0;
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
    //self.tableView.dataSource = self;
    //self.tableView.delegate = self;
    [self.tableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSMutableString *titleString = [[NSMutableString alloc] init];
    [titleString appendString: _group.name];
    [titleString appendString: @" Events"];

    self.title = titleString;
    self.eventArray = [[NSArray alloc] init];
    self.datesSectionCountArray = [[NSMutableArray alloc]init];
    self.datesSectionCountDictionary = [[NSMutableDictionary alloc] init];
    self.dateEventsDictionary = [[NSMutableDictionary alloc] init];
    self.numDates = 0;
    [self getUpcomingGroupEvents];
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupEvent" forIndexPath:indexPath];
    NSString *dateString = _datesArray[indexPath.section];
    
    NSMutableArray *eventArray = [_dateEventsDictionary objectForKey:dateString];
    Event *upcomingEvent = eventArray[indexPath.row];
    
    //Event *upcomingEvent = [_eventArray objectAtIndex:indexPath.row];
    cell.textLabel.text = upcomingEvent.description;
    NSTimeInterval startedTime = [upcomingEvent.start_time doubleValue];
    NSDate *startedDate = [[NSDate alloc] initWithTimeIntervalSince1970:startedTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a"];
    NSString * eventDate = [dateFormatter stringFromDate:startedDate];
    cell.detailTextLabel.text = eventDate;
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}




/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
    GroupTableViewController * groupPage = [segue destinationViewController];
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    [groupPage setDelegate:self];
    groupPage.group = _group;
}


@end
