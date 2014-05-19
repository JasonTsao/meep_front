//
//  DjangoAuthClient.m
//  Django-iOS-Auth-Example
//
//  Created by Ben Boyd on 1/3/13.
//  Copyright (c) 2013 Ben Boyd. All rights reserved.
//

#import "DjangoAuthClient.h"


NSString * const DjangoAuthClientDidLoginSuccessfully = @"DjangoAuthClientDidLoginSuccessfully";
NSString * const DjangoAuthClientDidFailToLogin = @"DjangoAuthClientDidFailToLogin";
NSString * const DjangoAuthClientDidFailToCreateConnectionToAuthURL = @"DjangoAuthClientDidFailToCreateConnectionToAuthURL";

NSString *const kDjangoAuthClientLoginFailureInvalidCredentials = @"kDjangoAuthClientLoginFailureInvalidCredentials";
NSString *const kDjangoAuthClientLoginFailureInactiveAccount = @"kDjangoAuthClientLoginFailureInactiveAccount";

@interface DjangoAuthClient()

// Private properties
@property (nonatomic, strong) NSString *userid;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *email;
@property (nonatomic) BOOL serverDidRespond;
@property (nonatomic) BOOL serverDidAuthenticate;
@end

@implementation DjangoAuthClient
@synthesize enc_userid;
@synthesize enc_username;
@synthesize enc_password;
@synthesize enc_email;
@synthesize enc_serverDidRespond;
@synthesize enc_serverDidAuthenticate;
@synthesize enc_profile_pic;

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.enc_userid = [decoder decodeObjectForKey:@"userid"];
        self.enc_username = [decoder decodeObjectForKey:@"username"];
        self.enc_password = [decoder decodeObjectForKey:@"password"];
        self.enc_email = [decoder decodeObjectForKey:@"email"];
        self.enc_profile_pic = [decoder decodeObjectForKey:@"profile_pic"];
        self.enc_serverDidRespond = [decoder decodeBoolForKey:@"serverDidRespond"];
        self.enc_serverDidAuthenticate = [decoder decodeBoolForKey:@"serverDidAuthenticate"];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:enc_userid forKey:@"userid"];
    [encoder encodeObject:enc_username forKey:@"username"];
    [encoder encodeObject:enc_password forKey:@"password"];
    [encoder encodeObject:enc_email forKey:@"email"];
    [encoder encodeObject:enc_profile_pic forKey:@"profile_pic"];
    [encoder encodeBool:enc_serverDidRespond forKey:@"reminders"];
    [encoder encodeBool:enc_serverDidAuthenticate forKey:@"serverDidAuthenticate"];
}

- (id)initWithURL:(NSString *)loginURL forUsername:(NSString *)username andPassword:(NSString *)password {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _username = username;
    _password = password;
    _requestURL = [NSURL URLWithString:loginURL];
    _responseData = [[NSMutableData alloc] initWithCapacity:512];
    _serverDidRespond = NO;
    _serverDidAuthenticate = NO;
    
    _loginSucceeded = NO;

    self.enc_serverDidAuthenticate = NO;
    self.enc_username = username;
    
    return self;
}

- (id)initWithURL:(NSString *)loginURL forUsername:(NSString *)username andEmail:(NSString *)email andPassword:(NSString *)password {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _username = username;
    _password = password;
    _email = email;
    _requestURL = [NSURL URLWithString:loginURL];
    _responseData = [[NSMutableData alloc] initWithCapacity:512];
    _serverDidRespond = NO;
    _serverDidAuthenticate = NO;
    
    _loginSucceeded = NO;
    self.enc_serverDidAuthenticate = NO;
    self.enc_username = username;
    
    return self;
}

- (void)login {
    //[self makeLoginRequest:nil];
    NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:_username, @"username", _password, @"password", nil];
    NSLog(@"login request url: %@", _requestURL);
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:[_requestURL absoluteString] postDictionary:postDict];
    [self makeLoginRequest:request];
}

