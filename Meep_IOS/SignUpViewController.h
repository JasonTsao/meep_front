//
//  SignUpViewController.h
//  Meep_IOS
//
//  Created by Jason Tsao on 5/7/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DjangoAuthClient.h"
#import "DjangoAuthLoginResultObject.h"

@class SignUpViewController;

@protocol SignUpViewControllerDelegate
- (void) loadMainViewAfterAuthentication;
@end

@interface SignUpViewController : UIViewController<DjangoAuthClientDelegate>

@property (nonatomic, strong) DjangoAuthClient *authClient;
@property (nonatomic, assign) id<SignUpViewControllerDelegate> delegate;
@end
