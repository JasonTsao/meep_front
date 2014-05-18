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
#import "MEPLocationService.h"
#import <CoreLocation/CoreLocation.h>


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

@property (nonatomic, strong) CLLocationManager * locationManager;

@end

@implementation CenterViewController

- (void)closeCreatorModal
{
    [_delegate movePanelToOriginalPosition];
}

- (void) openProfilePage
{
    [_delegate openProfilePage];
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

/*
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
 */

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *dateString;
    dateString = [_datesArray objectAtIndex:section];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *startedDate = [dateFormatter dateFromString:dateString];
    
    [dateFormatter setDateFormat:@"MMM dd"];
    NSString * header = [dateFormatter stringFromDate:startedDate];
    
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, tableView.sectionHeaderHeight)];
    
    UIView * horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(28, headerView.frame.size.height/2, tableView.frame.size
                                                                       .width, 1)];
    horizontalLine.backgroundColor = [UIColor blackColor];
    UIView * verticalLine = [[UIView alloc] initWithFrame:CGRectMake(28, 0, 1, headerView.frame.size.height)];
    verticalLine.backgroundColor = [UIColor blackColor];
    UIView * headerContainer = [[UIView alloc] initWithFrame:CGRectMake(headerView.frame.size.width/5, 0, headerView.frame.size.width, headerView.frame.size.height)];
    UILabel * headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, headerContainer.frame.size.width, headerContainer.frame.size.height)];
    headerContainer.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f];
    headerTitle.text = header;
    [headerTitle setFont:[UIFont fontWithName:@"Courier-BoldOblique" size:10]];
    [headerContainer addSubview:headerTitle];
    
    [headerView addSubview:verticalLine];
    [headerView addSubview:horizontalLine];
    [headerView addSubview:headerContainer];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell*)clearCell:(UITableViewCell *)cell{
    for(UIView *view in cell.contentView.subviews){
        if ([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"upcomingEvent" forIndexPath:indexPath];
    cell = [self clearCell:cell];
    NSString *dateString = _datesArray[indexPath.section];
    NSMutableArray *eventArray = [_dateEventsDictionary objectForKey:dateString];
    Event *upcomingEvent = eventArray[indexPath.row];
    /*
    //Event *upcomingEvent = [_eventArray objectAtIndex:indexPath.row];
    UILabel *eventHeader = [[UILabel alloc] initWithFrame:CGRectMake(60, 15, 235, 21)];
    eventHeader.text = upcomingEvent.description;
    [eventHeader setFont:[UIFont systemFontOfSize:18]];
    // cell.textLabel.text = upcomingEvent.description;
    NSTimeInterval startedTime = [upcomingEvent.start_time doubleValue];
    NSDate *startedDate = [[NSDate alloc] initWithTimeIntervalSince1970:startedTime];
    //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@"h:mm a"];
    //NSString * eventDate = [dateFormatter stringFromDate:startedDate];
    NSString * eventDateMessage = [MEPTextParse getTimeUntilDateTime:startedDate];
    // cell.detailTextLabel.text = eventDate;
    UILabel * eventDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 35, 235, 21)];
    eventDetailLabel.text = eventDateMessage;
    [eventDetailLabel setFont:[UIFont systemFontOfSize:12]];
    [cell.contentView addSubview:eventHeader];
    [cell.contentView addSubview:eventDetailLabel];
     */
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
    // UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 44, 44)];
    // img.image = [UIImage imageNamed:imageFileName];
    // [cell.contentView addSubview:img];
    // return cell;
    return [self createCustomCellView:cell forEvent:upcomingEvent withImage:[UIImage imageNamed:imageFileName]];
}


- (UITableViewCell *) createCustomCellView:(UITableViewCell*)cell
                                  forEvent:(Event*)event
                                 withImage:(UIImage*)image{
    
    float imageHeight = 40;
    float imageXCoord = 8;
    float imageYCoord = (cell.frame.size.height/2) - (imageHeight/2);
    float vertLineXCoord = (imageHeight/2) + imageXCoord;
    float contentBoxXCoord = imageXCoord + imageHeight + 12;
    float contentBoxYCoord = 12;
    float contentBoxWidth = cell.frame.size.width - contentBoxXCoord - 30;
    float contentBoxHeight = cell.frame.size.height - (contentBoxYCoord * 2);
    
    // This view covers the line separator between the cells.
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1)];
    separatorLineView.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f];
    [cell addSubview:separatorLineView];
    
    // This view creates the vertical line that lies behind the image.
    UIView * verticalLine = [[UIView alloc] initWithFrame:CGRectMake(vertLineXCoord, 0, 1, cell.frame.size.height)];
    verticalLine.backgroundColor = [UIColor blackColor];
    [cell addSubview:verticalLine];
    
    // This view creates the horizontal line between the image and the content frames.
    UIView * horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(20, (cell.frame.size.height/2), (cell.frame.size.width/2), 1)];
    horizontalLine.backgroundColor = [UIColor blackColor];
    [cell addSubview:horizontalLine];
    
    // This view creates the black background which the image and mid ground lie on top of.
    UIView * imageBackGround = [[UIView alloc] initWithFrame:CGRectMake(imageXCoord - 1, imageYCoord - 1, imageHeight + 2, imageHeight + 2)];
    imageBackGround.layer.cornerRadius = 21;
    imageBackGround.backgroundColor = [UIColor blackColor];
    [cell addSubview:imageBackGround];
    
    // This view creates the white background for the image.
    UIView * imageBackMid = [[UIView alloc] initWithFrame:CGRectMake(imageXCoord, imageYCoord, imageHeight, imageHeight)];
    imageBackMid.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f];
    imageBackMid.layer.cornerRadius = 20;
    [cell addSubview:imageBackMid];
    
    // This view creates uses the image provided in the parameters to display the image on top of the background and midground
    UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(imageXCoord, imageYCoord, imageHeight, imageHeight)];
    if (![event.yelpImageLink isEqual:[NSNull null]] && [event.yelpImageLink length] > 1) {
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:event.yelpImageLink]]];
    }
    img.image = image;
    img.layer.cornerRadius = imageHeight/2;
    [cell addSubview:img];
    
    // This view creates the background for the content
    UIView * contentFrame = [[UIView alloc] initWithFrame:CGRectMake(contentBoxXCoord - 1, contentBoxYCoord - 1, contentBoxWidth + 2, contentBoxHeight + 2)];
    contentFrame.layer.cornerRadius = 6;
    contentFrame.backgroundColor = [UIColor blackColor];
    [cell addSubview:contentFrame];
    
    // This view contains the data fields and is placed on top of the background view.
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(contentBoxXCoord, contentBoxYCoord, contentBoxWidth, contentBoxHeight)];
    contentView.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f];
    contentView.layer.cornerRadius = 5;
    
    float detailXCoord = 10;
    float detailYCoord = contentView.frame.size.height * 6/8 - 5;
    UILabel * eventDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(detailXCoord, detailYCoord, (contentView.frame.size.width/2 ) - 6, 21)];
    
    NSTimeInterval startedTime = [event.start_time doubleValue];
    NSDate *startedDate = [[NSDate alloc] initWithTimeIntervalSince1970:startedTime];
    NSString * eventDateMessage = [MEPTextParse getTimeUntilDateTime:startedDate];
    eventDetailLabel.text = eventDateMessage;
    eventDetailLabel.textColor = [UIColor grayColor];
    [eventDetailLabel setFont:[UIFont systemFontOfSize:8.5]];
    [contentView addSubview:eventDetailLabel];
    
    UILabel *eventHeader = [[UILabel alloc] initWithFrame:CGRectMake(6, 3, contentView.frame.size.width - 12, 40)];
    eventHeader.text = event.description;
    [eventHeader setFont:[UIFont systemFontOfSize:14]];
    eventHeader.lineBreakMode = UILineBreakModeWordWrap;
    eventHeader.numberOfLines = 0;
    [contentView addSubview:eventHeader];
    
    [cell addSubview:contentView];
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

