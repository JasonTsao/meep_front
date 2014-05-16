//
//  Friend.h
//  Friends
//
//  Created by Jason Tsao on 4/24/14.
//  Copyright (c) 2014 Jason Tsao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Friend : NSObject <NSCoding>{
    NSInteger account_id;
    NSString *name;
    NSString *bio;
    NSString *imageFileName;
    NSString *phoneNumber;
    NSInteger numFriends;
    NSInteger numTimesInvitedByMe;
    UIImage * profilePic;
}

@property (nonatomic) NSInteger account_id;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *bio;
@property (nonatomic) NSString *imageFileName;
@property (nonatomic) NSString *phoneNumber;
@property (nonatomic) NSInteger numFriends;
@property (nonatomic) NSInteger numTimesInvitedByMe;
@property (nonatomic, strong) UIImage * profilePic;


@end
