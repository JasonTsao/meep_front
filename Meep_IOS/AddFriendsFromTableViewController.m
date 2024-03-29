//
//  AddFromContactsTableViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/4/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//
#import <FacebookSDK/FacebookSDK.h>
#import "AddFriendsFromTableViewController.h"
#import "MEPAppDelegate.h"
#import "Search.h"

@interface AddFriendsFromTableViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplay;

@end

@implementation AddFriendsFromTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)getFriendsList
{
    NSString * requestURL = [NSString stringWithFormat:@"%@friends/list",[MEEPhttp accountURL]];
    NSLog(@"request url : %@", requestURL);
    NSDictionary * postDict = [[NSDictionary alloc] init];
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
    NSLog(@"error: %@", error);
}
-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    [self handleData]; // Deal with the data
}

-(void)getFriendsToInviteAndRegisteredUsers:(NSMutableArray*)nonFriends
{
    NSString * requestURL = [NSString stringWithFormat:@"%@check_if_phone_users_registered",[MEEPhttp accountURL]];
    NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:_phoneNonFriendUsersNumbers,@"phone_numbers", nil];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}


-(void)handleData{
    NSError* nserror;
    NSDictionary * jsonResponse = [NSJSONSerialization JSONObjectWithData:_data options:0 error:&nserror];
    if ([_viewTitle isEqualToString:@"From Contacts"]){
        if ([jsonResponse objectForKey:@"registered_users"] != nil){
            _phoneRegisteredUsers = [[NSMutableArray alloc] init];
            _phoneNonRegisteredUsers = [[NSMutableArray alloc] init];
            NSMutableArray *registeredUsers = jsonResponse[@"registered_users"];
            NSMutableArray *nonregisteredUsers = jsonResponse[@"nonregistered_users"];
            for ( int i = 0; i < [registeredUsers count]; i++){
                NSInteger index = [_phoneNonFriendUsersNumbers indexOfObject:registeredUsers[i]];
                [_phoneRegisteredUsers addObject:_phoneNonFriendUsers[index]];
            }
            for ( int i = 0; i < [nonregisteredUsers count]; i++){
                NSInteger index = [_phoneNonFriendUsersNumbers indexOfObject:nonregisteredUsers[i]];
                [_phoneNonRegisteredUsers addObject:_phoneNonFriendUsers[index]];
            }
            [self.tableView reloadData];
        }
        else if([jsonResponse objectForKey:@"friends"] != nil){
            // initialize variables for class to pass around user contact data
            _phoneNonFriendUsersNumbers = [[NSMutableArray alloc]init];
            _phoneNonFriendUsers = [[NSMutableArray alloc]init];
            _phoneContacts = [[NSMutableArray alloc]init];
            _phoneContactNumbers = [[NSMutableArray alloc]init];

            // Initialize variables for getting access to a users contact list
            CFErrorRef error = NULL;
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, (CFErrorRef *)&error);
            CFArrayRef allPeople;
            CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
            
            __block BOOL accessGranted = NO;
            if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
                dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                
                ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                    accessGranted = granted;
                    dispatch_semaphore_signal(sema);
                });
                
                dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            }
            else { // we're on iOS 5 or older
                accessGranted = YES;
            }
            
            // If we have access to their contacts
            if(accessGranted){
                allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
                for ( int i = 0; i < nPeople; i++ )
                {
                    ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
                    NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
                    NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
                    if(!firstName){
                        firstName = @"";
                    }
                    if(!lastName){
                        lastName = @"";
                    }
                    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
                    NSString *phoneNumber;
                    for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
                        NSString *numberFromPhone = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                        NSCharacterSet *onlyAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
                        phoneNumber = [[numberFromPhone componentsSeparatedByCharactersInSet:onlyAllowedChars] componentsJoinedByString:@""];
                        
                        if([phoneNumber length] == 11 && [[phoneNumber substringToIndex:1] isEqualToString:@"1"] ){
                            NSRange phoneNumberRange = NSMakeRange(1, phoneNumber.length - 1);
                            phoneNumber = [phoneNumber substringWithRange:phoneNumberRange];
                        }
                    }
                    NSDictionary *user_dictionary = [[NSDictionary alloc]initWithObjectsAndKeys:lastName, @"last_name", firstName, @"first_name", phoneNumber, @"phone_number", nil];
                    [_phoneContacts addObject:user_dictionary];
                    [_phoneContactNumbers addObject:phoneNumber];
                }
                
                CFRelease(addressBook);
                NSArray * friends = jsonResponse[@"friends"];
                _friendsList = [[NSMutableArray alloc]init];
                
                for( int i = 0; i< [friends count]; i++){
                    NSDictionary * new_friend_dict = [NSJSONSerialization JSONObjectWithData: [friends[i] dataUsingEncoding:NSUTF8StringEncoding]
                                                                                     options: NSJSONReadingMutableContainers
                                                                                       error: &nserror];
                    [_friendsList addObject:new_friend_dict[@"phone_number"]];
                }
                for (int k = 0; k < [_phoneContacts count]; k++)
                {
                    if (![_friendsList containsObject:_phoneContactNumbers[k]]){
                        [_phoneNonFriendUsers addObject:_phoneContacts[k]];
                        [_phoneNonFriendUsersNumbers addObject:_phoneContactNumbers[k]];
                    }
                }
                [self getFriendsToInviteAndRegisteredUsers:_phoneNonFriendUsers];
            }
        }
    }
    
    else if ([_viewTitle isEqualToString:@"From Facebook"]){
        if([jsonResponse objectForKey:@"all_facebook_friends"] != nil){
            NSArray *all_fb_friends = jsonResponse[@"all_facebook_friends"];
            for (int i = 0; i < [all_fb_friends count]; i++){
                NSLog(@"fb friend: %@", all_fb_friends[i]);
                NSDictionary *fb_friend_dict = all_fb_friends[i];
                
                NSDictionary *fb_friend = [[NSDictionary alloc] initWithObjectsAndKeys:all_fb_friends[i][@"name"], @"name", all_fb_friends[i][@"id"], @"id", nil];
                [_allFacebookFriends addObject: fb_friend];
            }
            NSLog(@"all_fb_friends array:%@", _allFacebookFriends);
            [self.tableView reloadData];
        }
    }
    
    else if ([_viewTitle isEqualToString:@"From Everyone"]){
        
        if([jsonResponse objectForKey:@"friends"] != nil){
            NSArray * friends = jsonResponse[@"friends"];
            _friendsList = [[NSMutableArray alloc]init];
            
            for( int i = 0; i< [friends count]; i++){
                NSDictionary * new_friend_dict = [NSJSONSerialization JSONObjectWithData: [friends[i] dataUsingEncoding:NSUTF8StringEncoding]
                                                                                 options: NSJSONReadingMutableContainers
                                                                                   error: &nserror];
                NSString *friend_account_id = [NSString stringWithFormat:@"%i",[new_friend_dict[@"account_id"] integerValue]];
                [_friendsList addObject:friend_account_id];
            }
        }
        else{
            NSMutableArray *searchUsers = jsonResponse[@"users"];
            _searchResultFriendsList = [[NSMutableArray alloc] init];
            for(int i = 0; i < [searchUsers count]; i++){
                Friend *newFriend = [[Friend alloc] init];
                newFriend.account_id = [searchUsers[i][@"id"] integerValue];
                newFriend.name = searchUsers[i][@"user_name"];
                [_searchResultFriendsList addObject:newFriend];
                
            }
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    }
    
}

