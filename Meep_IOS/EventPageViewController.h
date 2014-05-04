//
//  EventPageViewController.h
//  MeepIOS
//
//  Created by Ryan Sharp on 4/15/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "Friend.h"
#import "InvitedFriend.h"
#import "MEEPhttp.h"

@protocol EventPageViewControllerDelegate <NSObject>

@optional

@required
- (void)closeEventModal;

@end

@interface EventPageViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) Event *currentEvent;
@property (nonatomic) NSMutableArray *invitedFriends;
@property(nonatomic, strong) NSMutableData * data;
@property (nonatomic, assign) id<EventPageViewControllerDelegate> delegate;

@end
