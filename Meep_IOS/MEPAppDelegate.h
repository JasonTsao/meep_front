//
//  MEPAppDelegate.h
//  MeepIOS
//
//  Created by Ryan Sharp on 4/13/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "AccountSettings.h"

@interface MEPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainViewController *viewController;
@property(nonatomic, strong) NSMutableData * data;
@property (nonatomic, strong) AccountSettings * account_settings;
@end
