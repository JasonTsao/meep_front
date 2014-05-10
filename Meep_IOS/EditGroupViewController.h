//
//  EditGroupViewController.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/10/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"

@class EditGroupViewController;

@protocol EditGroupViewControllerDelegate
- (void) backToGroupPage:(EditGroupViewController *)controller;
@end


@interface EditGroupViewController : UIViewController
@property (nonatomic) Group *currentGroup;
@property(nonatomic) NSString *originalName;
@property(nonatomic) NSString *savedGroupName;
@property(nonatomic, strong) id <EditGroupViewControllerDelegate> delegate;
@end
