//
//  EventChatViewController.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/17/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "InvitedFriend.h"
#import "Friend.h"

@interface EventChatViewController : UIViewController
@property (nonatomic) Event *currentEvent;
@property (nonatomic) NSMutableArray *invitedFriends;
@property (nonatomic) NSString *account_id;
@property(nonatomic, strong) NSMutableData * data;
+(UIColor*)colorWithHexString:(NSString*)hex;
@end
