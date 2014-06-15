//
//  GroupEventsTableViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/12/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "GroupEventsTableViewController.h"
#import "GroupsViewController.h"
#import "EventPageViewController.h"
#import "Event.h"
#import "MEEPhttp.h"
#import "jsonParser.h"
#import "MEPTableCell.h"
#import "Colors.h"
#import "ImageCache.h"

#import <CoreLocation/CoreLocation.h>

#define BORDER_WIDTH 1

#define LINE_WIDTH 1
#define LINE_COLOR "ffffff"

//Color Settings for date header: white text, black background.
#define HEADER_TEXT_COLOR "ffffff"
#define TABLE_BACKGROUND_COLOR "000000"
//not working
#define MAIN_TEXT_COLOR "000000"
#define NAV_BAR_COLOR "FFFFFF"
#define ICON_BACKGROUND_COLOR "000000"
#define CONTENT_BACKGROUND_COLOR "FFFFFF"
#define BORDER_COLOR "000000"
#define STATIC_IMAGE_COLOR "000000"

@interface GroupEventsTableViewController ()

@property(nonatomic) NSInteger numDates;
@property(nonatomic, strong) NSMutableArray *datesArray;
@property(nonatomic, strong) NSMutableArray *datesSectionCountArray;
@property(nonatomic, strong) NSMutableDictionary *datesSectionCountDictionary;
@property(nonatomic, strong) NSMutableDictionary *dateEventsDictionary;

@property (nonatomic, strong) NSMutableDictionary * eventData;
@property (nonatomic, strong) NSMutableDictionary * eventCellData;

@property (nonatomic, assign) float lat;
@property (nonatomic, assign) float lng;

@property (nonatomic, strong) CLLocationManager * locationManager;

@property (nonatomic, strong) EventPageViewController *eventPageViewController;


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

    NSString * requestURL = [NSString stringWithFormat:@"%@group/%i/upcoming",[MEEPhttp eventURL], _group.group_id];
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
    
    NSArray * upcoming = jsonResponse[@"upcoming_events"];
    NSInteger numRowsInSection = 0;
    NSMutableArray *unsortedEventArray = [jsonParser eventsArray:upcoming];
    _datesArray = [[NSMutableArray alloc] init];
    _eventData = [[NSMutableDictionary alloc] init];
    
    if(!_eventCellData){
        _eventCellData = [[NSMutableDictionary alloc] init];
    }
    
    for( Event *event in unsortedEventArray){
        //event.group = eventObj[@"group"];
        NSLog(@"event: %@", event);
        //getting number of differnt days
        if (![event.locationLatitude isEqual:[NSNull null]] &&
            ![event.locationLongitude isEqual:[NSNull null]]) {
            _lat = _locationManager.location.coordinate.latitude;
            _lng = _locationManager.location.coordinate.longitude;
            if (_lat < 0.001) {
                _lat = [[jsonResponse valueForKey:@"lat"] floatValue];
                _lng = [[jsonResponse valueForKey:@"lng"] floatValue];
            }
        }
        
        NSTimeInterval startedTime = [event.start_time doubleValue];
        NSDate *startedDate = [[NSDate alloc] initWithTimeIntervalSince1970:startedTime];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString * eventDate = [dateFormatter stringFromDate:startedDate];

        // New Code!
        if ([_eventData objectForKey:eventDate]) {
            NSMutableArray * unsortedEventData = [_eventData objectForKey:eventDate];
            [unsortedEventData addObject:event];
            [_eventData setObject:unsortedEventData forKey:eventDate];
        }
        else {
            NSMutableArray * unsortedEventData = [[NSMutableArray alloc] initWithObjects:event, nil];
            [_eventData setObject:unsortedEventData forKey:eventDate];
        }
    }
    
    NSSortDescriptor * nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"start_time" ascending:YES];
    for (NSString * key in [_eventData allKeys]) {
        _eventData[key] = [_eventData[key] sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameSortDescriptor]];
    }
    NSMutableArray * orderedTableCells;
    for (NSString * key in [_eventData allKeys]) {
        orderedTableCells = [[NSMutableArray alloc] init];
        for (Event * event in [_eventData objectForKey:key]) {
            BOOL hasNotification = NO;
            
            UIView * eventCover = [MEPTableCell eventCell:event userLatitude:_lat userLongitude:_lng hasNotification:hasNotification];
            [orderedTableCells addObject:eventCover];
        }
        [_eventCellData setObject:orderedTableCells forKey:key];
    }
    
    [_datesArray addObjectsFromArray:[[_eventData allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    
    _eventArray = [unsortedEventArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameSortDescriptor]];
    
    [self.tableView reloadData];
    
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [self getUpcomingGroupEvents];
    [refreshControl endRefreshing];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    NSMutableString *titleString = [[NSMutableString alloc] init];
    [titleString appendString: _group.name];
    [titleString appendString: @" Events"];

    // Initializing variables
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

- (void) backToCenterFromEventPage:(EventPageViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"number of sections in table: %i", [_datesArray count]);
    return [_datesArray count];
    //return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [_datesArray objectAtIndex:section];
    NSInteger count = [[_eventCellData objectForKey:key] count];
    return count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString * header;
    if( [_datesArray count] > 0){
        NSString *dateString;
        dateString = [_datesArray objectAtIndex:section];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *startedDate = [dateFormatter dateFromString:dateString];
        
        [dateFormatter setDateFormat:@"MMM dd"];
        header = [dateFormatter stringFromDate:startedDate];
    }
    else{
        header = @"";
    }
    
    return header;
}

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
    
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, tableView.sectionHeaderHeight)];
    
    UIView * horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(28, headerView.frame.size.height/2 + 1 - (BORDER_WIDTH/2), headerView.frame.size.width/5 - 28, BORDER_WIDTH)];
    horizontalLine.backgroundColor = framingColor;
    UIView * verticalLine = [[UIView alloc] initWithFrame:CGRectMake(30 - BORDER_WIDTH, 0, BORDER_WIDTH, headerView.frame.size.height)];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * dateText = [_datesArray objectAtIndex:indexPath.section];
    Event * currentRecord = [[_eventData objectForKey:dateText] objectAtIndex:indexPath.row];
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    self.eventPageViewController = (EventPageViewController *)[storyboard instantiateViewControllerWithIdentifier:@"EventViewController"];
    _eventPageViewController.currentEvent = currentRecord;
    [self.eventPageViewController setDelegate:self];
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_eventPageViewController];
    [self presentViewController:navigation animated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupEvent" forIndexPath:indexPath];
    NSString *dateString = _datesArray[indexPath.section];
    
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
                [cell addSubview:img];
                
            });
        });
        [cell addSubview:eventView];
        
    }
    else{
        [cell addSubview:_eventCellData[key][indexPath.row]];
    }

    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
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
    GroupTableViewController * groupPage = [segue destinationViewController];
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    [groupPage setDelegate:self];
    groupPage.group = _group;
}


@end