- (void)registerUser {
    //[self makeLoginRequest:nil];
    NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:_username, @"username", _password, @"password1", _email, @"email",nil];
    NSLog(@"register request url: %@", _requestURL);
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:[_requestURL absoluteString] postDictionary:postDict];
    [self makeLoginRequest:request];
}

-(void)logout{
    
}

- (void)makeLoginRequest:(NSMutableURLRequest *)request {
    if (request == nil) {
        request = [NSMutableURLRequest requestWithURL:_requestURL];
    }
    NSLog(@"make login request request method: %@", request.HTTPMethod);
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (!connection) {
        NSLog(@"no connection!");
        [[NSNotificationCenter defaultCenter] postNotificationName:DjangoAuthClientDidFailToCreateConnectionToAuthURL object:self];
    }
    [connection start];
}

#pragma mark - NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    DjangoAuthLoginResultObject *resultObject = [DjangoAuthLoginResultObject loginResultObjectFromResponse:response];
    
    if (resultObject.statusCode == 200) {
        // We're logged in and good to go
        _loginSucceeded = YES;
        _djangoResultObject = resultObject;
        
        /*NSLog(@"initial login attempt!!");
        // Initial login attempt
        NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:resultObject.responseHeaders forURL:self.requestURL];
        // Django defaults to CSRF protection, so we need to get the token to send back in the request
        NSHTTPCookie *csrfCookie;
        for (NSHTTPCookie *cookie in cookies) {
            if ([cookie.name isEqualToString:@"csrftoken"]) {
                csrfCookie = cookie;
            }
        }
        [connection cancel];
        if ([_delegate respondsToSelector:@selector(loginSuccessful:)]) {
            self.enc_serverDidAuthenticate = YES;
            [_delegate loginSuccessful:resultObject];
        }*/
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DjangoAuthClientDidLoginSuccessfully object:resultObject];
    }
    else if (resultObject.statusCode == 401) {
        NSLog(@"we're not authorized");
        // We're not authorized, so cancel the connection since we need to send the login POST request
        [connection cancel];
        
        resultObject.loginFailureReason = kDjangoAuthClientLoginFailureInvalidCredentials;
        if ([_delegate respondsToSelector:@selector(loginFailed:)]) {
            [_delegate loginFailed:resultObject];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:DjangoAuthClientDidFailToLogin object:resultObject];
        
    }
    else if (resultObject.statusCode == 403) {
        // Login failed because the user's account is inactive
        resultObject.loginFailureReason = kDjangoAuthClientLoginFailureInactiveAccount;
        if ([_delegate respondsToSelector:@selector(loginFailed:)]) {
            [_delegate loginFailed:resultObject];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:DjangoAuthClientDidFailToLogin object:resultObject];
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self handleData:connection];
}

- (void)handleData:(NSURLConnection *)connection
{
    NSLog(@"initial login attempt!!");
    // Initial login attempt
    /*NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:resultObject.responseHeaders forURL:self.requestURL];
    // Django defaults to CSRF protection, so we need to get the token to send back in the request
    NSHTTPCookie *csrfCookie;
    for (NSHTTPCookie *cookie in cookies) {
        if ([cookie.name isEqualToString:@"csrftoken"]) {
            csrfCookie = cookie;
        }
    }*/
    [connection cancel];
    if ([_delegate respondsToSelector:@selector(loginSuccessful:)]) {
        NSError *error;
        NSDictionary * jsonResponse = [NSJSONSerialization JSONObjectWithData:self.responseData options:0 error:&error];
        
        if([jsonResponse objectForKey:@"userid"]){
            self.enc_userid = jsonResponse[@"userid"];
        }
        
        self.enc_serverDidAuthenticate = YES;
        [_delegate loginSuccessful:_djangoResultObject];
        [self.responseData setLength:0];
    }
}


@end
