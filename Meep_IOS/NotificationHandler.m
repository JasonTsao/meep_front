//
//  NotificationHandler.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/23/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "NotificationHandler.h"

//localNotif.alertAction = NSLocalizedString(@"View Details", nil); localized string example
@implementation NotificationHandler

// LOCAL NOTIFICATIONS FOR IN SYSTEM THINGS THAT HAPPEN
+ (void)createAndSendLocalNotificationForEvent:(Event*)event
{
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = [NSString stringWithFormat:@"%@ event time!.",event.description];
    localNotif.alertAction = @"View Details";
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;
    
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:event.description forKey:@"event"];
    localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];

}

- (void)presentLocalNotificationNow:(UILocalNotification *)notification
{
    NSLog(@"presenting local notificaiton now!");
}

+ (void)handleNotification:(NSDictionary*)userInfo forMainView:(MainViewController*)viewController
{
    
    
    if( [userInfo[@"notification_type"] isEqualToString:@"chat"]){
        NSMutableDictionary *eventNotifications = viewController.eventNotifications;
        //test alert to see if we can parse the dictionary in this fashion
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"in user handling data!"
                                                        message:userInfo[@"aps"][@"alert"]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        if( [eventNotifications objectForKey:@""]){
            
        }
        
        

        
        
    }
}


@end
