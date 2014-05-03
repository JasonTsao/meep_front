//
//  InvitedFriend.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/3/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "InvitedFriend.h"

@implementation InvitedFriend

-(id) initWithName:(NSString*) friendName
                 withAccountID:(NSInteger*) friendAccountid
                withAttending:(BOOL) friendAttending
            withCanInvite:(BOOL)friendCanInvite{
    if((self = [super init])) {
        _name = friendName;
        _account_id = friendAccountid;
        _attending = friendAttending;
        _can_invite_friends = friendCanInvite;
    }
    return self;
}
@end
