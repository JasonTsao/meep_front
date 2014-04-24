//
//  MEPAppDelegate.m
//  MeepIOS
//
//  Created by Ryan Sharp on 4/13/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "MEPAppDelegate.h"
#import "MEEPhttp.h"
#import "MainViewController.h"
#import "AccountSettings.h"

@implementation MEPAppDelegate


- (void)getAccountSettings
{
    NSString * requestURL = [NSString stringWithFormat:@"%@settings/get",[MEEPhttp accountURL]];
    NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"user",nil];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    _data = [[NSMutableData alloc] init]; // _data being an ivar
}
-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    [_data appendData:data];
}
-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    // Handle the error properly
    NSLog(@"Call Failed");
}
-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    [self handleData]; // Deal with the data
}


-(void)handleData{
    NSError* error;
    NSDictionary * jsonResponse = [NSJSONSerialization JSONObjectWithData:_data options:0 error:&error];
    NSDictionary * settings_data = jsonResponse[@"settings"];
    BOOL privacy_allowed;
    BOOL search_allowed;
    BOOL reminders_allowed;
    BOOL vibrate_on_notification;
    @try{
        if ([settings_data[@"private"] boolValue]){
            privacy_allowed = YES;
        }
        else{
            privacy_allowed = NO;
        }
        if ([settings_data[@"private"] boolValue]){
            search_allowed = YES;
        }
        else{
            search_allowed = NO;
        }
        if ([settings_data[@"searchable"] boolValue]){
            reminders_allowed = YES;
        }
        else{
            reminders_allowed = NO;
        }
        if ([settings_data[@"vibrate_on_notification"] boolValue]){
            vibrate_on_notification = YES;
        }
        else{
            vibrate_on_notification = NO;
        }
        privacy_allowed = [settings_data[@"private"] boolValue];
        search_allowed = [settings_data[@"searchable"] boolValue];
        reminders_allowed = [settings_data[@"reminder_on"] boolValue];
        vibrate_on_notification = [settings_data[@"vibrate_on_notification"] boolValue];
        
        _account_settings = [[AccountSettings alloc]initWithPrivate: privacy_allowed withSearchable:search_allowed withReminders:reminders_allowed withVibrateOnNotification:vibrate_on_notification];
    }
    @catch(NSString *){
        NSLog(@"Not getting account settings");
    }
    
    //NSArray * upcoming = jsonResponse[@"upcoming_events"];
    //NSArray * owned = jsonResponse[@"owned_upcoming_events"];
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    [self getAccountSettings];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
