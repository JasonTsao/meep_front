//
//  ViewController.h
//  AccountSettings
//
//  Created by Jason Tsao on 4/21/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AccountViewControllerDelegate <NSObject>

@optional

@required

@end

@interface AccountViewController : UIViewController <UITableViewDataSource>

@property (nonatomic, assign) id <AccountViewControllerDelegate> delegate;

@end
