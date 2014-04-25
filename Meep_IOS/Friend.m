//
//  Friend.m
//  Friends
//
//  Created by Jason Tsao on 4/24/14.
//  Copyright (c) 2014 Jason Tsao. All rights reserved.
//

#import "Friend.h"

@implementation Friend

@synthesize name;
@synthesize account_id;
@synthesize bio;
@synthesize imageFileName;
@synthesize phoneNumber;
@synthesize numFriends;
@synthesize numTimesInvitedByMe;

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.account_id = [decoder decodeIntegerForKey:@"account_id"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.bio = [decoder decodeObjectForKey:@"bio"];
        self.imageFileName = [decoder decodeObjectForKey:@"imageFileName"];
        self.phoneNumber = [decoder decodeObjectForKey:@"phoneNumber"];
        self.numFriends = [decoder decodeIntegerForKey:@"numFriends"];
        self.numTimesInvitedByMe = [decoder decodeIntegerForKey:@"numTimesInvitedByMe"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:account_id forKey:@"account_id"];
    [encoder encodeObject: name forKey:@"name"];
    [encoder encodeObject: bio forKey:@"bio"];
    [encoder encodeObject: imageFileName forKey:@"imageFileName"];
    [encoder encodeObject: phoneNumber forKey:@"phoneNumber"];
    [encoder encodeInteger:numFriends forKey:@"numFriends"];
    [encoder encodeInteger:numTimesInvitedByMe forKey:@"numTimesInvitedByMe"];
}


@end
