//
//  EventAttendeeTabBarController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/12/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "EventAttendeeTabBarController.h"
#import "EventAttendeesViewController.h"
#import "EventAttendeesDistanceViewController.h"
#import "AddRemoveFriendsFromEventTableViewController.h"

@interface EventAttendeeTabBarController ()
@property (nonatomic, strong) AddRemoveFriendsFromEventTableViewController *addRemoveFriendsFromEventTableViewController;

@end



@implementation EventAttendeeTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)backToEventPage:(id)sender {
    [self.delegate backToEventPage:self];
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
                    NSLog(@"Add Remove users");
                    //[self logoutSelect];
                    [self openAddRemoveFriendsPage];
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void)openAttendeeOptions:(id)sender {
    //[self.delegate backToEventPage:self];
    UIActionSheet *eventOptionsPopup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add/Remove Friends",nil];
    //else
    //UIActionSheet *eventOptionsPopup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil  otherButtonTitles:@"Leave Event",nil];
    eventOptionsPopup.tag = 1;
    [eventOptionsPopup showInView:self.view];

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backToEventPage:)];
    
    UIBarButtonItem *optionsBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(openAttendeeOptions:)];
    
    self.navigationItem.leftBarButtonItem = customBarItem;
    self.navigationItem.rightBarButtonItem = optionsBarItem;
    
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
    NSLog(@"seguing to : %@", segue);
    NSLog(@"sender is: %@", sender);
}


@end
