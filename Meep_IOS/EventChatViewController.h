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

@interface EventChatViewController : UIViewController <UITextFieldDelegate>
@property (nonatomic) Event *currentEvent;
@property (nonatomic) NSMutableArray *invitedFriends;
@property (nonatomic) NSString *account_id;
@property (nonatomic) NSString *user_name;
@property(nonatomic, strong) NSMutableData * data;
+(UIColor*)colorWithHexString:(NSString*)hex;
- (void)reloadEventChat:(NSString *)message withAccount:(NSString*)account_id withName:(NSString *)user_name;
@end
