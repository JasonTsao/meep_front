//
//  AccountSettings.h
//  Meep_IOS
//
//  Created by Jason Tsao on 4/23/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountSettings : NSObject <NSCoding>{
    BOOL user_is_private;
    BOOL searchable;
    BOOL reminders;
    BOOL vibrate_on_notification;
}
@property (nonatomic) BOOL user_is_private;
@property (nonatomic) BOOL searchable;
@property (nonatomic) BOOL reminders;
@property (nonatomic) BOOL vibrate_on_notification;

-(id) initWithPrivate:(BOOL) acctPrivate
                 withSearchable:(BOOL) acctSearchable
                withReminders:(BOOL) acctReminders
        withVibrateOnNotification:(BOOL) acctVibrateOnNotification;

@end
