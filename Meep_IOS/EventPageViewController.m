//
//  EventPageViewController.m
//  MeepIOS
//
//  Created by Ryan Sharp on 4/15/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "Event.h"
#import "EventPageViewController.h"
#import "EditEventViewController.h"
#import "FriendProfileViewController.h"
#import "AddRemoveFriendsFromEventTableViewController.h"
#import "EventAttendeeTabBarController.h"
#import "EventAttendeesDistanceViewController.h"
#import "EventAttendeesViewController.h"
#import "EventChatViewController.h"
#import "Colors.h"
#import "jsonParser.h"
#import <CoreLocation/CoreLocation.h>

#define CONTENT_BG_COLOR "3FC380"
#define CONTENT_TEXT_COLOR "FFFFFF"

#define CONTENT_SPACING 4

@interface EventPageViewController ()

@property (weak, nonatomic) IBOutlet UITableView *eventInfoTable;
@property (weak, nonatomic) IBOutlet UICollectionView *friendsCollection;
@property (weak, nonatomic) IBOutlet UINavigationItem *eventNavBar;

@property (nonatomic, strong) EditEventViewController *editEventViewController;
@property (nonatomic, assign) BOOL showingEditPage;

@property (nonatomic, strong) FriendProfileViewController *friendProfileViewController;
@property (nonatomic, assign) BOOL showingFriendPage;

@property (nonatomic, strong) AddRemoveFriendsFromEventTableViewController *addRemoveFriendsFromEventTableViewController;

@property (nonatomic, strong) EventAttendeeTabBarController *eventAttendeeTabBarController;
@property (nonatomic, strong) EventAttendeesViewController *eventAttendeesViewController;

@property(nonatomic, strong) NSMutableArray *basicInfoToDisplay;
@property(nonatomic, strong) NSMutableArray *locationInfoToDisplay;
@property(nonatomic, strong) NSMutableArray *thirdPartyInfoToDisplay;
@property (nonatomic, strong)MKMapView * mapView;

@property (nonatomic, assign) int YELP_SLOT;

@property (nonatomic, strong) CLLocationManager * locationManager;

@end

@implementation EventPageViewController
- (IBAction)closeModal:(id)sender {
    [_delegate closeEventModal];
}

- (IBAction)backToCenterFromEventPage:(id)sender {
    [self.delegate backToCenterFromEventPage:self];
}

- (void) leaveEvent
{
    // remove user from event
}

- (void) openEventAttendeesPage
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    _eventAttendeeTabBarController = (EventAttendeeTabBarController *)[storyboard instantiateViewControllerWithIdentifier:@"eventAttendeeTabController"];

    [_eventAttendeeTabBarController.viewControllers[0] setInvitedFriends:_invitedFriends];
    [_eventAttendeeTabBarController.viewControllers[0] setCurrentEvent:_currentEvent];
    [_eventAttendeeTabBarController.viewControllers[1] setInvitedFriends:_invitedFriends];
    [_eventAttendeeTabBarController.viewControllers[1] setCurrentEvent:_currentEvent];
    
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_eventAttendeeTabBarController];
    [_eventAttendeeTabBarController setDelegate:self];
    _eventAttendeeTabBarController.invitedFriends = _invitedFriends;
    _eventAttendeeTabBarController.currentEvent = _currentEvent;
    
    [self presentViewController:navigation animated:YES completion:nil];
}

- (void) openEditEventPage
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    _editEventViewController = (EditEventViewController *)[storyboard instantiateViewControllerWithIdentifier:@"editEvent"];
    
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_editEventViewController];
    [_editEventViewController setDelegate:self];
    _editEventViewController.currentEvent = _currentEvent;
    [self presentViewController:navigation animated:YES completion:nil];
}

- (void) openChatPage
{
    [self performSegueWithIdentifier:@"toEventChat" sender:self];
}

