//
//  GroupEventsTableViewController.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/12/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"

@class GroupEventsTableViewController;
@protocol GroupEventsTableViewControllerDelegate
@end


@interface GroupEventsTableViewController : UITableViewController

@property (nonatomic) NSMutableArray *groupMembers;
@property (nonatomic) Group *group;
@property(nonatomic, strong) NSMutableData * data;

@property(nonatomic, strong) id <GroupEventsTableViewControllerDelegate> delegate;
@end
