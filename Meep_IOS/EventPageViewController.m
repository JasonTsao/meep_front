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
#import <CoreLocation/CoreLocation.h>


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
    _invitedFriends = [[NSMutableArray alloc]init];
    for( int i = 0; i< [friends count]; i++){
        InvitedFriend *new_friend = [[InvitedFriend alloc]init];
        
        NSDictionary * new_friend_dict = [NSJSONSerialization JSONObjectWithData: [friends[i] dataUsingEncoding:NSUTF8StringEncoding]
                                                                         options: NSJSONReadingMutableContainers
                                                                           error: &error];
        new_friend.name = new_friend_dict[@"name"];
        new_friend.account_id = [new_friend_dict[@"friend_id"] intValue];
        
        if ([new_friend_dict[@"pf_pic"] length] == 0 || [new_friend_dict objectForKey:@"pf_pf"] == nil){
            UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 40, 40)];
            img.image = [UIImage imageNamed:@"ManSilhouette"];
            //new_friend.profilePic = img;
            new_friend.profilePic = img.image;
        }
        else{
                NSURL *url = [[NSURL alloc] initWithString:new_friend_dict[@"fb_pfpic_url"]];
                //NSURL *url = [[NSURL alloc] initWithString:@"https://graph.facebook.com/jason.s.tsao/picture"];
                NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
                //NSData *urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:nil];
                NSData *urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                new_friend.profilePic = image;
            
        }

        
        
        [_invitedFriends addObject:new_friend];
    }
    
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
    return 4;
}

/*-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *header;
    return header;
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 0;
    
    if(section == 0){
        if( [_currentEvent.name length] != 0){
            [_basicInfoToDisplay addObject:@"name"];
            numRows++;
        }
        if( [_currentEvent.description length] != 0){
            [_basicInfoToDisplay addObject:@"description"];
            numRows++;
            
        }
        //if( [_currentEvent.start_time length] != 0){
        if (![_currentEvent.start_time isEqual:[NSNull null]]){
            [_basicInfoToDisplay addObject:@"time"];
            numRows++;
        }
    }
    
    if(section == 1){
        //if([_currentEvent.locationAddress length] != 0){
        if(![_currentEvent.locationAddress isEqual:[NSNull null]]){
            
            if([_currentEvent.locationAddress length] != 0){
                NSLog(@"location address is : %@", _currentEvent.locationAddress);
                //MAKE MAP VIEW
                [_locationInfoToDisplay addObject:@"locationAddress"];
                numRows++;
            }
            
        }
        //if( [_currentEvent.locationName length] != 0){
        if(![_currentEvent.locationName isEqual:[NSNull null]]){
            if([_currentEvent.locationName length] != 0){
                [_locationInfoToDisplay addObject:@"locationName"];
                numRows++;
            }
        }
    }
    
    if(section == 2){
        if (!(_currentEvent.yelpLink == (id)[NSNull null] || _currentEvent.yelpLink.length == 0)){
            [_thirdPartyInfoToDisplay addObject:@"yelp"];
            _YELP_SLOT = numRows;
            numRows++;
        }
        if (!(_currentEvent.uberLink == (id)[NSNull null] || _currentEvent.uberLink.length == 0)){
            [_thirdPartyInfoToDisplay addObject:@"uber"];
            numRows++;
        }
    }
    
    
    if(section == 3){
        numRows = 1;
    }
    
    return numRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    NSString *eventInfoType;
    
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

    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventInfoCell"];
    NSString *eventInfoType;
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
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.eventInfoTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _basicInfoToDisplay = [[NSMutableArray alloc]init];
    _locationInfoToDisplay = [[NSMutableArray alloc]init];
    _thirdPartyInfoToDisplay = [[NSMutableArray alloc]init];
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 180.0)];
    if (!(_currentEvent.locationAddress == (id)[NSNull null] || _currentEvent.locationAddress.length == 0)) {
        CLGeocoder * geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:_currentEvent.locationAddress completionHandler:^(NSArray * placemarks, NSError* error) {
            if (placemarks && placemarks.count > 0) {
                CLPlacemark * topResult = [placemarks objectAtIndex:0];
                MKPlacemark * placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                
                MKCoordinateRegion region = self.mapView.region;
                region.center = placemark.region.center;
                region.span.longitudeDelta /= 200.0;
                region.span.latitudeDelta /= 200.0;
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
    [self getInvitedFriends];
    self.eventInfoTable.dataSource = self;
    self.eventInfoTable.delegate = self;
    //self.friendsCollection.dataSource = self;
    //self.friendsCollection.delegate = self;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
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
}


@end
