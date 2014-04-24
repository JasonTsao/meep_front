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
<<<<<<< HEAD
=======
@property(nonatomic, strong) NSMutableData * data;
@property (nonatomic, strong) AccountSettings * account_settings;
>>>>>>> 1f59d1d3f72a4c5ccf58b92768c6a6202896c520
@end
