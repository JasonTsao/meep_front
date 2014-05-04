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
#import "Event.h"

#import <QuartzCore/QuartzCore.h>

#define CENTER_TAG 1
#define LEFT_PANEL_TAG 2
#define RIGHT_PANEL_TAG 3
#define CORNER_RADIUS 4
#define SLIDE_TIMING .25
#define PANEL_WIDTH 60

@interface MainViewController () <CenterViewControllerDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) CenterViewController *centerViewController;

@property (nonatomic, strong) CreateGroupViewController *createGroupViewController;
@property (nonatomic, assign) BOOL showGroupCreationPage;

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
@property (nonatomic, assign) BOOL showEventCreator;

@property (nonatomic, strong) EventPageViewController *eventPageViewController;
@property (nonatomic, assign) BOOL showEventPage;

@end

@implementation MainViewController

#pragma mark -
#pragma mark View Did Load/Unload

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupView];
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
#pragma mark Setup View

- (void)setupView
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    _centerViewController = (GroupsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"centerView"];
    
    //UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_centerViewController];
    //[self presentViewController:navigation animated:YES completion:nil];
    _centerViewController.delegate = self;
    
    [self.view addSubview:_centerViewController.view];
    [self addChildViewController:_centerViewController];
    
    [_centerViewController didMoveToParentViewController:self];
    
    
    // setup center view
    /*self.centerViewController = [[CenterViewController alloc] initWithNibName:@"CenterViewController" bundle:nil];
    self.centerViewController.view.tag = CENTER_TAG;
    
    self.centerViewController.delegate = self;
    
    [self.view addSubview:self.centerViewController.view];
    [self addChildViewController:_centerViewController];
    
    [_centerViewController didMoveToParentViewController:self];*/
    [self setupGestures];
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

//- (UIView *)getEventPageView:(Event*)selectedEvent {
- (EventPageViewController *)getEventPageView:(Event*)selectedEvent {
    if(_eventPageViewController == nil) {
        self.eventPageViewController = [[EventPageViewController alloc] initWithNibName:@"EventPage" bundle:nil];
        _eventPageViewController.currentEvent = selectedEvent;
        self.eventPageViewController.view.tag = RIGHT_PANEL_TAG;
        self.eventPageViewController.delegate = _centerViewController;
        [self.view addSubview:self.eventPageViewController.view];
        [_eventPageViewController didMoveToParentViewController:self];
        _eventPageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
    }
    self.showEventPage = YES;
    [self showCenterViewWithShadow:YES withOffset:2];
    //UIView * view = self.eventCreatorViewController.view;
    UIView * view = _eventPageViewController.view;
    //return view;
    return _eventPageViewController;
}

#pragma mark -
#pragma mark Swipe Gesture Setup/Actions

#pragma mark - setup

- (void)setupGestures
{
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
                childView = [self getRightView];
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
        } else {
            if (_showingLeftPanel) {
                [self movePanelRight];
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

- (void) openAccountPage
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _accountViewController = (AccountViewController *)[storyboard instantiateViewControllerWithIdentifier:@"accountSettings"];
    
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_accountViewController];
    [_accountViewController setDelegate:self];
    [self presentViewController:navigation animated:YES completion:nil];
    //[self presentViewController:_accountViewController animated:YES completion:nil];
}

- (void) openCreateGroupPage
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"GroupsStoryboard" bundle:nil];
    _createGroupViewController = (CreateGroupViewController *)[storyboard instantiateViewControllerWithIdentifier:@"groups"];
    [self presentViewController:_createGroupViewController animated:YES completion:nil];
}



- (void) openGroupsPage
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"GroupsStoryboard" bundle:nil];
    _groupsViewController = (GroupsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"groups"];
    
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_groupsViewController];
    [_groupsViewController setDelegate:self];
    [self presentViewController:navigation animated:YES completion:nil];
    /*[self presentViewController:_friendsListTableViewController animated:YES completion:nil];*/
}


- (void) openCreateEventPage
{
    /*UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CreateEventStoryboard" bundle:nil];
    _inviteFriendsViewController = (InviteFriendsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"createEvent"];
    [self presentViewController:_inviteFriendsViewController animated:YES completion:nil];*/
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CreateEventStoryboard" bundle:nil];
    _inviteFriendsViewController = (InviteFriendsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"createEvent"];
    
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_inviteFriendsViewController];
    [_inviteFriendsViewController setDelegate:self];
    [self presentViewController:navigation animated:YES completion:nil];
}


- (void) openFriendsListPage
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"FriendsStoryboard" bundle:nil];
    _friendsListTableViewController = (FriendsListTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"friendsList"];
    
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_friendsListTableViewController];
    [_friendsListTableViewController setDelegate:self];
    [self presentViewController:navigation animated:YES completion:nil];
    /*[self presentViewController:_friendsListTableViewController animated:YES completion:nil];*/
}

// MOST LIKELY WONT USE THIS FUNCTION ANYMORE
- (EventPageViewController *)OpenEventPage:(Event*)selectedEvent {
    NSLog(@"selected event: %@", selectedEvent);
    if(_eventPageViewController == nil) {
        self.eventPageViewController = [[EventPageViewController alloc] initWithNibName:@"EventPage" bundle:nil];
        self.eventPageViewController.view.tag = RIGHT_PANEL_TAG;
        self.eventPageViewController.delegate = _centerViewController;
        [self.view addSubview:self.eventPageViewController.view];
        [_eventPageViewController didMoveToParentViewController:self];
        _eventPageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _eventPageViewController.currentEvent = selectedEvent;
    }
    self.showEventPage = YES;
    [self showCenterViewWithShadow:YES withOffset:2];
    //UIView * view = self.eventCreatorViewController.view;
    //UIView * view = _eventPageViewController.view;
    return _eventPageViewController;
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
    NSLog(@"event: %@", event);
    //UIView * childView = [self getEventPageView:event];
    //[[self navigationController] setView:childView];
    EventPageViewController * eventPage = [self getEventPageView:event];
    NSLog(@"eventdescription : %@", eventPage.currentEvent.description);
    //NSLog(@"%@", eventPage.modalTransitionStyle);
    //eventPage.
    /*
    NSArray *viewArray = [[NSArray alloc] initWithObjects:eventPage,nil];
    [[self navigationController] pushViewController:eventPage animated:YES];*/
    //[[self navigationController] setViewControllers:viewArray animated:YES];
    
    //[[self navigationController] ];
    //EventPageViewController *childView = [self OpenEventPage:event];
    //[self presentViewController:childView animated:YES completion:nil];
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
