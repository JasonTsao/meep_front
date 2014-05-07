//
//  AuthenticationViewController.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/5/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DjangoAuthClient.h"
#import "SignInViewController.h"

//@protocol AuthenticationViewControllerDelegate <NSObject>
@class AuthenticationViewController;

@protocol AuthenticationViewControllerDelegate
- (void) loadMainViewAfterAuthentication;
@end

@interface AuthenticationViewController : UIViewController<DjangoAuthClientDelegate>
@property (weak, nonatomic) IBOutlet UITextField *username;

@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UILabel *loginMessage;

@property (nonatomic, strong) DjangoAuthClient *authClient;
@property (nonatomic, assign) id<AuthenticationViewControllerDelegate> delegate;
-(IBAction) logIn:(id) sender;
@end
