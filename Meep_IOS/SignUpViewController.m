//
//  SignUpViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/7/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *retypePasswordField;
@property (weak, nonatomic) IBOutlet UILabel *registerMessage;
@property (nonatomic) NSString *errorMessage;
@end

@implementation SignUpViewController

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
    if (![_usernameField.text isEqualToString:@""] && ![_passwordField.text isEqualToString:@""] && ![_retypePasswordField.text isEqualToString:@""]) {
        if([_passwordField.text isEqualToString:_retypePasswordField.text]){
            return YES;
        }
        else{
            _errorMessage = @"Passwords do not match";
        }
        
    }
    else{
        _errorMessage = @"Username and Password are required to log in.";
    }
    
    return NO;
}

- (IBAction)registerUser:(id)sender {
    if ([self validateInputs]) {
        NSLog(@"trying to login");
        _authClient = [[DjangoAuthClient alloc] initWithURL:@"http://50.112.180.63:8000/acct/register"
                                                forUsername:_usernameField.text
                                                   andEmail:_emailField.text
                                                andPassword:_passwordField.text];
        _authClient.delegate = self;
        [_authClient registerUser];
    }
    else {
        _registerMessage.text = _errorMessage;
    }
}

- (void)loginSuccessful:(DjangoAuthLoginResultObject *)result {
    
    NSLog(@"login successful");
    [_delegate loadMainViewAfterAuthentication];
}

- (void)loginFailed:(DjangoAuthLoginResultObject *)result {
    
    if (result.loginFailureReason == kDjangoAuthClientLoginFailureInactiveAccount) {
        _registerMessage.text = @"Login failed: Your account is inactive.";
        // NSLog(@"Login failed: Your account is inactive.");
    }
    else if (result.loginFailureReason == kDjangoAuthClientLoginFailureInvalidCredentials) {
        _registerMessage.text = @"Login failed: Please check your username and password.";
        //NSLog(@"Login failed: Please check your username and password.");
    }else{
        NSLog(@"Unknown reason for login failure");
        _registerMessage.text = @"Login failed: Please check your username and password.";
        //[_delegate loadMainViewAfterAuthentication];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
