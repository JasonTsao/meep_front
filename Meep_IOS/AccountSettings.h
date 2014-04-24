//
//  AccountSettings.h
//  Meep_IOS
//
//  Created by Jason Tsao on 4/23/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountSettings : NSObject
@property BOOL user_is_private;
@property BOOL searchable;
@property BOOL reminders;
@property BOOL vibrate_on_notification;

-(id) initWithPrivate:(BOOL) acctPrivate
                 withSearchable:(BOOL) acctSearchable
                withReminders:(BOOL) acctReminders
        withVibrateOnNotification:(BOOL) acctVibrateOnNotification;

@end
