//
//  InvitedFriend.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/3/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InvitedFriend : NSObject
@property (nonatomic) NSInteger event_id;
@property (nonatomic) NSInteger account_id;
@property (nonatomic) NSInteger invited_friend_id;
@property (nonatomic) BOOL attending;
@property (nonatomic) BOOL can_invite_friends;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *longitude;
@property (nonatomic) NSString *latitude;
@property (nonatomic) NSString *profile_pic_url;
@property (nonatomic) UIImage * profilePic;

-(id) initWithName:(NSString*) friendName
     withAccountID:(NSInteger*) friendAccountid
     withAttending:(BOOL) friendAttending
     withCanInvite:(BOOL)friendCanInvite;
@end
