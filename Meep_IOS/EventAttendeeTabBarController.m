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

@interface EventAttendeeTabBarController ()


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

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    NSLog(@"in should select view controller");
    NSLog(@"view controller:%@",viewController);
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backToEventPage:)];
    
    UIBarButtonItem *optionsBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(openAttendeeOptions:)];
    
    self.navigationItem.leftBarButtonItem = customBarItem;
    self.navigationItem.rightBarButtonItem = optionsBarItem;
    
    EventAttendeesViewController *eventAttendeesViewController = [self.tabBarController.viewControllers objectAtIndex:0];
    
    NSLog(@"view controllers: %@", self.tabBarController.viewControllers);
    NSLog(@"eventattendees view controller: %@", eventAttendeesViewController);
    eventAttendeesViewController.invitedFriends = _invitedFriends;
    eventAttendeesViewController.currentEvent = _currentEvent;
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
