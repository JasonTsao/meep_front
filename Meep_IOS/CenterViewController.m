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
#import "Colors.h"
#import "MEPTableCell.h"
#import "jsonParser.h"
#import "ImageCache.h"
#import "CacheObjects.h"
#import <CoreLocation/CoreLocation.h>


#define BORDER_WIDTH 1

#define LINE_WIDTH 1
#define LINE_COLOR "ffffff"

//Color Settings for date header: white text, black background.
#define HEADER_TEXT_COLOR "ffffff"
#define TABLE_BACKGROUND_COLOR "1E824C"



//not working
#define MAIN_TEXT_COLOR "000000"
#define NAV_BAR_COLOR "FFFFFF"
#define ICON_BACKGROUND_COLOR "000000"
#define CONTENT_BACKGROUND_COLOR "FFFFFF"
#define BORDER_COLOR "000000"
#define STATIC_IMAGE_COLOR "000000"

// Color Settings (Green Context Background, White Table Background)
//#define BORDER_COLOR "3FC380"
//#define STATIC_IMAGE_COLOR "3FC380"
//#define TABLE_BACKGROUND_COLOR "FFFFFF"
//#define HEADER_TEXT_COLOR "019875"
//#define CONTENT_BACKGROUND_COLOR "3FC380"
//#define ICON_BACKGROUND_COLOR "FFFFFF"
//#define MAIN_TEXT_COLOR "FFFFFF"
//#define NAV_BAR_COLOR "#2c3e50"

/*
 // Color Settings (White Context Background, Green Table Background)
#define BORDER_COLOR "F5F5F5"
#define STATIC_IMAGE_COLOR "FFFFFF"
#define TABLE_BACKGROUND_COLOR "3FC380"
#define HEADER_TEXT_COLOR "F5F5F5"
#define CONTENT_BACKGROUND_COLOR "FFFFFF"
#define ICON_BACKGROUND_COLOR "3FC380"
#define MAIN_TEXT_COLOR "0F0F0F"
*/
 
@interface CenterViewController () <UITableViewDataSource, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftNavBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightNavBarButton;


@property (weak, nonatomic) IBOutlet UITableView *upcomingEventsTable;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellMain;
@property (weak, nonatomic) IBOutlet UITableView *upcomingEvents;
@property (nonatomic, assign) NSInteger numDates;

@property (nonatomic, strong) NSMutableArray *datesArray;
@property (nonatomic, strong) NSMutableArray *datesEpochTimeArray;

@property (nonatomic, strong) NSMutableDictionary * eventData;
@property (nonatomic, strong) NSMutableDictionary * eventCellData;

@property (nonatomic, strong) NSArray * eventArray;

@property (nonatomic, strong) NSMutableData * data;

@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic, assign) float lat;
@property (nonatomic, assign) float lng;

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

- (void)openNotificationsPage
{
    [_delegate openNotificationsPage];
}

- (IBAction)openLeftPanelPage:(id)sender {
    if(!_showingLeftPanel){
        _showingLeftPanel = YES;
        [_delegate movePanelRight];
    }
    else{
        _showingLeftPanel = NO;
        [_delegate movePanelToOriginalPosition];
    }
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
    NSInteger count = [[_eventCellData objectForKey:key] count];
    return count;
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

-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView * footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, tableView.sectionFooterHeight)];
    UIView * verticalLine = [[UIView alloc] initWithFrame:CGRectMake(30 - BORDER_WIDTH, 0, 1, tableView.sectionFooterHeight)];
    verticalLine.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",BORDER_COLOR]];
    [footerView addSubview:verticalLine];
    footerView.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",TABLE_BACKGROUND_COLOR]];
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return tableView.sectionHeaderHeight;
}