- (void) openAddRemoveFriendsPage
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    _addRemoveFriendsFromEventTableViewController = (AddRemoveFriendsFromEventTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"addRemoveFriendsFromEvent"];
    
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_addRemoveFriendsFromEventTableViewController];
    [_addRemoveFriendsFromEventTableViewController setDelegate:self];
    //_addRemoveFriendsFromEventTableViewController.invitedFriends = _invitedFriends;
    _addRemoveFriendsFromEventTableViewController.originalInvitedFriends = _invitedFriends;
    _addRemoveFriendsFromEventTableViewController.currentEvent = _currentEvent;
    [self presentViewController:navigation animated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"clicked button at index: %i", buttonIndex);
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [self openChatPage];
                    break;
                case 1:
                    NSLog(@"Removing user from group");
                    //[self logoutSelect];
                    break;
                case 2:
                    NSLog(@"going to edit view page");
                    [self openEditEventPage];
                    break;
                case 3:
                    NSLog(@"going to invite more friends page");
                    [self openAddRemoveFriendsPage];
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (IBAction)openEventOptions:(id)sender {
    
    //if user is host
    UIActionSheet *eventOptionsPopup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Chat",@"Leave Event", @"Edit Event", @"Add/Remove Friends",nil];
    //else
    //UIActionSheet *eventOptionsPopup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Leave Event",nil];
    eventOptionsPopup.tag = 1;
    [eventOptionsPopup showInView:self.view];
}

- (IBAction)openMapsLink:(id)sender {
    NSString* url = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%@",_locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude, [_currentEvent.locationAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil event:(Event*) event
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) getInvitedFriends
{
    NSString * requestURL = [NSString stringWithFormat:@"%@invited_friends/%i",[MEEPhttp eventURL], _currentEvent.event_id];
    //NSString * event_id = [NSString stringWithFormat:@"%i", _currentEvent.event_id ];
    NSDictionary *postDict = [[NSDictionary alloc] init];
    //NSDictionary *postDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"user", event_id, @"event", nil];
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
    NSArray * friends = jsonResponse[@"invited_friends"];
    _invitedFriends = [jsonParser invitedFriendsArray:friends];
    [self.friendsCollection reloadData];
    /*NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_invitedFriends];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"invited_friends_list"];
    [NSUserDefaults resetStandardUserDefaults];*/
    //[self.];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_invitedFriends count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (void)backToEventPage:(EditEventViewController*)controller
{
    [self getInvitedFriends];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) openFriendPage:(id)sender
{
    
    /*UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    _friendProfileViewController = (FriendProfileViewController *)[storyboard instantiateViewControllerWithIdentifier:@"friendProfile"];
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_friendProfileViewController];
    [_friendProfileViewController setDelegate:self];
     _friendProfileViewController.currentFriend =
    [self presentViewController:navigation animated:YES completion:nil];*/
    NSLog(@"just clicked open friend page butotn");
    NSLog(@"sender : %@", sender);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    UICollectionViewCell *cell = [_friendsCollection dequeueReusableCellWithReuseIdentifier:@"invitedFriendCell" forIndexPath:indexPath];
    //UIImage *cellImage = [[UIImage alloc] init];
    UIButton *cellButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    NSString *user_name;

    if([[_invitedFriends[indexPath.row] name] length] >= 6){
        user_name = [[_invitedFriends[indexPath.row] name] substringToIndex:6];
    }
    else{
        user_name = [_invitedFriends[indexPath.row] name];
    }

    [cellButton addTarget:self
               action:@selector(openFriendPage:)
     forControlEvents:UIControlEventTouchUpInside];
    [cellButton setTitle:user_name forState:UIControlStateNormal];
    cellButton.frame = CGRectMake(0.0, 0.0, 50.0, 50.0);
    [cell.contentView addSubview: cellButton];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *friend_name;
    Friend *selectedFriend;
    if(indexPath.section == 1){
        if(indexPath.row == 1){
            NSLog(@"Transfer to users map app!");
            NSString* url = [NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%@",_locationManager.location.coordinate.latitude, _locationManager.location.coordinate.longitude, [_currentEvent.locationAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            NSLog(@"Opening Yelp Link");
            if ([self isYelpInstalled]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_currentEvent.yelpLink]];
            }
            else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_currentEvent.yelpLink]];
            }
        }
    }
    if(indexPath.section == 3){
        if(indexPath.row == 0){
            [self openEventAttendeesPage];
        }
    }
}

