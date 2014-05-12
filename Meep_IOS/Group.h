//
//  Group.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/3/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Group : NSObject
@property (nonatomic) NSInteger group_creator_id;
@property (nonatomic) NSString *name;
@property (nonatomic) NSInteger group_id;
@property (nonatomic) NSMutableArray * group_members;
-(id) initWithName:(NSString*) groupName;
@end
