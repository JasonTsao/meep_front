//
//  FriendsListTableViewController.h
//  Friends
//
//  Created by Jason Tsao on 4/24/14.
//  Copyright (c) 2014 Jason Tsao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"
#import "FriendProfileViewController.h"

@class FriendsListTableViewController;

@protocol FriendsListTableViewControllerDelegate
- (void) backToCenterFromFriends:(FriendsListTableViewController *)controller;
@end
@interface FriendsListTableViewController : UITableViewController
@property(nonatomic, strong) id <FriendsListTableViewControllerDelegate> delegate;
@property(nonatomic, strong) NSMutableData * data;

- (IBAction) backToMain:(id)sender;
@end
