//
//  MainViewController.m
//  Navigation
//
//  Created by Tammy Coron on 1/19/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import "MainViewController.h"
#import "CenterViewController.h"
#import "LeftPanelViewController.h"
#import "RightPanelViewController.h"
#import "EventCreatorViewController.h"
#import "EventPageViewController.h"
//#import "AccountViewController.h"
#import "FriendsListTableViewController.h"
//#import "CreateGroupViewController.h"
#import "InviteFriendsViewController.h"
#import "NotificationsTableViewController.h"
#import "ProfileViewController.h"
#import "Event.h"
#import "NotificationHandler.h"
#import "MEPLocationService.h"

#import <QuartzCore/QuartzCore.h>

#define CENTER_TAG 1
#define LEFT_PANEL_TAG 2
#define RIGHT_PANEL_TAG 3
#define CORNER_RADIUS 0
#define SLIDE_TIMING .25
#define PANEL_WIDTH 60

@interface MainViewController () <CenterViewControllerDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) CenterViewController *centerViewController;

@property (nonatomic, strong) ProfileViewController *profileViewController;

@property (nonatomic, strong) CreateGroupViewController *createGroupViewController;
@property (nonatomic, assign) BOOL showGroupCreationPage;

@property (nonatomic, strong) NotificationsTableViewController *notificationsTableViewController;
@property (nonatomic, assign) BOOL showNotificationsPage;

@property (nonatomic, strong) GroupsViewController *groupsViewController;
@property (nonatomic, assign) BOOL showGroupsPage;

@property (nonatomic, strong) FriendsListTableViewController *friendsListTableViewController;
@property (nonatomic, assign) BOOL showingFriendsPanel;

@property (nonatomic, strong) AccountViewController *accountViewController;
@property (nonatomic, assign) BOOL showingAccountPanel;

@property (nonatomic, strong) LeftPanelViewController *leftPanelViewController;
@property (nonatomic, assign) BOOL showingLeftPanel;

@property (nonatomic, strong) RightPanelViewController * rightPanelViewController;
@property (nonatomic, assign) BOOL showingRightPanel;

@property (nonatomic, assign) BOOL showPanel;
@property( nonatomic, assign) CGPoint preVelocity;
@property( nonatomic, strong) EventCreatorViewController *eventCreatorViewController;

@property (nonatomic, strong) InviteFriendsViewController *inviteFriendsViewController;
@property (nonatomic, strong) AuthenticationViewController *authenticationViewController;

@property (nonatomic, strong) AddFriendsViewController *addFriendsViewController;
@property (nonatomic, assign) BOOL showaddFriends;
@property (nonatomic, assign) BOOL showEventCreator;

@property (nonatomic, strong) EventPageViewController *eventPageViewController;
@property (nonatomic, assign) BOOL showEventPage;

@property (nonatomic, strong) MEPLocationService *locationServiceManager;

@end

@implementation MainViewController

#pragma mark -
#pragma mark View Did Load/Unload

- (void)viewDidLoad
{
    [super viewDidLoad];
    BOOL viewExists = [self setupView];
    self.locationServiceManager = [[MEPLocationService alloc] init];
    
    if( viewExists){
        NSLog(@"view already exists");
    }
    //if( user is authenticated){
    //    [self setupView];
    //}
    //else{
    //[self openAuthenticationPage];
    //}
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
    
    if([_eventNotifications count] > 0){
        //NSLog(@"event notification: %@", _eventNotifications);
        //NSString *event_notifications = [NSString stringWithFormat:@"%@", _eventNotifications];
        
    }
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

- (void) logout:(AccountViewController *)controller{
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:NO completion:^{[self openAuthenticationPage];}];
    
}

#pragma mark -
#pragma mark Setup View

- (BOOL)setupView
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    
    if(_centerViewController == nil){
        _centerViewController = (GroupsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"centerView"];
        _centerViewController.delegate = self;
        _centerViewController.eventNotifications = self.eventNotifications;
        
        [self.view addSubview:_centerViewController.view];
        [self addChildViewController:_centerViewController];
        
        [self setupGestures];
    }
    else{
        return YES;
    }
    //_centerViewController = (GroupsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"centerView"];
    
    
    return NO;
    //[self openAuthenticationPage];
}

- (void)showCenterViewWithShadow:(BOOL)value withOffset:(double)offset
{
    if(value) {
        [_centerViewController.view.layer setCornerRadius:CORNER_RADIUS];
        [_centerViewController.view.layer setShadowColor:[UIColor blackColor].CGColor];
        [_centerViewController.view.layer setShadowOpacity:0.8];
        [_centerViewController.view.layer setShadowOffset:CGSizeMake(offset, offset)];
    }
    else {
        [_centerViewController.view.layer setCornerRadius:0.0f];
        [_centerViewController.view.layer setShadowOffset:CGSizeMake(offset,offset)];
    }
}

