//
//  Notification.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/25/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notification : NSObject
@property (nonatomic) NSString *message;
@property (nonatomic) NSString *type;
@property (nonatomic) NSString *time_stamp;
@property (nonatomic) NSInteger notification_id;
@end
