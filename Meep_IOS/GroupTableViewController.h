//
//  GroupTableViewController.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/3/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"
#import "Group.h"
#import "MEEPhttp.h"

@class GroupTableViewController;
@protocol GroupTableViewControllerDelegate
- (void)updatedGroupName:(id)sender;
@end

@interface GroupTableViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
//@property (nonatomic) Group *selectedGroup;
@property (nonatomic) NSMutableArray *groupMembers;
@property (nonatomic) Group *group;
@property(nonatomic, strong) id <GroupTableViewControllerDelegate> delegate;
@property(nonatomic, strong) NSMutableData * data;


@end
