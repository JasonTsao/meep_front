//
//  EventPageViewController.m
//  MeepIOS
//
//  Created by Ryan Sharp on 4/15/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "EventPageViewController.h"
#import "EditEventViewController.h"
#import "AddRemoveFriendsFromEventTableViewController.h"
#import "Event.h"

@interface EventPageViewController ()

@property (weak, nonatomic) IBOutlet UILabel *eventDescription;
@property (weak, nonatomic) IBOutlet UICollectionView *friendsCollection;

@property (weak, nonatomic) IBOutlet UILabel *description;
@property (weak, nonatomic) IBOutlet UINavigationItem *eventNavBar;

@property (nonatomic, strong) EditEventViewController *editEventViewController;
@property (nonatomic, assign) BOOL showingEditPage;

@property (nonatomic, strong) AddRemoveFriendsFromEventTableViewController *addRemoveFriendsFromEventTableViewController;

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

- (void) openEditEventPage
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    _editEventViewController = (EditEventViewController *)[storyboard instantiateViewControllerWithIdentifier:@"editEvent"];
    
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_editEventViewController];
    [_editEventViewController setDelegate:self];
    _editEventViewController.currentEvent = _currentEvent;
    [self presentViewController:navigation animated:YES completion:nil];
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
                    NSLog(@"Removing user from group");
                    //[self logoutSelect];
                    break;
                case 1:
                    NSLog(@"going to edit view page");
                    [self openEditEventPage];
                    break;
                case 2:
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
    UIActionSheet *eventOptionsPopup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Leave Event", @"Edit Event", @"Add/Remove Friends",nil];
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

-(void) aMethod
{
    NSLog(@"yay!");
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //UICollectionViewCell *cell = [_friendsCollection dequeueReusableCellWithReuseIdentifier:@"table" forIndexPath:indexPath];
    UICollectionViewCell *cell = [_friendsCollection dequeueReusableCellWithReuseIdentifier:@"invitedFriendCell" forIndexPath:indexPath];
    //UIImage *cellImage = [[UIImage alloc] init];
    UIButton *cellButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    NSString *user_name;

    if([[_invitedFriends[indexPath.row] name] length] >= 6){
        //user_name = [_invitedFriends[indexPath.row] name];
        user_name = [[_invitedFriends[indexPath.row] name] substringToIndex:6];
    }
    else{
        user_name = [_invitedFriends[indexPath.row] name];
    }

    [cellButton addTarget:self
               action:@selector(aMethod:)
     forControlEvents:UIControlEventTouchUpInside];
    [cellButton setTitle:user_name forState:UIControlStateNormal];
    cellButton.frame = CGRectMake(0.0, 0.0, 50.0, 50.0);
    [cell.contentView addSubview: cellButton];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *friend_name;
    Friend *selectedFriend;
    
    if(indexPath.section == 0){
        /*selectedFriend = selected_friends_list[indexPath.row];
        friend_name = selectedFriend.name;
        [tableView beginUpdates];
        [selected_friends_list removeObjectAtIndex: indexPath.row];
        [tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]]
                         withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView endUpdates];*/
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *header;
    if (section == 0){
        header = @"Invited";
    }
    
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 1;
    if (section == 0){
        numRows = [_invitedFriends count];
    }

    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventInvitedFriend"];
    
    if (indexPath.section == 0){
        Friend *currentFriend = _invitedFriends[indexPath.row];
        cell.textLabel.text = currentFriend.name;
    }
    
    return cell;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([_currentEvent.description length] > 15){
        self.title = [_currentEvent.description substringToIndex:15];
    }
    else{
        self.title = _currentEvent.description;
    }
    [self getInvitedFriends];
    _eventDescription.text = _currentEvent.description;
    _description.text = _currentEvent.description;
    //self.friendsCollection.dataSource = self;
    //self.friendsCollection.delegate = self;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.friendsCollection setCollectionViewLayout:flowLayout];
    //[self.friendsCollection registerNib:[UINib nibWithNibName:@"EventPage" bundle:nil] forCellWithReuseIdentifier:@"5"];
    // Do any additional setup after loading the view.
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