- (BOOL) isYelpInstalled {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"yelp:"]];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/*-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *header;
    return header;
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    NSString *eventInfoType;
    /*
    height = 25.0;
    if (indexPath.section == 0){
        eventInfoType = _basicInfoToDisplay[indexPath.row];
        if([eventInfoType isEqualToString:@"name"]){
            height = 40.0;
        }
        else if([eventInfoType isEqualToString:@"time"]){
            if(![_currentEvent.end_time isEqual:[NSNull null]]){
                height = 55;
            }
            else{
                height = 25.0;
            }
        }
        
    }
    
    else if(indexPath.section == 1){
        eventInfoType = _locationInfoToDisplay[indexPath.row];
        if([eventInfoType isEqualToString:@"locationAddress"]){
            height = 180.0;
        }
        else if ([eventInfoType isEqualToString:@"locationName"]){
            height = 30.0;
        }
    }
    else if(indexPath.section == 2){
        height = 25.0;
    }
    
    else if(indexPath.section == 3){
        height = 30.0;
    }
     */
    if (indexPath.row == 0) {
        NSString * title = ([_currentEvent.name isEqual:[NSNull null]] ? _currentEvent.name : _currentEvent.description);
        CGSize expectedSize = [title sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:self.eventInfoTable.frame.size lineBreakMode:NSLineBreakByWordWrapping];
        // height = 40.0;
        height = expectedSize.height * 2;
    }
    else if (indexPath.row == 1) {
        height = 180.0;
    }
    else if (indexPath.row == 2) {
        height = 50.0;
    }
    return height;
}

- (UITableViewCell *) titleCellView:(UITableViewCell*)cell {
    NSString * title = ([_currentEvent.name isEqual:[NSNull null]] ? _currentEvent.name : _currentEvent.description);
    CGSize expectedSize = [title sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGRectMake(0, 0, cell.frame.size.width - (CONTENT_SPACING * 2), cell.frame.size.height - (CONTENT_SPACING * 2)).size lineBreakMode:NSLineBreakByWordWrapping];
    cell.frame = CGRectMake(0, 0, cell.frame.size.width, expectedSize.height * 2);
    UIView * titleView = [[UIView alloc] initWithFrame:CGRectMake(CONTENT_SPACING, CONTENT_SPACING, cell.frame.size.width - (CONTENT_SPACING * 2), cell.frame.size.height - (CONTENT_SPACING * 2))];
    titleView.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",CONTENT_BG_COLOR]];
    UILabel* titleText = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_SPACING, CONTENT_SPACING, cell.frame.size.width - (CONTENT_SPACING * 2), cell.frame.size.height - (CONTENT_SPACING * 2))];
    if ([_currentEvent.name length] > 1) {
        titleText.text = _currentEvent.name;
    }
    else {
        titleText.text = _currentEvent.description;
    }
    titleText.textColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",CONTENT_TEXT_COLOR]];
    titleText.textAlignment = NSTextAlignmentLeft;
    titleText.lineBreakMode = NSLineBreakByWordWrapping;
    titleView.layer.cornerRadius = 5;
    [titleText setFont:[UIFont systemFontOfSize:14]];
    [titleView addSubview:titleText];
    [cell addSubview:titleView];
    return cell;
}

