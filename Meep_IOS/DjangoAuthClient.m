//
//  DjangoAuthClient.m
//  Django-iOS-Auth-Example
//
//  Created by Ben Boyd on 1/3/13.
//  Copyright (c) 2013 Ben Boyd. All rights reserved.
//

#import "DjangoAuthClient.h"
#import "DjangoAuthLoginResultObject.h"

NSString * const DjangoAuthClientDidLoginSuccessfully = @"DjangoAuthClientDidLoginSuccessfully";
NSString * const DjangoAuthClientDidFailToLogin = @"DjangoAuthClientDidFailToLogin";
NSString * const DjangoAuthClientDidFailToCreateConnectionToAuthURL = @"DjangoAuthClientDidFailToCreateConnectionToAuthURL";

NSString *const kDjangoAuthClientLoginFailureInvalidCredentials = @"kDjangoAuthClientLoginFailureInvalidCredentials";
NSString *const kDjangoAuthClientLoginFailureInactiveAccount = @"kDjangoAuthClientLoginFailureInactiveAccount";

@interface DjangoAuthClient()

// Private properties
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *email;
@property (nonatomic) BOOL serverDidRespond;
@property (nonatomic) BOOL serverDidAuthenticate;
@end

@implementation DjangoAuthClient

@synthesize enc_username;
@synthesize enc_password;
@synthesize enc_email;
@synthesize enc_serverDidRespond;
@synthesize enc_serverDidAuthenticate;

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.enc_username = [decoder decodeObjectForKey:@"username"];
        self.enc_password = [decoder decodeObjectForKey:@"password"];
        self.enc_email = [decoder decodeObjectForKey:@"email"];
        self.enc_serverDidRespond = [decoder decodeBoolForKey:@"serverDidRespond"];
        self.enc_serverDidAuthenticate = [decoder decodeBoolForKey:@"serverDidAuthenticate"];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:enc_username forKey:@"username"];
    [encoder encodeObject:enc_password forKey:@"password"];
    [encoder encodeObject:enc_email forKey:@"email"];
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

}

#pragma mark - NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
    NSError *error;
    NSDictionary * jsonResponse = [NSJSONSerialization JSONObjectWithData:self.responseData options:0 error:&error];
    NSLog(@"jsonREsponse: %@", jsonResponse);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    DjangoAuthLoginResultObject *resultObject = [DjangoAuthLoginResultObject loginResultObjectFromResponse:response];
    
    NSLog(@"status code is %i", resultObject.statusCode);
    
    if (resultObject.statusCode == 200) {
        // We're logged in and good to go
        NSLog(@"initial login attempt!!");
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
        }
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
        
        // Check to see if we've already made an attempt to log in and failed
        /*if ([[resultObject.responseHeaders objectForKey:@"Auth-Response"] isEqualToString:@"Login failed"]) {
            resultObject.loginFailureReason = kDjangoAuthClientLoginFailureInvalidCredentials;
            if ([_delegate respondsToSelector:@selector(loginFailed:)]) {
                [_delegate loginFailed:resultObject];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:DjangoAuthClientDidFailToLogin object:resultObject];
        }
        else {
            NSLog(@"else initial login attempt!!");
            // Initial login attempt
            NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:resultObject.responseHeaders forURL:self.requestURL];
            
            // Django defaults to CSRF protection, so we need to get the token to send back in the request
            NSHTTPCookie *csrfCookie;
            for (NSHTTPCookie *cookie in cookies) {
                if ([cookie.name isEqualToString:@"csrftoken"]) {
                    csrfCookie = cookie;
                }
            }
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.requestURL];
            [request setHTTPMethod:@"POST"];
            //[request setValue:@"multipart/form-data; boundary=0xKhTmLbOuNdArY" forHTTPHeaderField:@"Content-Type"];
            NSString *authString = [NSString stringWithFormat:@"username=%@;password=%@;csrfmiddlewaretoken=%@;", _username, _password, csrfCookie.value, nil];
            [request setHTTPBody:[authString dataUsingEncoding:NSUTF8StringEncoding]];

            [self makeLoginRequest:request];
        }*/
    }
    else if (resultObject.statusCode == 403) {
        // Login failed because the user's account is inactive
        resultObject.loginFailureReason = kDjangoAuthClientLoginFailureInactiveAccount;
        if ([_delegate respondsToSelector:@selector(loginFailed:)]) {
            [_delegate loginFailed:resultObject];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:DjangoAuthClientDidFailToLogin object:resultObject];
    }
    /*delete this code later*/
    else{
        NSLog(@"no valid response code");
        [_delegate loginFailed:nil];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"response data string %@", [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding]);
    [self.responseData setLength:0];
}


@end
