//
//  Group.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/3/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "Group.h"

@implementation Group

@synthesize group_creator_id;
@synthesize name;
@synthesize group_id;
@synthesize group_members;
@synthesize groupProfilePic;

-(id) initWithName:(NSString*) groupName
{
    if((self = [super init])) {
        //_name = groupName;
        name = groupName;

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.group_creator_id = [decoder decodeIntegerForKey:@"group_creator_id"];
        self.group_id = [decoder decodeIntegerForKey:@"group_id"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.group_members = [decoder decodeObjectForKey:@"group_members"];
        self.groupProfilePic = [decoder decodeObjectForKey:@"groupProfilePic"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInteger:group_creator_id forKey:@"group_creator_id"];
    [encoder encodeInteger:group_id forKey:@"group_id"];
    [encoder encodeObject: name forKey:@"name"];
    [encoder encodeObject: group_members forKey:@"group_members"];
    [encoder encodeObject: groupProfilePic forKey:@"groupProfilePic"];
}


@end
