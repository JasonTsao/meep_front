//
//  AddFriendsViewController.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/4/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AddFriendsFromTableViewController.h"
#import "FriendsListTableViewController.h"

@class AddFriendsViewController;
@protocol AddFriendsViewControllerDelegate <NSObject>
- (void) backToCenterFromAddFriends:(AddFriendsViewController *)controller;
@end
@interface AddFriendsViewController : UITableViewController<FBLoginViewDelegate>
@property (nonatomic, assign) id <AddFriendsViewControllerDelegate> delegate;
@end
