//
//  MEPTableCell.h
//  Meep_IOS
//
//  Created by Ryan Sharp on 5/21/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "Event.h"
#import "Friend.h"
#import "Group.h"
#import <Foundation/Foundation.h>

@interface MEPTableCell : NSObject

+(UIView*)eventCell:(Event*)event userLatitude:(float)lat userLongitude:(float)lng;
+(UIView*)eventHeaderCell:(NSString*)dateText;
+ (CGFloat) customFriendCellHeight;
+ (UITableViewCell*) customFriendCell:(Friend*)friend forTable:(UITableView*)tableView selected:(BOOL)sel;
+ (UITableViewCell*) customGroupCell:(Group*)group forCell:(UITableViewCell*)cell forTable:(UITableView*)tableView selected:(BOOL)sel;

@end
