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
#import "DjangoAuthClient.h"


@interface MEPAppDelegate()
@property(nonatomic, strong) DjangoAuthClient * authClient;
@end

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
    
    if( [jsonResponse objectForKey:@"settings"]){
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
            
            AccountSettings *account_settings = [[AccountSettings alloc]initWithPrivate: privacy_allowed withSearchable:search_allowed withReminders:reminders_allowed withVibrateOnNotification:vibrate_on_notification];
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:account_settings];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"account_settings"];
        }
        @catch(NSString *){
            NSLog(@"Not getting account settings");
        }
    }
    else{
        //HANDLE RETRYING TO GET DEVICE TOKEN
    }
    
    
    //NSArray * upcoming = jsonResponse[@"upcoming_events"];
    //NSArray * owned = jsonResponse[@"owned_upcoming_events"];
}

- (void) logout:(AccountViewController *)controller
{
    NSLog(@"logging out in app delegate");
}

- (void) loadMainViewAfterAuthentication
{
    
    NSLog(@"loading main view after authentication");
    [_authenticationViewController dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"main view controller %@", self.viewController);
    
    //self.window.rootViewController = self.viewController;
    //[self.window makeKeyAndVisible];
    self.viewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    NSData *settingsData = [[NSUserDefaults standardUserDefaults] objectForKey:@"account_settings"];
    AccountSettings *user_account_settings = [NSKeyedUnarchiver unarchiveObjectWithData:settingsData];
    if (!user_account_settings){
        NSLog(@"No user account settings");
        NSLog(@"%@", user_account_settings);
        [self getAccountSettings];
    }
    else{
    }
}

/*-(void) sessionStateChanged:(FBSession*)session state:(FBSessionState*)sessionState error:(NSError *)ns_error
{
    NSLog(@"session state changed");
}*/
- (void) userLoggedIn
{
    NSLog(@"user logged into fb");
}

-(void) userLoggedOut
{
    NSLog(@"user logged out of fb");
}

-(void) showMessage:(NSString*)alertText withTitle:(NSString*)alertTitle{
    NSLog(@"alert text:%@", alertText);
    NSLog(@"alert title:%@", alertTitle);
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    NSLog(@"application openURL");
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    //return [[FBSession activeSession] handleOpenURL:url];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"application did become active");
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    [FBAppCall handleDidBecomeActive];
}


// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        // Show the user the logged-in UI
        [self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // Here we will handle all other errors with a generic error message.
                // We recommend you check our Handling Errors guide for more information
                // https://developers.facebook.com/docs/ios/errors/
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}

- (void)registerForRemoteNotificationTypes:(UIRemoteNotificationType)types{
    NSLog(@"registering for remote notification types!");
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"failed to register for remote notifications!");
    NSLog(@"error: %@", error);
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"Got Device token!: %@", deviceToken);
    const char* data = [deviceToken bytes];
    NSMutableString* token = [NSMutableString string];
    
    for (int i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    
    NSString * requestURL = [NSString stringWithFormat:@"%@device/?token=%@&service=1",[MEEPhttp iosNotificationsURL], token];
    NSLog(@"request url : %@", requestURL);
    NSString *service_id = [NSString stringWithFormat:@"%i", 1 ];
    NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:service_id,@"service",token, @"token",nil];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"did receieve remote notification!"
                                                    message:[NSString stringWithFormat:@"%@", userInfo]
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    NSLog(@"did recieve remote notification, application state: %@!", application.applicationState);
    NSLog(@"user info dict: %@", userInfo);
    if( application.applicationState == UIApplicationStateInactive){
        NSLog(@"user is not in the application when it got the notification");
    }
    else if( application.applicationState == UIApplicationStateActive){
        NSLog(@"application is already open when user got notification");
    }
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"did receive local notification!");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"did receieve local notification!"
                                                    message:[NSString stringWithFormat:@"%@", notification]
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    UILocalNotification *localNotif =
    [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (localNotif) {
        NSLog(@"got local notificaiton!");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"local notification"
                                                        message:[NSString stringWithFormat:@"%@", localNotif]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        NSLog(@"%@", localNotif);
        NSString *itemName = [localNotif.userInfo objectForKey:@"event"];
        application.applicationIconBadgeNumber = localNotif.applicationIconBadgeNumber-1;
    }
    if (remoteNotif){
        NSLog(@"got a remote notification!");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"remote notification!"
                                                        message:[NSString stringWithFormat:@"%@", remoteNotif]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        NSLog(@"%@", remoteNotif);
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    [FBLoginView class];
    [FBProfilePictureView class];

    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    
    NSData *authenticated = [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_client"];
    _authClient = [NSKeyedUnarchiver unarchiveObjectWithData:authenticated];
    
    if(_authClient == nil){
        NSLog(@"no auth client");
        _authenticationViewController  = (AuthenticationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"authentication"];
        _authenticationViewController.delegate = self;
        UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_authenticationViewController];
        self.window.rootViewController = navigation;
        [self.window makeKeyAndVisible];
    }else{
        if (_authClient.enc_serverDidAuthenticate){
            [self loadMainViewAfterAuthentication];
        }
        else{
            NSLog(@"user is not authenticated");
            _authenticationViewController  = (AuthenticationViewController *)[storyboard instantiateViewControllerWithIdentifier:@"authentication"];
            _authenticationViewController.delegate = self;
            UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_authenticationViewController];
            self.window.rootViewController = navigation;
            [self.window makeKeyAndVisible];
        }
    }
    
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        NSLog(@"there already is active fb session");
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
    }
    
    //CANCEL ALL NOTIFICATIONS. MUST GET RID OF THIS LATER!
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    //make call to APN Services
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"low memory!!");
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
    NSLog(@"application did enter background");
    
    /*dispatch_async(dispatch_get_main_queue(), ^{
        while ([application backgroundTimeRemaining] > 1.0) {
            NSLog(@"making local notification in backgorund");
            UILocalNotification *localNotif = [[UILocalNotification alloc] init];
            localNotif.alertAction = NSLocalizedString(@"Read Message", nil);
            localNotif.soundName = @"alarmsound.caf";
            localNotif.applicationIconBadgeNumber = 1;
            [application presentLocalNotificationNow:localNotif];
        }
    });*/
   /*
    SOME EXAMPLE CODE ON HOW TO HANDLE PUSH NOTIFICATIONS IN THE BACKGROUND
    NSLog(@"Application entered background state.");
    // bgTask is a property of the class
    NSAssert(self.bgTask == UIInvalidBackgroundTask, nil);
    
    bgTask = [application beginBackgroundTaskWithExpirationHandler: ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [application endBackgroundTask:self.bgTask];
            self.bgTask = UIInvalidBackgroundTask;
        });
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        while ([application backgroundTimeRemaining] > 1.0) {
            NSString *friend = [self checkForIncomingChat];
            if (friend) {
                UILocalNotification *localNotif = [[UILocalNotification alloc] init];
                if (localNotif) {
                    localNotif.alertBody = [NSString stringWithFormat:
                                            NSLocalizedString(@"%@ has a message for you.", nil), friend];
                    localNotif.alertAction = NSLocalizedString(@"Read Message", nil);
                    localNotif.soundName = @"alarmsound.caf";
                    localNotif.applicationIconBadgeNumber = 1;
                    [application presentLocalNotificationNow:localNotif];
                    [localNotif release];
                    friend = nil;
                    break;
                }
            }
        }
        [application endBackgroundTask:self.bgTask];
        self.bgTask = UIInvalidBackgroundTask;
    });*/
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

/*- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}
*/
- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
