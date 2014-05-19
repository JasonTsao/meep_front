//
//  AuthenticationViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/5/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "AuthenticationViewController.h"
#import "DjangoAuthLoginResultObject.h"
#import "CenterViewController.h"

@interface AuthenticationViewController ()
@property (nonatomic, strong) CenterViewController *centerViewController;
@end

@implementation AuthenticationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing: YES];
}

- (BOOL)validateInputs {
    // Ensure that something has been entered in the username and password fields
    if (![_username.text isEqualToString:@""] && ![_password.text isEqualToString:@""]) {
        return YES;
    }
    
    return NO;
}
- (IBAction)login:(id)sender {
    if ([self validateInputs]) {
        NSLog(@"trying to login");
        _authClient = [[DjangoAuthClient alloc] initWithURL:@"http://50.112.180.63:8000/acct/login"
                                                forUsername:_username.text
                                                andPassword:_password.text];
        _authClient.delegate = self;
        [_authClient login];
    }
    else {
        _loginMessage.text = @"Username and Password are required to log in.";
    }
}



#pragma mark - DjangoAuthClientDelegate methods

- (void)loginSuccessful:(DjangoAuthLoginResultObject *)result {

    NSLog(@"login successful");
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_authClient];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"auth_client"];
    [NSUserDefaults resetStandardUserDefaults];
    [_delegate loadMainViewAfterAuthentication];
}

- (void)loginFailed:(DjangoAuthLoginResultObject *)result {

    if (result.loginFailureReason == kDjangoAuthClientLoginFailureInactiveAccount) {
        _loginMessage.text = @"Login failed: Your account is inactive.";
       // NSLog(@"Login failed: Your account is inactive.");
    }
    else if (result.loginFailureReason == kDjangoAuthClientLoginFailureInvalidCredentials) {
        _loginMessage.text = @"Login failed: Please check your username and password.";
        //NSLog(@"Login failed: Please check your username and password.");
    }else{
        NSLog(@"Unknown reason for login failure");
        _loginMessage.text = @"Login failed: Please check your username and password.";
        //[_delegate loadMainViewAfterAuthentication];
    }

}




- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Extra boner time!!";
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    SignUpViewController * signup = [segue destinationViewController];
    [signup setDelegate:self.delegate];
}


@end
