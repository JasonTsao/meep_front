//
//  ProfileViewController.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/16/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProfileViewController;

@protocol ProfileViewControllerDelegate
- (void) backToMainFromProfilePage:(ProfileViewController *)controller;

@end
@interface ProfileViewController : UIViewController
@property (nonatomic) NSString *userName;
@property(nonatomic, strong) id <ProfileViewControllerDelegate> delegate;
@end