-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *dateString;
    dateString = [_datesArray objectAtIndex:section];
    UIColor * framingColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",BORDER_COLOR]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *startedDate = [dateFormatter dateFromString:dateString];
    
    [dateFormatter setDateFormat:@"MMM dd"];
    NSString * header = [dateFormatter stringFromDate:startedDate];
    
    
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
//    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, tableView.sectionHeaderHeight)];
    
    UIView * horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(28, headerView.frame.size.height/2 + 1 - (BORDER_WIDTH/2), headerView.frame.size.width/5 - 28, BORDER_WIDTH)];
    horizontalLine.backgroundColor = framingColor;
    UIView * verticalLine = [[UIView alloc] initWithFrame:CGRectMake(30 - BORDER_WIDTH, 0, 0, headerView.frame.size.height)];
    verticalLine.backgroundColor = framingColor;
    
    
    UIView * headerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, headerView.frame.size.height)];
    UILabel * headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerContainer.frame.size.width - 15, headerContainer.frame.size.height)];
    headerTitle.textAlignment = NSTextAlignmentRight;
    // headerContainer.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f];
    headerTitle.text = header;
    [headerTitle setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Thin" size:35.0f]];
    
    headerTitle.textColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",HEADER_TEXT_COLOR]];
    
    //[headerTitle setFont:[UIFont systemFontOfSize:30.0f]];
    
    [headerContainer addSubview:headerTitle];
    [headerView addSubview:headerContainer];
    [headerView addSubview:verticalLine];
    // [headerView addSubview:horizontalLine];
    headerView.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",TABLE_BACKGROUND_COLOR]];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


- (UITableViewCell*)clearCell:(UITableViewCell *)cell{
    for(UIView *view in cell.contentView.subviews){
        if ([view isKindOfClass:[UIView class]]) {
            [cell delete:view];
        }
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"upcomingEvent" forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",TABLE_BACKGROUND_COLOR]];
    NSString * key = _datesArray[indexPath.section];
    UIView * eventView = _eventCellData[key][indexPath.row];
    
    
    NSString * dateText = [_datesArray objectAtIndex:indexPath.section];
    Event * event = [[_eventData objectForKey:dateText] objectAtIndex:indexPath.row];
    if (![event.yelpImageLink isEqual:[NSNull null]] && [event.yelpImageLink length] > 1 && YES) {
    
        dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
        dispatch_async(downloadQueue, ^{
            NSString *imgUrl = event.yelpImageLink;
            float imageHeight = 40;
            float imageXCoord = 8;
            float imageYCoord = (cell.frame.size.height/2) - (imageHeight/2);
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(imageXCoord-0.75, imageYCoord-0.75, imageHeight+1.5, imageHeight+1.5)];
            UIImage* image;
    
            if ([[ImageCache sharedImageCache] DoesExist:imgUrl] == true)
            {
                image = [[ImageCache sharedImageCache] GetImage:imgUrl];
            }
            else
            {
                // Create new image data to be cached
                NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: imgUrl]];
                image = [[UIImage alloc] initWithData:imageData];

                // Create a rounded image from the square ones we would get from online
                UIImageView* tmpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageXCoord-0.75, imageYCoord-0.75, imageHeight+1.5, imageHeight+1.5)];
                tmpImageView.image = image;
                tmpImageView.layer.cornerRadius = imageHeight/2;
                tmpImageView.layer.masksToBounds = YES;
                UIImage* roundedImage = [ImageCache screenshotOfView: tmpImageView];
                
                image = roundedImage;
                
                // Add the image to the cache
                [[ImageCache sharedImageCache] AddImage:imgUrl :roundedImage];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                img.image = image;
                //img.layer.cornerRadius = imageHeight/2;
                //img.layer.masksToBounds = YES;
                [cell addSubview:img];
                
            });
        });
        [cell addSubview:eventView];
        
    }
    else{
        [cell addSubview:_eventCellData[key][indexPath.row]];
    }
    //[cell addSubview:_eventCellData[key][indexPath.row]];
    
    return cell;
}

 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable. 3108956853
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
    NSString * dateText = [_datesArray objectAtIndex:indexPath.section];
    Event * currentRecord = [[_eventData objectForKey:dateText] objectAtIndex:indexPath.row];
    
    [_delegate displayEventPage:currentRecord];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [self getUpcomingEvents];
    [refreshControl endRefreshing];
}

/*
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
*/
-(NSInteger)getIndexOfClosestDay
{
    NSInteger indexOfClosestDay = 0;
    NSTimeInterval closest_time_difference = 0;
    
    NSDate* date = [NSDate date];
    NSTimeInterval current_epoch_time_date = [date timeIntervalSince1970];

    for (NSInteger i=0; i < [_datesEpochTimeArray count]; i++){
        if (closest_time_difference == 0){
            closest_time_difference = current_epoch_time_date - [_datesEpochTimeArray[i] doubleValue];
            
            if(closest_time_difference < 0){
                closest_time_difference = -closest_time_difference;
            }
            indexOfClosestDay = i;
            continue;
        }
        
        NSTimeInterval time_difference = current_epoch_time_date - [_datesEpochTimeArray[i] doubleValue];
        if(time_difference < 0){
            time_difference = -time_difference;
        }
        
        if(time_difference < closest_time_difference){
            closest_time_difference = time_difference;
            indexOfClosestDay = i;
        }

    }
    return indexOfClosestDay;
}