- (UITableViewCell *) mainContentView:(UITableViewCell*)cell {
    NSLog(@"%f",cell.frame.size.height);
    UIView * textContent = [[UIView alloc] initWithFrame:CGRectMake(CONTENT_SPACING, CONTENT_SPACING, cell.frame.size.width - (CONTENT_SPACING * 2), cell.frame.size.height - (CONTENT_SPACING * 2))];
    textContent.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",CONTENT_BG_COLOR]];
    textContent.layer.cornerRadius = 5;
    if (!(_currentEvent.locationAddress == (id)[NSNull null] || _currentEvent.locationAddress.length == 0)) {
        UIView * mapViewFrame = [[UIView alloc] initWithFrame:CGRectMake(cell.frame.size.width/2 + CONTENT_SPACING, CONTENT_SPACING, (cell.frame.size.width/2) - (CONTENT_SPACING * 2), cell.frame.size.height - (CONTENT_SPACING * 2))];
        mapViewFrame.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",CONTENT_BG_COLOR]];
        mapViewFrame.layer.cornerRadius = 5;
        UIView * mapFrame = [[UIView alloc] initWithFrame:CGRectMake(2, 2, mapViewFrame.frame.size.width - 4, mapViewFrame.frame.size.height - 4)];
        _mapView.frame = CGRectMake(CONTENT_SPACING, CONTENT_SPACING, mapViewFrame.frame.size.width - (CONTENT_SPACING * 2), mapViewFrame.frame.size.height - (CONTENT_SPACING * 2));
        _mapView.layer.cornerRadius = 5;
        [mapViewFrame addSubview:_mapView];
        [cell addSubview:mapViewFrame];
        
        textContent.frame = CGRectMake(CONTENT_SPACING, CONTENT_SPACING, (cell.frame.size.width/2) - (CONTENT_SPACING * 2), cell.frame.size.height - (CONTENT_SPACING * 2));
    }
    float yCoord = 2;
    if (![_currentEvent.name isEqual:[NSNull null]] && [_currentEvent.name length] > 1) {
        CGSize descSize = [_currentEvent.description sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:textContent.frame.size lineBreakMode:NSLineBreakByWordWrapping];
        UILabel * desc = [[UILabel alloc] initWithFrame:CGRectMake(2, yCoord, descSize.width-4, descSize.height)];
        desc.text = _currentEvent.description;
        desc.textColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",CONTENT_TEXT_COLOR]];
        [desc setFont:[UIFont systemFontOfSize:9]];
        yCoord = 6 + descSize.height;
        [textContent addSubview:desc];
    }
    if (![_currentEvent.locationAddress isEqual:[NSNull null]]) {
        UILabel * addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, yCoord, textContent.frame.size.width - 4, 15)];
        addressLabel.text = @"Location";
        addressLabel.textColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",CONTENT_TEXT_COLOR]];
        [addressLabel setFont:[UIFont systemFontOfSize:9.5]];
        [textContent addSubview:addressLabel];
        yCoord = yCoord + 1 + addressLabel.frame.size.height;
        UILabel * address = [[UILabel alloc] initWithFrame:CGRectMake(2, yCoord, textContent.frame.size.width-4, 15)];
        address.text = _currentEvent.locationAddress;
        address.textColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",CONTENT_TEXT_COLOR]];
        [address setFont:[UIFont systemFontOfSize:9]];
        yCoord = yCoord + 6 + address.frame.size.height;
        [textContent addSubview:address];
    }
    if (![_currentEvent.start_time isEqual:[NSNull null]]) {
        NSMutableString *timeString = [[NSMutableString alloc] init];
        NSTimeInterval startedTime = [_currentEvent.start_time doubleValue];
        NSDate *startedDate = [[NSDate alloc] initWithTimeIntervalSince1970:startedTime];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM dd h:mm a"];
        NSString * startTime = [dateFormatter stringFromDate:startedDate];
        UILabel * startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, yCoord, textContent.frame.size.width-4, 15)];
        startTimeLabel.text = startTime;
        startTimeLabel.textColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",CONTENT_TEXT_COLOR]];
        [startTimeLabel setFont:[UIFont systemFontOfSize:9]];
        [textContent addSubview:startTimeLabel];
    }
    [cell addSubview:textContent];
    return cell;
}

