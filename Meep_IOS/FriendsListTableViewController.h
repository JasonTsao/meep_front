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

@interface FriendsListTableViewController : UITableViewController
@property(nonatomic, strong) NSMutableData * data;
@end
