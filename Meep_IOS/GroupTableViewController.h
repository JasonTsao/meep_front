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

@interface GroupTableViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>
//@property (nonatomic) Group *selectedGroup;
@property (nonatomic) NSMutableArray *groupMembers;
@property (nonatomic) Group *group;
@property(nonatomic, strong) NSMutableData * data;
@end
