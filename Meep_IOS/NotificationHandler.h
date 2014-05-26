//
//  NotificationHandler.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/23/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "MainViewController.h"

@interface NotificationHandler : NSObject
+ (void)createAndSendLocalNotificationForEvent:(Event*)event;
+ (void)handleNotification:(NSDictionary*)userInfo forMainView:(MainViewController*)viewController;
@property (strong, nonatomic) MainViewController *mainViewController;
@end