- (void)resetMainView
{
    if(_leftPanelViewController != nil) {
        [self.leftPanelViewController.view removeFromSuperview];
        self.leftPanelViewController = nil;
        
        _centerViewController.leftButton.tag = 1;
        self.showingLeftPanel = NO;
    }
    if (_rightPanelViewController != nil)
    {
        [self.rightPanelViewController.view removeFromSuperview];
        self.rightPanelViewController = nil;
        
        _centerViewController.rightButton.tag = 1;
        self.showingRightPanel = NO;
    }
    if (_eventCreatorViewController != nil)
    {
        [self.eventCreatorViewController.view removeFromSuperview];
        self.eventCreatorViewController = nil;
        
        _centerViewController.rightButton.tag = 1;
        self.showingRightPanel = NO;
    }
    if (_eventPageViewController != nil)
    {
        [self.eventPageViewController.view removeFromSuperview];
        self.eventPageViewController = nil;
        
        self.showEventPage = NO;
    }
    [self showCenterViewWithShadow:NO withOffset:0];
}

- (UIView *)getLeftView
{    
    if(_leftPanelViewController == nil) {
        self.leftPanelViewController = [[LeftPanelViewController alloc] initWithNibName:@"LeftPanelViewController" bundle:nil];
        self.leftPanelViewController.view.tag = LEFT_PANEL_TAG;
        self.leftPanelViewController.delegate = _centerViewController;
        
        [self.view addSubview:self.leftPanelViewController.view];
        [self addChildViewController:_leftPanelViewController];
        [_leftPanelViewController didMoveToParentViewController:self];
        _leftPanelViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    self.showingLeftPanel = YES;
    [self showCenterViewWithShadow:YES withOffset:-2];
    UIView *view = self.leftPanelViewController.view;
    return view;
}

- (UIView *)getRightView
{
    if(_eventCreatorViewController == nil) {
        self.eventCreatorViewController = [[EventCreatorViewController alloc] initWithNibName:@"CreateEvent" bundle:nil];
        self.eventCreatorViewController.view.tag = RIGHT_PANEL_TAG;
        self.eventCreatorViewController.delegate = _centerViewController;
        [self.view addSubview:self.eventCreatorViewController.view];
        [_eventCreatorViewController didMoveToParentViewController:self];
        _eventCreatorViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    self.showingRightPanel = YES;
    [self showCenterViewWithShadow:YES withOffset:2];
    UIView * view = self.eventCreatorViewController.view;
    return view;
}

#pragma mark -
#pragma mark Swipe Gesture Setup/Actions

#pragma mark - setup

- (void)setupGestures
{
    NSLog(@"setting up gestures!!");
    UIPanGestureRecognizer * panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    
    [_centerViewController.view addGestureRecognizer:panRecognizer];
}

-(void)movePanel:(id)sender
{
    [[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];
    CGPoint velocity = [(UIPanGestureRecognizer*)sender velocityInView:[sender view]];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        UIView *childView = nil;
        
        if(velocity.x > 0) {
            if (!_showingRightPanel) {
                childView = [self getLeftView];
            }
        } else {
            if (!_showingLeftPanel) {
                //childView = [self getRightView];
            }
            
        }
        // Make sure the view you're working with is front and center.
        [self.view sendSubviewToBack:childView];
        [[sender view] bringSubviewToFront:[(UIPanGestureRecognizer*)sender view]];
    }
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
        if(velocity.x > 0) {
            // NSLog(@"gesture went right");
        } else {
            // NSLog(@"gesture went left");
        }
        
        if (!_showPanel) {
            [self movePanelToOriginalPosition];
            _centerViewController.showingLeftPanel = NO;
        } else {
            if (_showingLeftPanel) {
                [self movePanelRight];
                _centerViewController.showingLeftPanel = YES;
            }  else if (_showingRightPanel) {
                [self movePanelLeft];
            }
        }
    }
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        if(velocity.x > 0) {
            // NSLog(@"gesture went right");
        } else {
            // NSLog(@"gesture went left");
        }
        
        // Are you more than halfway? If so, show the panel when done dragging by setting this value to YES (1).
        _showPanel = abs([sender view].center.x - _centerViewController.view.frame.size.width/2) > _centerViewController.view.frame.size.width/2;
        
        // Allow dragging only in x-coordinates by only updating the x-coordinate with translation position.
        [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x, [sender view].center.y);
        [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:self.view];
        
        // If you needed to check for a change in direction, you could use this code to do so.
        if(velocity.x*_preVelocity.x + velocity.y*_preVelocity.y > 0) {
            // NSLog(@"same direction");
        } else {
            // NSLog(@"opposite direction");
        }
        
        _preVelocity = velocity;
    }}

