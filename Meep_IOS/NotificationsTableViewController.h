//
//  NotificationsTableViewController.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/25/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NotificationsTableViewController;
@protocol NotificationsTableViewControllerDelegate
- (void) backToCenterFromNotifications:(NotificationsTableViewController *)controller;

@end
@interface NotificationsTableViewController : UITableViewController
@property(nonatomic, strong) NSMutableData * data;
@property(nonatomic, strong) id <NotificationsTableViewControllerDelegate> delegate;
@end