/*- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"cowabunga!!");
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"shell shock!!");
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    NSLog(@"over 9000!!");
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSLog(@"search string: %@", searchString);
    return YES;
}*/


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _searchResultRegistered = [[NSMutableArray alloc] init];
    _searchResultNonRegistered = [[NSMutableArray alloc] init];

    if([_viewTitle isEqualToString:@"From Contacts"]){
        for( int i = 0; i < [_phoneRegisteredUsers count]; i++){
            if([Search string:_phoneRegisteredUsers[i][@"first_name"] hasPrefix:searchText caseInsensitive:YES] || [Search string:_phoneRegisteredUsers[i][@"last_name"] hasPrefix:searchText caseInsensitive:YES] ){
                [_searchResultRegistered addObject:_phoneRegisteredUsers[i]];
            }
        }
        for( int i = 0; i < [_phoneNonRegisteredUsers count]; i++){
            if([Search string:_phoneNonRegisteredUsers[i][@"first_name"] hasPrefix:searchText caseInsensitive:YES] || [Search string:_phoneNonRegisteredUsers[i][@"last_name"] hasPrefix:searchText caseInsensitive:YES] ){
                [_searchResultNonRegistered addObject:_phoneNonRegisteredUsers[i]];
            }
        }

        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    else if([_viewTitle isEqualToString:@"From Everyone"]){
        NSString * requestURL = [NSString stringWithFormat:@"%@search/username",[MEEPhttp accountURL]];
        NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys: searchText, @"search_field" ,nil];
        NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
        NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [conn start];
    }
    
}
-(void) syncFacebookUser{
    NSString * accessToken = [[FBSession activeSession] accessToken];
    
    NSString * requestURL = [NSString stringWithFormat:@"%@syncFacebookUser/%@",[MEEPhttp accountURL], accessToken];
    //NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys: accessToken, @"access_token" ,nil];
    NSDictionary * postDict = [[NSDictionary alloc] init];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

-(void) syncFacebookFriends:(id)sender{
    NSString * requestURL = [NSString stringWithFormat:@"%@syncFacebookFriends",[MEEPhttp accountURL]];
    //NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys: accessToken, @"access_token" ,nil];
    NSDictionary * postDict = [[NSDictionary alloc] init];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

-(void) getAllFacebookFriends
{
    NSString * requestURL = [NSString stringWithFormat:@"%@friends/facebook/all",[MEEPhttp accountURL]];
    //NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys: accessToken, @"access_token" ,nil];
    NSDictionary * postDict = [[NSDictionary alloc] init];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}


// WILL ONLY RETURN FB USERS WHO ARE FRIENDS WHO HAVE SIGNED IN USING THIS APP
-(void) getFacebookFriendsWithAppList{
    [FBRequestConnection startWithGraphPath:@"me/friends?limit=500"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  // Success! Include your code to handle the results here
                                  NSArray *results = result;
                                  NSLog(@"results: %@", results);
                                  for (int i = 0; i < [results count]; i++){
                                      NSLog(@"friend: %@", results[i]);
                                  }
                              } else {
                                  // An error occurred, we need to handle the error
                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"error %@", error.description);
                              }
                          }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _viewTitle;
    _buttonTagDictionary = [[NSMutableDictionary alloc] init];
    _buttonTagNumber = 0;
    _searchButtonTagDictionary = [[NSMutableDictionary alloc] init];
    _searchButtonTagNumber = 0;
    _allFacebookFriends = [[NSMutableArray alloc] init];
    
    _searchResultFriendsList = [[NSMutableArray alloc] init];
    
    [self getFriendsList];

    if([_viewTitle isEqualToString:@"From Facebook"]){
        
        UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Sync All" style:UIBarButtonItemStyleBordered target:self action:@selector( syncFacebookFriends:)];
        
        self.navigationItem.rightBarButtonItem = customBarItem;
        
        if (FBSession.activeSession.state == FBSessionStateOpen
            || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
            NSLog(@"FBSessionStateOpen || FBSessionStateOpenTokenExtended");
            // Close the session and remove the access token from the cache
            // The session state handler (in the app delegate) will be called automatically
            
            //[FBSession.activeSession closeAndClearTokenInformation];
            //[self syncFacebookUser];
            [self getAllFacebookFriends];
            // If the session state is not any of the two "open" states when the button is clicked
        } else {
            // Open a session showing the user the login UI
            // You must ALWAYS ask for public_profile permissions when opening a session
            NSLog(@"about to open active session with read permissions");
            [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"user_friends", @"read_friendlists", @"email", @"user_birthday"]
                                               allowLoginUI:YES
                                          completionHandler:
             ^(FBSession *session, FBSessionState state, NSError *error) {
                 // Retrieve the app delegate
                 MEPAppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
                 // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
                 [self syncFacebookUser];
                 [self getAllFacebookFriends];
                 [appDelegate sessionStateChanged:session state:state error:error];
             }];
        }

    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL) animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *header;
    if( [_viewTitle isEqualToString:@"From Contacts"] ){
        NSString *classType = [NSString stringWithFormat:@"%@",[tableView class]];
        
        if([classType isEqualToString:@"UISearchResultsTableView"] ){
            if (section == 0){
                header = @"Friends who have Meep";
            }
            else if(section == 1){
                header = @"Invite";
            }
        }
        else{
            if (section == 0){
                header = @"Friends who have Meep";
            }
            else if(section == 1){
                header = @"Invite";
            }
        }
        
    }else if( [_viewTitle isEqualToString:@"From Everyone"] ){
        if(section == 0){
            header = @"Users";
        }
    }
    
    return header;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    NSInteger numSections = 0;
    if( [_viewTitle isEqualToString:@"From Contacts"]){
        NSString *classType = [NSString stringWithFormat:@"%@",[tableView class]];
        
        if([classType isEqualToString:@"UISearchResultsTableView"] ){
            numSections = 2;
        }
        else{
            numSections = 2;
        }
        
    }
    else if([_viewTitle isEqualToString:@"From Facebook"]){
        numSections = 1;
    }
    else if( [_viewTitle isEqualToString:@"From Everyone"] ){
        numSections = 1;
    }
    return numSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if ([_viewTitle isEqualToString:@"From Contacts"]){
        
        NSString *classType = [NSString stringWithFormat:@"%@",[tableView class]];
        
        if([classType isEqualToString:@"UISearchResultsTableView"] ){
            //return[_searchResultFriendsList count];
            if( section == 0){
                return [_searchResultRegistered count];
            }
            else if(section ==1){
                return[_searchResultNonRegistered count];
            }
        }
        else{
            if( section == 0){
                return [_phoneRegisteredUsers count];
            }
            else if(section ==1){
                return[_phoneNonRegisteredUsers count];
            }
        }
        
        
    }
    else if([_viewTitle isEqualToString:@"From Facebook"]){
        return [_allFacebookFriends count];
    }
    else if([_viewTitle isEqualToString:@"From Everyone"]){
        if(section == 0){
            return[_searchResultFriendsList count];
        }
    }
    
    return 0;
}

