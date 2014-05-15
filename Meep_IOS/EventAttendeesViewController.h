//
//  EventAttendeesViewController.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/12/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "InvitedFriend.h"
#import "Friend.h"

@interface EventAttendeesViewController : UICollectionViewController<UIActionSheetDelegate>
@property (nonatomic) Event *currentEvent;
@property (nonatomic) NSMutableArray *invitedFriends;
@property(nonatomic, strong) NSMutableData * data;
@end
