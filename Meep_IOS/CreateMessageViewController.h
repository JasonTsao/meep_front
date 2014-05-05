//
//  CreateMessageViewController.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/1/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"
#import "InvitedFriend.h"
#import "MEEPhttp.h"
#import "EventPageViewController.h"
//#import "CenterViewController.h"
//#import "MainViewController.h"
@class CreateMessageViewController;

@protocol CreateMessageViewControllerDelegate
@end

@interface CreateMessageViewController : UIViewController<UITableViewDataSource, UITextFieldDelegate>
@property(nonatomic, strong) id <CreateMessageViewControllerDelegate> delegate;
@property (nonatomic) NSMutableArray *invited_friends_list;
-(void)textFieldDidChange;
@end