- (void)selectFriend:(id)sender
{
    UIButton *button = (UIButton*) sender;
    
    NSLog(@"pressed add friend button ");
    
    if([_viewTitle isEqualToString:@"From Contacts"] ){
        if([button isSelected]){
            [button setSelected:NO];
            NSString * requestURL = [NSString stringWithFormat:@"%@friends/unfriend",[MEEPhttp accountURL]];
            NSLog(@"request url : %@", requestURL);
            NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:_buttonTagDictionary[[NSString stringWithFormat:@"%i", button.tag]],@"phone_number", nil];
            NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
            NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [conn start];
        }
        else if( ![button isSelected]){
            [button setSelected:YES];
            NSString * requestURL = [NSString stringWithFormat:@"%@friends/add_by_phone",[MEEPhttp accountURL]];
            NSLog(@"request url : %@", requestURL);
            NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:_buttonTagDictionary[[NSString stringWithFormat:@"%i", button.tag]],@"phone_number", nil];
            NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
            NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [conn start];
        }
    }
    
    else if([_viewTitle isEqualToString:@"From Everyone"]){
        if([button isSelected]){
            [button setSelected:NO];
            NSString * requestURL = [NSString stringWithFormat:@"%@friends/unfriend",[MEEPhttp accountURL]];
            
            /*
             NOT IMPLEMENTED ON THE SERVER YET. UNCOMMENT WHEN IMPLEMENTED
             NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:_buttonTagDictionary[[NSString stringWithFormat:@"%i", button.tag]],@"friend_id", nil];
             NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
             NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
             [conn start];*/
        }
        else if( ![button isSelected]){
            [button setSelected:YES];
            NSString * requestURL = [NSString stringWithFormat:@"%@friends/new",[MEEPhttp accountURL]];

            //NSLog(@"friending : %@", [_searchResultFriendsList[_buttonTagDictionary[button.tag]] name]);
            NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:_buttonTagDictionary[[NSString stringWithFormat:@"%i", button.tag]],@"friend_id", nil];
             NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
             NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
             [conn start];
        }
        
    }
    
    
}

