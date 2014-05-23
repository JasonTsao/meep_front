//
//  AddRemoveFriendsFromGroupTableViewController.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/10/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"
#import "Group.h"

@class AddRemoveFriendsFromGroupTableViewController;

@protocol AddRemoveFriendsFromGroupTableViewControllerDelegate
- (void) backToGroupPage:(AddRemoveFriendsFromGroupTableViewController *)controller;
@end

@interface AddRemoveFriendsFromGroupTableViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>
@property (nonatomic) Group *currentGroup;
@property (nonatomic) NSMutableArray *invitedMembers;
@property (nonatomic) NSMutableArray *originalMembers;
@property (nonatomic) NSMutableArray *removedMembers;
@property (nonatomic) NSMutableArray *members;
@property (nonatomic) NSMutableArray *friends;
@property(nonatomic) NSString *savedGroupName;
@property(nonatomic, strong) NSMutableData * data;
@property(nonatomic, strong) id <AddRemoveFriendsFromGroupTableViewControllerDelegate> delegate;
@end