- (void)refresh:(UIRefreshControl *)refreshControl {
    [self getUpcomingEvents];
    [refreshControl endRefreshing];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Get Location Data
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [_locationManager startUpdatingLocation];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.upcomingEvents addSubview:refreshControl];
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
    NSLog(@"center view appeared");
    //[self getUpcomingEvents];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    [_upcomingEvents reloadData];
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
    NSLog(@"%@",error);
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
        if ([eventObj[@"start_time"]  isEqual:[NSNull null]]){
            startTime = eventObj[@"created"];
        }
        else {
            startTime = eventObj[@"start_time"];
        }
        
        Event * event = [[Event alloc] initWithDescription:eventObj[@"description"] withName:eventObj[@"name"] startTime:startTime eventId:[eventObj[@"id"] integerValue]] ;
        event.locationName = eventObj[@"location_name"];
        event.locationAddress = eventObj[@"location_address"];
        event.end_time = eventObj[@"end_time"];
        event.yelpLink = eventObj[@"yelp_url"];
        event.locationLatitude = eventObj[@"location_latitude"];
        event.locationLongitude = eventObj[@"location_longitude"];
        
        if (![event.locationLatitude isEqual:[NSNull null]] &&
            ![event.locationLongitude isEqual:[NSNull null]] &&
            [jsonResponse valueForKey:@"lat"] &&
            [jsonResponse valueForKey:@"lng"]) {
            float locLat = [event.locationLatitude floatValue];
            float locLng = [event.locationLongitude floatValue];
            float currentLat = _locationManager.location.coordinate.latitude;
            float currentLng = _locationManager.location.coordinate.longitude;
            if (currentLat < 0.001) {
                currentLat = [[jsonResponse valueForKey:@"lat"] floatValue];
                currentLng = [[jsonResponse valueForKey:@"lng"] floatValue];
            }
            NSLog(@"%f",[MEPLocationService distanceBetweenCoordinatesWithLatitudeOne:locLat longitudeOne:locLng latitudeTwo:currentLat longitudeTwo:currentLng]);
        }
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
    //self.upcomingEvents.dataSource = self;
    //self.upcomingEvents.delegate = self;
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