- (UITableViewCell *) externalLinksCellView:(UITableViewCell*)cell {
    cell.frame = CGRectMake(0, 0, cell.frame.size.width, 60);
    UIView * linksContainer = [[UIView alloc] initWithFrame:CGRectMake(CONTENT_SPACING, CONTENT_SPACING, cell.frame.size.width - (CONTENT_SPACING * 2), cell.frame.size.height - (CONTENT_SPACING * 2))];
    linksContainer.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",CONTENT_BG_COLOR]];
    if (![_currentEvent.locationAddress isEqual:[NSNull null]]) {
        UIButton * mapsIconHolder = [[UIButton alloc] initWithFrame:CGRectMake(2, 2, linksContainer.frame.size.height - 8, linksContainer.frame.size.height - 8)];
        [mapsIconHolder addTarget:self action:@selector(openMapsLink:) forControlEvents:UIControlEventTouchUpInside];
        UIImageView * mapsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 0, linksContainer.frame.size.height - 14, linksContainer.frame.size.height - 14)];
        UIImage * iconImage = [UIImage imageNamed:@"map19.png"];
        CGRect rect = CGRectMake(0, 0, iconImage.size.width, iconImage.size.height);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextClipToMask(context, rect, iconImage.CGImage);
        CGContextSetFillColorWithColor(context, [[Colors colorWithHexString:[NSString stringWithFormat:@"%s",CONTENT_TEXT_COLOR]] CGColor]);
        CGContextFillRect(context, rect);
        UIImage *image2 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        iconImage = [UIImage imageWithCGImage:image2.CGImage scale:1.0 orientation: UIImageOrientationDownMirrored];
        mapsImageView.image = iconImage;
        [mapsIconHolder addSubview:mapsImageView];
        
        UILabel * mapIconLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, mapsIconHolder.frame.size.height - 6, mapsIconHolder.frame.size.width, 10)];
        mapIconLabel.text = @"Maps";
        mapIconLabel.textColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",CONTENT_TEXT_COLOR]];
        [mapIconLabel setFont:[UIFont systemFontOfSize:9]];
        mapIconLabel.textAlignment = NSTextAlignmentCenter;
        [mapsIconHolder addSubview:mapIconLabel];
        
        [linksContainer addSubview:mapsIconHolder];
    }
    linksContainer.layer.cornerRadius = 5;
    [cell addSubview:linksContainer];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventInfoCell"];
    if (indexPath.row == 0) {
        cell = [self titleCellView:cell];
    }
    else if (indexPath.row == 1) {
        cell = [self mainContentView:cell];
    }
    else if (indexPath.row == 2) {
        cell = [self externalLinksCellView:cell];
    }
    
    
    /*
    NSString *eventInfoType;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0){
        eventInfoType = _basicInfoToDisplay[indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        
        if([eventInfoType isEqualToString:@"name"]){
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.textLabel.text = _currentEvent.name;
            
        }
        else if([eventInfoType isEqualToString:@"description"]){
            cell.textLabel.text = _currentEvent.description;
        }
        else if([eventInfoType isEqualToString:@"time"]){

            NSMutableString *timeString = [[NSMutableString alloc] init];
            
            NSTimeInterval startedTime = [_currentEvent.start_time doubleValue];
            NSDate *startedDate = [[NSDate alloc] initWithTimeIntervalSince1970:startedTime];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MMM dd h:mm a"];
            NSString * startTime = [dateFormatter stringFromDate:startedDate];
            
            [timeString appendString: startTime];
            
            if(![_currentEvent.end_time isEqual:[NSNull null]]){
                NSTimeInterval endedTime = [_currentEvent.end_time doubleValue];
                NSDate *endedDate = [[NSDate alloc] initWithTimeIntervalSince1970:endedTime];
                NSString * endTime = [dateFormatter stringFromDate:endedDate];
                [timeString appendString: @"\n"];
                [timeString appendString: endTime];
                cell.textLabel.numberOfLines = 2;
                cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
            }
            cell.textLabel.text = timeString;
            
        }
    }
    
    if(indexPath.section == 1){
        eventInfoType = _locationInfoToDisplay[indexPath.row];
        if([eventInfoType isEqualToString:@"locationAddress"]){
            //DISPLAY MAP IF THIS IS TRUE
            //cell.textLabel.text = _currentEvent.locationAddress;
            CGRect mapFrame = CGRectMake(cell.frame.size.width/2, 0, cell.frame.size.width/2, _mapView.frame.size.height);
            _mapView.frame = mapFrame;
             [cell.contentView addSubview:_mapView];
        }
        else if([eventInfoType isEqualToString:@"locationName"]){
            cell.textLabel.text = _currentEvent.locationName;
        }
    }
    
    if(indexPath.section == 2){
        eventInfoType = _thirdPartyInfoToDisplay[indexPath.row];
        if([eventInfoType isEqualToString:@"yelp"]){
            cell.textLabel.text = @"yelp";
            
        }
        else if([eventInfoType isEqualToString:@"uber"]){
            cell.textLabel.text = @"uber";
        }
    }
    
    if(indexPath.section == 3){
        cell.textLabel.text = @"Attendees";
    }
     */
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //initializing fields
    self.eventInfoTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _basicInfoToDisplay = [[NSMutableArray alloc]init];
    _locationInfoToDisplay = [[NSMutableArray alloc]init];
    _thirdPartyInfoToDisplay = [[NSMutableArray alloc]init];
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 180.0)];
    
    //ADD CODE FOR CHECKING IF CURRENT USER HAS VIeWED THIS PAGE, IF NOT AND THIS IS FIRST TIME VIEWING, SAVE has_viewed AS TRUE
    
    
    //getting location data
    if (!(_currentEvent.locationAddress == (id)[NSNull null] || _currentEvent.locationAddress.length == 0)) {
        CLGeocoder * geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:_currentEvent.locationAddress completionHandler:^(NSArray * placemarks, NSError* error) {
            if (placemarks && placemarks.count > 0) {
                CLPlacemark * topResult = [placemarks objectAtIndex:0];
                MKPlacemark * placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                MKCoordinateRegion region = self.mapView.region;
                region.center = placemark.region.center;
                region.span.longitudeDelta /= 1000.0;
                region.span.latitudeDelta /= 1000.0;
                [self.mapView setRegion:region animated:YES];
                [self.mapView addAnnotation:placemark];
            }
        }];
    }
    if ([_currentEvent.description length] > 15){
        self.title = [_currentEvent.description substringToIndex:15];
    }
    else{
        self.title = _currentEvent.description;
    }
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    [self getInvitedFriends];
    self.eventInfoTable.dataSource = self;
    self.eventInfoTable.delegate = self;
    //self.friendsCollection.dataSource = self;
    //self.friendsCollection.delegate = self;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.friendsCollection setCollectionViewLayout:flowLayout];
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backToCenterFromEventPage:)];
    
    UIBarButtonItem *optionsBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Options" style:UIBarButtonItemStyleBordered target:self action:@selector(openEventOptions:)];
    
    self.navigationItem.leftBarButtonItem = customBarItem;
    self.navigationItem.rightBarButtonItem = optionsBarItem;
    //[self.friendsCollection registerNib:[UINib nibWithNibName:@"EventPage" bundle:nil] forCellWithReuseIdentifier:@"5"];
    // Do any additional setup after loading the view.
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [_locationManager startUpdatingLocation];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    EventChatViewController * chatView = [segue destinationViewController];
    chatView.invitedFriends = _invitedFriends;
    chatView.currentEvent = _currentEvent;
}



@end
