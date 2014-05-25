//
//  LeftPanelViewController.h
//  SlideoutNavigation
//
//  Created by Tammy Coron on 1/10/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LeftPanelViewControllerDelegate <NSObject>

@optional

@required
- (void)openAccountSettings;
- (void)openFriendsListPage;
- (void)openGroupsPage;
- (void)openAddFriendsPage;
- (void)openProfilePage;
- (void)openNotificationsPage;
@end

@interface LeftPanelViewController : UIViewController

@property (nonatomic, assign) id<LeftPanelViewControllerDelegate> delegate;

@end