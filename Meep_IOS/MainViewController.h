//
//  MainViewController.h
//  Navigation
//
//  Created by Tammy Coron on 1/19/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InviteFriendsViewController.h"
#import "AccountViewController.h"
#import "CreateGroupViewController.h"
#import "GroupsViewController.h"
#import "EventPageViewController.h"
#import "AddFriendsViewController.h"
#import "AuthenticationViewController.h"

@interface MainViewController : UIViewController<AccountViewControllerDelegate, CreateGroupViewControllerDelegate, GroupsViewControllerDelegate, InviteFriendsViewControllerDelegate>

@end
