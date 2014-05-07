//
//  ViewController.h
//  AccountSettings
//
//  Created by Jason Tsao on 4/21/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AccountViewController;
@protocol AccountViewControllerDelegate <NSObject>
- (void) backToCenterFromAccountSettings:(AccountViewController *)controller;
- (void) logout:(AccountViewController*)controller;
@optional

@required

@end

@interface AccountViewController : UIViewController <UITableViewDataSource,UIActionSheetDelegate>

@property (nonatomic, assign) id <AccountViewControllerDelegate> delegate;
- (IBAction) backToMain:(id)sender;
@end
