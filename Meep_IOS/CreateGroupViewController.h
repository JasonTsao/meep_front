//
//  CreateGroupViewController.h
//  Group
//
//  Created by Jason Tsao on 4/30/14.
//  Copyright (c) 2014 Jason Tsao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CreateGroupViewController;

@protocol CreateGroupViewControllerDelegate
- (void) backToCenterFromGroups:(CreateGroupViewController *)controller;
@end

@interface CreateGroupViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong) id <CreateGroupViewControllerDelegate> delegate;
@property(nonatomic, strong) NSMutableData * data;

- (IBAction) backToMain:(id)sender;
@end