#pragma mark -
#pragma mark Delegate Actions

- (void)movePanelLeft // to show right panel
{
    UIView *childView = [self getRightView];
    [self.view sendSubviewToBack:childView];
    
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _centerViewController.view.frame = CGRectMake(-self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             
                             _centerViewController.rightButton.tag = 0;
                         }
                     }];
}

- (void)movePanelRight // to show left panel
{
    UIView *childView = [self getLeftView];
    [self.view sendSubviewToBack:childView];
    
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         _centerViewController.view.frame = CGRectMake(self.view.frame.size.width - PANEL_WIDTH, 0, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if(finished) {
                             _centerViewController.leftButton.tag = 0;
                         }
                     }];
}

- (void) openProfilePage
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    _profileViewController = (ProfileViewController *)[storyboard instantiateViewControllerWithIdentifier:@"profile"];
    
    NSString *name;
    NSData *authenticated = [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_client"];
    _authClient = [NSKeyedUnarchiver unarchiveObjectWithData:authenticated];
    _profileViewController.userName = _authClient.enc_username;
    
    
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_profileViewController];
    [_profileViewController setDelegate:self];
    [self presentViewController:navigation animated:YES completion:nil];
    
}

- (void) openAuthenticationPage
{
    NSLog(@"opening authentication page");
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    _authenticationViewController = (AuthenticationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"authentication"];
    
    //[self.view addSubview:_authenticationViewController.view];
    [_authenticationViewController setDelegate:self];
    [self presentViewController:_authenticationViewController animated:YES completion:nil];
    //[self addChildViewController:_authenticationViewController];

}

- (void) openAccountPage
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    _accountViewController = (AccountViewController *)[storyboard instantiateViewControllerWithIdentifier:@"accountSettings"];
    
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_accountViewController];
    [_accountViewController setDelegate:self];
    [self presentViewController:navigation animated:YES completion:nil];
}


- (void) openGroupsPage
{
    //[self.view addSubview:_centerViewController.view];
    //[self addChildViewController:_centerViewController];
    
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    _groupsViewController = (GroupsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"groups"];
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_groupsViewController];
    [_groupsViewController setDelegate:self];
    
    //[self.view addSubview:_groupsViewController.view];
    //[self addChildViewController:_groupsViewController];
    [self presentViewController:navigation animated:YES completion:nil];
}


- (void) openCreateEventPage
{

    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    _inviteFriendsViewController = (InviteFriendsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"createEvent"];
    
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_inviteFriendsViewController];
    [_inviteFriendsViewController setDelegate:self];
    [self presentViewController:navigation animated:YES completion:nil];
}


- (void) openFriendsListPage
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    _friendsListTableViewController = (FriendsListTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"friendsList"];
    
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_friendsListTableViewController];
    [_friendsListTableViewController setDelegate:self];
    [self presentViewController:navigation animated:YES completion:nil];
}

- (void) openAddFriendsPage
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    _addFriendsViewController = (AddFriendsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"addFriends"];
    
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_addFriendsViewController];
    [_addFriendsViewController setDelegate:self];
    [self presentViewController:navigation animated:YES completion:nil];
}

- (void)openNotificationsPage
{
    NSLog(@"opening notification page");
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    _notificationsTableViewController = (NotificationsTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"notifications"];
    
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_notificationsTableViewController];
    [_notificationsTableViewController setDelegate:self];
    [self presentViewController:navigation animated:YES completion:nil];
}

- (void) loadMainViewAfterAuthentication
{
    
    NSLog(@"loading main view after authentication");
    [_authenticationViewController dismissViewControllerAnimated:YES completion:nil];
    [self setupView];
}

- (void) backToMainFromProfilePage:(ProfileViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) backToCenterFromCreateEvent:(InviteFriendsViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) backToCenterFromAccountSettings:(AccountViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) backToCenterFromGroups:(GroupsViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) backToCenterFromFriends:(FriendsListTableViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) backToCenterFromEventPage:(EventPageViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) backToCenterFromAddFriends:(AddFriendsViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) backToCenterFromNotifications:(NotificationsTableViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)movePanelToOriginalPosition
{
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        _centerViewController.view.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        if(finished) {
            [self resetMainView];
        }
    }];
}

- (void)displayEventPage:(Event *)event{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    self.eventPageViewController = (EventPageViewController *)[storyboard instantiateViewControllerWithIdentifier:@"EventViewController"];
    _eventPageViewController.currentEvent = event;
    NSString *event_id = [NSString stringWithFormat:@"%i", event.event_id];
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
    
    [self.eventPageViewController setDelegate:self];
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_eventPageViewController];
    [self presentViewController:navigation animated:YES completion:nil];
    //[self presentViewController:self.eventPageViewController animated:YES completion:nil];
}

- (void) returnToMain {
    [self resetMainView];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
