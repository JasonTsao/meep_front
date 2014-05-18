//
//  CenterViewController.h
//  Navigation
//
//  Created by Tammy Coron on 1/19/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//
#import "LeftPanelViewController.h"
#import "RightPanelViewController.h"
#import "EventCreatorViewController.h"
#import "EventPageViewController.h"
#import "AccountViewController.h"
#import "CreateGroupViewController.h"
#import "InviteFriendsViewController.h"
#import "Event.h"

@protocol CenterViewControllerDelegate <NSObject>

@optional
- (void)movePanelLeft;
- (void)movePanelRight;

@required
- (void)movePanelToOriginalPosition;
- (void)displayEventPage:(Event *)event;
- (void)returnToMain;
- (void)openAccountPage;
- (void)openFriendsListPage;
- (void)openCreateEventPage;
- (void)openGroupsPage;
- (void)openAddFriendsPage;
- (void)openProfilePage;

@end

@interface CenterViewController : UIViewController <LeftPanelViewControllerDelegate, RightPanelViewControllerDelegate, EventCreatorViewControllerDelegate, EventPageViewControllerDelegate, AccountViewControllerDelegate, UITableViewDelegate>

@property (nonatomic, assign) id<CenterViewControllerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UIButton *leftButton;
@property (nonatomic, weak) IBOutlet UIButton *rightButton;

+(UIColor*)colorWithHexString:(NSString*)hex;

@end