- (void)selectFriendFromSearch:(id)sender
{
    UIButton *button = (UIButton*) sender;
    
    NSLog(@"pressed add friend button from search");
    
    if([_viewTitle isEqualToString:@"From Contacts"] ){
        if([button isSelected]){
            [button setSelected:NO];
            NSString * requestURL = [NSString stringWithFormat:@"%@friends/unfriend",[MEEPhttp accountURL]];
            NSLog(@"request url : %@", requestURL);
            NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:_searchButtonTagDictionary[[NSString stringWithFormat:@"%i", button.tag]],@"phone_number", nil];
            NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
            NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [conn start];
        }
        else if( ![button isSelected]){
            [button setSelected:YES];
            NSString * requestURL = [NSString stringWithFormat:@"%@friends/add_by_phone",[MEEPhttp accountURL]];
            NSLog(@"request url : %@", requestURL);
            NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:_searchButtonTagDictionary[[NSString stringWithFormat:@"%i", button.tag]],@"phone_number", nil];
            NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
            NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            [conn start];
        }
    }
}


- (void)inviteFriend:(id)sender
{
    UIButton *button = (UIButton*) sender;
    NSLog(@"Invite Friend tag: %i", button.tag);
    NSLog(@"Invite Friend description: %@", _buttonTagDictionary[[NSString stringWithFormat:@"%i", button.tag]]);
}

