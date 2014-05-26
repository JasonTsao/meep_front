//
//  MEPAppDelegate.h
//  MeepIOS
//
//  Created by Ryan Sharp on 4/13/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "MainViewController.h"
#import "AccountSettings.h"
#import "AuthenticationViewController.h"

@interface MEPAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainViewController *viewController;
@property(nonatomic, strong) NSMutableData * data;
@property (nonatomic) NSMutableDictionary *groupNotifications;
@property (nonatomic) NSMutableDictionary *eventNotifications;
@property (strong, nonatomic) AuthenticationViewController *authenticationViewController;
@property (nonatomic, strong) AccountSettings * account_settings;
-(void) sessionStateChanged:(FBSession*)session state:(FBSessionState*)sessionState error:(NSError *)ns_error;
@end
