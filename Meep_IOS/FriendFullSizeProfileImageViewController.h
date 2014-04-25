//
//  FriendFullSizeProfileImageViewController.h
//  Friends
//
//  Created by Jason Tsao on 4/24/14.
//  Copyright (c) 2014 Jason Tsao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"
#import "Photo.h"

@interface FriendFullSizeProfileImageViewController : UIViewController

@property (nonatomic) Friend *currentFriend;
@property (nonatomic) Photo *currentPhoto;

@end