- (void)inviteFriendFromSearch:(id)sender
{
    UIButton *button = (UIButton*) sender;
    NSLog(@"Invite Friend tag: %i", button.tag);
    NSLog(@"Invite Friend description: %@", _searchButtonTagDictionary[[NSString stringWithFormat:@"%i", button.tag]]);
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {

     NSString *classType = [NSString stringWithFormat:@"%@",[tableView class]];
     
     UITableViewCell *cell;
     
     if([classType isEqualToString:@"UISearchResultsTableView"] ){
         cell = [[UITableViewCell alloc]init];
     }
     else{
         cell = [tableView dequeueReusableCellWithIdentifier:@"friendToAdd" forIndexPath:indexPath];
     }
     
     if( [_viewTitle isEqualToString:@"From Contacts"] ){
         
         NSString *classType = [NSString stringWithFormat:@"%@",[tableView class]];
         if([classType isEqualToString:@"UISearchResultsTableView"] ){
             if (indexPath.section == 0){
                 UIButton *newButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                 [newButton setFrame:CGRectMake(
                                                cell.bounds.size.width-(cell.bounds.size.width/5.0),
                                                (cell.bounds.size.height/4.0),
                                                50,
                                                23)];
                 newButton.backgroundColor = [UIColor grayColor];
                 [newButton setTitle:@"add" forState:UIControlStateNormal];
                 
                 [newButton addTarget:self action:@selector(selectFriendFromSearch:)
                     forControlEvents:UIControlEventTouchUpInside];
                 [newButton setTag: _searchButtonTagNumber];
                 NSString *key = [NSString stringWithFormat:@"%i", _searchButtonTagNumber];
                 [_searchButtonTagDictionary setObject:_searchResultRegistered[indexPath.row][@"phone_number"] forKey:key];
                 _searchButtonTagNumber++;
                 
                 [cell addSubview:newButton];
                 
                 NSMutableString *full_name = [[NSMutableString alloc] initWithString: _searchResultRegistered[indexPath.row][@"first_name"]];
                 [full_name appendString: @" "];
                 [full_name appendString: _searchResultRegistered[indexPath.row][@"last_name"]];
                 cell.textLabel.text = full_name;
             }
             else if(indexPath.section == 1){
                 UIButton *newButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                 [newButton setFrame:CGRectMake(
                                                cell.bounds.size.width-(cell.bounds.size.width/5.0),
                                                (cell.bounds.size.height/4.0),
                                                50,
                                                23)];
                 newButton.backgroundColor = [UIColor grayColor];
                 [newButton setTitle:@"Invite" forState:UIControlStateNormal];
                 [newButton addTarget:self action:@selector(inviteFriendFromSearch:)
                     forControlEvents:UIControlEventTouchUpInside];
                 [newButton setTag: _searchButtonTagNumber];
                 NSString *key = [NSString stringWithFormat:@"%i", _searchButtonTagNumber];
                 [_searchButtonTagDictionary setObject:_searchResultNonRegistered[indexPath.row][@"phone_number"] forKey:key];
                 _searchButtonTagNumber++;
                 
                 [cell addSubview:newButton];
                 
                 NSMutableString *full_name = [[NSMutableString alloc] initWithString: _searchResultNonRegistered[indexPath.row][@"first_name"]];
                 [full_name appendString: @" "];
                 [full_name appendString: _searchResultNonRegistered[indexPath.row][@"last_name"]];
                 cell.textLabel.text = full_name;
             }

         }
         else{
             if (indexPath.section == 0){
                 UIButton *newButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                 [newButton setFrame:CGRectMake(
                                                cell.bounds.size.width-(cell.bounds.size.width/5.0),
                                                (cell.bounds.size.height/4.0),
                                                50,
                                                23)];
                 newButton.backgroundColor = [UIColor grayColor];
                 [newButton setTitle:@"add" forState:UIControlStateNormal];
                 
                 [newButton addTarget:self action:@selector(selectFriend:)
                     forControlEvents:UIControlEventTouchUpInside];
                 [newButton setTag: _buttonTagNumber];
                 NSString *key = [NSString stringWithFormat:@"%i", _buttonTagNumber];
                 [_buttonTagDictionary setObject:_phoneRegisteredUsers[indexPath.row][@"phone_number"] forKey:key];
                 _buttonTagNumber++;
                 
                 [cell addSubview:newButton];
                 
                 NSMutableString *full_name = [[NSMutableString alloc] initWithString: _phoneRegisteredUsers[indexPath.row][@"first_name"]];
                 [full_name appendString: @" "];
                 [full_name appendString: _phoneRegisteredUsers[indexPath.row][@"last_name"]];
                 cell.textLabel.text = full_name;
             }
             else if(indexPath.section == 1){
                 UIButton *newButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                 [newButton setFrame:CGRectMake(
                                                cell.bounds.size.width-(cell.bounds.size.width/5.0),
                                                (cell.bounds.size.height/4.0),
                                                50,
                                                23)];
                 newButton.backgroundColor = [UIColor grayColor];
                 [newButton setTitle:@"Invite" forState:UIControlStateNormal];
                 [newButton addTarget:self action:@selector(inviteFriend:)
                     forControlEvents:UIControlEventTouchUpInside];
                 [newButton setTag: _buttonTagNumber];
                 NSString *key = [NSString stringWithFormat:@"%i", _buttonTagNumber];
                 [_buttonTagDictionary setObject:_phoneNonRegisteredUsers[indexPath.row][@"phone_number"] forKey:key];
                 _buttonTagNumber++;
                 
                 [cell addSubview:newButton];
                 
                 NSMutableString *full_name = [[NSMutableString alloc] initWithString: _phoneNonRegisteredUsers[indexPath.row][@"first_name"]];
                 [full_name appendString: @" "];
                 [full_name appendString: _phoneNonRegisteredUsers[indexPath.row][@"last_name"]];
                 cell.textLabel.text = full_name;
             }
         }
     }
     else if([_viewTitle isEqualToString:@"From Facebook"]){
         //cell.textLabel.text = _allFacebookFriends[indexPath.row][@"name"];
         UILabel *friendHeader = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 235, 21)];
         friendHeader.text =  _allFacebookFriends[indexPath.row][@"name"];
         [friendHeader setFont:[UIFont systemFontOfSize:18]];
         [cell.contentView addSubview:friendHeader];
         UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 40, 40)];
         img.image = [UIImage imageNamed:@"ManSilhouette"];
         [cell.contentView addSubview:img];
     }
     else if( [_viewTitle isEqualToString:@"From Everyone"] ){
             UIButton *newButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
             [newButton setFrame:CGRectMake(
                                            cell.bounds.size.width-(cell.bounds.size.width/5.0),
                                            (cell.bounds.size.height/4.0),
                                            50,
                                            23)];
             newButton.backgroundColor = [UIColor grayColor];
         
            NSString *friend_account_id = [NSString stringWithFormat:@"%i", [_searchResultFriendsList[indexPath.row] account_id]];
            if( [_friendsList containsObject:friend_account_id]){
                [newButton setTitle:@"block" forState:UIControlStateNormal];
                [newButton setSelected:YES];
            }
            else{
                [newButton setTitle:@"add" forState:UIControlStateNormal];
            }
         
             
             [newButton addTarget:self action:@selector(selectFriend:)
                 forControlEvents:UIControlEventTouchUpInside];
         
         
             [newButton setTag: _buttonTagNumber];
             NSString *key = [NSString stringWithFormat:@"%i", _buttonTagNumber];
             //[_buttonTagDictionary setObject:[_searchResultFriendsList[indexPath.row] name] forKey:key];
             [_buttonTagDictionary setObject:[NSString stringWithFormat:@"%i",[_searchResultFriendsList[indexPath.row] account_id]] forKey:key];
             _buttonTagNumber++;
             
             [cell addSubview:newButton];
             
             NSMutableString *full_name = [[NSMutableString alloc] initWithString: [_searchResultFriendsList[indexPath.row] name]];
             [full_name appendString: @" "];
             cell.textLabel.text = full_name;
     }
     
     return cell;
 }


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

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