-(void)scrollToClosestToCurrentDay
{
    if([_datesArray count] > 0){
        NSInteger currentDaySectionIndex = [self getIndexOfClosestDay];
        NSInteger currentDayRowIndex = 0;
        NSIndexPath *currentDayIndexPath = [NSIndexPath indexPathForRow:currentDayRowIndex inSection:currentDaySectionIndex];
        [_upcomingEvents scrollToRowAtIndexPath:currentDayIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _showingLeftPanel = NO;
    
    // Get Location Data
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [_locationManager startUpdatingLocation];
    
    // Set Button Icons
    
    //[_leftNavBarButton setImage:[UIImage imageNamed:NSImageNameListViewTemplate]];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    // self.view.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",NAV_BAR_COLOR]];'
    self.view.backgroundColor = [UIColor blackColor];
    // self.navigationController.navigationBar.translucent = NO;
    // self.navigationController.navigationBar.opaque = NO;
    // [[UINavigationBar appearance] setBarTintColor:[CenterViewController colorWithHexString:[NSString stringWithFormat:@"%s",NAV_BAR_COLOR]]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor clearColor]];
    // self.navigationController.view.backgroundColor = [UIColor clearColor];
    [self.upcomingEvents addSubview:refreshControl];
    //self.eventArray = [[NSMutableArray alloc] init];
    self.eventArray = [[NSMutableArray alloc] init];
    self.numDates = 0;
    // self.upcomingEventsTable.backgroundColor = [self colorWithHexString:[NSString stringWithFormat:@"%s",TABLE_BACKGROUND_COLOR]];
    
    [self setTitleView];

    [self getUpcomingEvents];
}

- (void) setTitleView {
    UIImage * pressedButton = [UIImage imageNamed:@"UIBarButtonAdd_2x.png"];
    UIButton * customButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [customButton setImage:pressedButton forState:UIControlStateNormal];
    customButton.frame = CGRectMake(0, 0, pressedButton.size.width, pressedButton.size.height);
    UIView * container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pressedButton.size.width, pressedButton.size.height)];
    container.backgroundColor = [UIColor clearColor];
    [container addSubview:customButton];
    UIBarButtonItem * customToolbarButton = [[UIBarButtonItem alloc] initWithCustomView:container];
}

- (void) getUpcomingEvents {

    _datesArray = [[NSMutableArray alloc] init];
    _datesEpochTimeArray = [[NSMutableArray alloc] init];
    
    NSArray *upcomingEvents = [CacheObjects getCachedList:@"upcoming_events"];
    if(upcomingEvents){
        [self putEventsOnTable:upcomingEvents];
    }
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
    //[self getUpcomingEvents];
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

-(void)putEventsOnTable:(NSArray*)upcomingEvents
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    _eventData = [[NSMutableDictionary alloc] init];
    
    // _lat = _locationManager.location.coordinate.latitude;
    // _lng = _locationManager.location.coordinate.longitude;
    _lat = 0;
    _lng = 0;
    
    if(!_eventCellData){
    _eventCellData = [[NSMutableDictionary alloc] init];
    }
    
    for (Event * event in upcomingEvents) {
        NSTimeInterval interval = [event.start_time doubleValue];
        NSDate * eventDate = [[NSDate alloc] initWithTimeIntervalSince1970:interval];
        NSString * dateString = [dateFormatter stringFromDate:eventDate];
        [_datesEpochTimeArray addObject:[NSString stringWithFormat:@"%f",interval]];
        if ([_eventData objectForKey:dateString]) {
            NSMutableArray * unsortedEventData = [_eventData objectForKey:dateString];
            [unsortedEventData addObject:event];
            [_eventData setObject:unsortedEventData forKey:dateString];
        }
        else {
            NSMutableArray * unsortedEventData = [[NSMutableArray alloc] initWithObjects:event, nil];
            [_eventData setObject:unsortedEventData forKey:dateString];
        }
        
        [CacheObjects cacheEvent:event];
    }
    //NSSortDescriptor * nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start_time" ascending:YES];
    NSSortDescriptor * nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start_time" ascending:YES];
    for (NSString * key in [_eventData allKeys]) {
        _eventData[key] = [_eventData[key] sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameSortDescriptor]];
    }

    NSMutableArray * orderedTableCells;
    for (NSString * key in [_eventData allKeys]) {
        orderedTableCells = [[NSMutableArray alloc] init];
        for (Event * event in [_eventData objectForKey:key]) {
            BOOL hasNotification = NO;
            
            //Checking if this event has notifications and setting a flag so the view can be adjugsted accordingly
            if([_eventNotifications objectForKey:[NSString stringWithFormat:@"%i", event.event_id ]]){
                NSLog(@"there is a notification for : %i", event.event_id);
                hasNotification = YES;
            }
            
            UIView * eventCover = [MEPTableCell eventCell:event userLatitude:_lat userLongitude:_lng hasNotification:hasNotification];
            [orderedTableCells addObject:eventCover];        }
        [_eventCellData setObject:orderedTableCells forKey:key];
    }
    
    [_datesArray addObjectsFromArray:[[_eventData allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    [_upcomingEvents reloadData];
    
    [self scrollToClosestToCurrentDay];
}

-(void)handleData{
    NSLog(@"got some upcoming events!");
    NSError* error;
    _datesArray = [[NSMutableArray alloc] init];
    _datesEpochTimeArray = [[NSMutableArray alloc] init];
    NSDictionary * jsonResponse = [NSJSONSerialization JSONObjectWithData:_data options:0 error:&error];
    NSArray * upcoming = jsonResponse[@"upcoming_events"];
    NSArray *upcomingEvents = [jsonParser eventsArray:upcoming];
    [CacheObjects cacheUpcomingEvents:upcomingEvents];
    [self putEventsOnTable:upcomingEvents];
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
