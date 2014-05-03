//
//  GroupsViewController.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/1/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"
#import "MEEPhttp.h"
#import "Group.h"
#import "GroupTableViewController.h"

@class GroupsViewController;
@protocol GroupsViewControllerDelegate
- (void) backToCenterFromGroups:(GroupsViewController *)controller;

@end
@interface GroupsViewController : UITableViewController

@property(nonatomic, strong) id <GroupsViewControllerDelegate> delegate;
@property(nonatomic, strong) NSMutableData * data;

- (IBAction) backToMain:(id)sender;

@end
