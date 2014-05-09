//
//  AddRemoveFriendsFromEventTableViewController.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/9/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@class AddRemoveFriendsFromEventTableViewController;

@protocol AddRemoveFriendsFromEventTableViewControllerDelegate
- (void) backToEventPage:(AddRemoveFriendsFromEventTableViewController *)controller;
@end


@interface AddRemoveFriendsFromEventTableViewController : UITableViewController<UITableViewDataSource>
@property (nonatomic) Event *currentEvent;
@property (nonatomic) NSMutableArray *invitedFriends;
@property (nonatomic) NSMutableArray *originalInvitedFriends;
@property (nonatomic) NSMutableArray *removedFriends;
@property (nonatomic) NSMutableArray *friends;
@property(nonatomic, strong) NSMutableData * data;
@property(nonatomic, strong) id <AddRemoveFriendsFromEventTableViewControllerDelegate> delegate;
@end
