//
//  FriendProfileViewController.h
//  Friends
//
//  Created by Jason Tsao on 4/24/14.
//  Copyright (c) 2014 Jason Tsao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"
#import "FriendFullSizeProfileImageViewController.h"
#import "Photo.h"
@class FriendProfileViewController;

@protocol FriendProfileViewControllerDelegate
- (void) backToEventPage:(FriendProfileViewController *)controller;
- (void) backToEventAttendeesPage:(FriendProfileViewController *)controller;
@end
@interface FriendProfileViewController : UIViewController

@property (nonatomic) Friend *currentFriend;
@property(nonatomic, strong) id <FriendProfileViewControllerDelegate> delegate;
@end
