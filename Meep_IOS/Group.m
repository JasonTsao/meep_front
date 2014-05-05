//
//  Group.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/3/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "Group.h"

@implementation Group

-(id) initWithName:(NSString*) groupName
{
    if((self = [super init])) {
        _name = groupName;

    }
    return self;
}


@end
