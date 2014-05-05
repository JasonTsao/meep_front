//
//  AddFromContactsTableViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/4/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "AddFriendsFromTableViewController.h"

@interface AddFriendsFromTableViewController ()

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
    NSString * requestURL = [NSString stringWithFormat:@"%@friends/list/1",[MEEPhttp accountURL]];
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
}
-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    [self handleData]; // Deal with the data
}

-(void)getFriendsToInviteAndRegisteredUsers:(NSMutableArray*)nonFriends
{
    NSString * requestURL = [NSString stringWithFormat:@"%@check_if_phone_users_registered",[MEEPhttp accountURL]];
    NSLog(@"request url : %@", requestURL);
    NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"2", @"user",_phoneNonFriendUsersNumbers,@"phone_numbers", nil];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}


-(void)handleData{
    
    if ([_viewTitle isEqualToString:@"From Contacts"]){
        
        NSError* nserror;
        NSDictionary * jsonResponse = [NSJSONSerialization JSONObjectWithData:_data options:0 error:&nserror];
        
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
            //_phoneRegisteredUsers = [[NSMutableArray alloc]init];
            _phoneNonFriendUsersNumbers = [[NSMutableArray alloc]init];
            _phoneNonFriendUsers = [[NSMutableArray alloc]init];
            _phoneContacts = [[NSMutableArray alloc]init];
            _phoneContactNumbers = [[NSMutableArray alloc]init];
            CFErrorRef error = NULL;
            ABAddressBookRef addressBook = ABAddressBookCreate( );
            CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
            CFIndex nPeople = ABAddressBookGetPersonCount( addressBook );
            
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
    
    
    //[self.tableView reloadData];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _viewTitle;
    
    if( [_viewTitle isEqualToString:@"From Contacts"]){
        [self getFriendsList];
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
    if (section == 0){
        header = @"Friends who have Meep";
    }
    else if(section == 1){
        header = @"Invite";
    }
    return header;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if ([_viewTitle isEqualToString:@"From Contacts"]){
        
        if( section == 0){
            return [_phoneRegisteredUsers count];
        }
        else if(section ==1){
            return[_phoneNonRegisteredUsers count];
        }
    }
    
    return 0;
}

- (void)addFriend:(id)sender
{
    NSLog(@"Add Friend sender: %@", sender);
}

- (void)inviteFriend:(id)sender
{
    NSLog(@"Invite Friend sender: %@", sender);
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendToAdd" forIndexPath:indexPath];
     
     if (indexPath.section == 0){
         UIButton *newButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
         [newButton setFrame:CGRectMake(
                                        cell.bounds.size.width-(cell.bounds.size.width/5.0),
                                        (cell.bounds.size.height/4.0),
                                        50,
                                        23)];
         newButton.backgroundColor = [UIColor grayColor];
         [newButton setTitle:@"add" forState:UIControlStateNormal];
         [newButton addTarget:self action:@selector(addFriend:)
              forControlEvents:UIControlEventTouchUpInside];
         [cell addSubview:newButton];
         
         NSMutableString *full_name = [[NSMutableString alloc] initWithString: _phoneRegisteredUsers[indexPath.row][@"first_name"]];
         [full_name appendString: @" "];
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
         [cell addSubview:newButton];
         
         NSMutableString *full_name = [[NSMutableString alloc] initWithString: _phoneNonRegisteredUsers[indexPath.row][@"first_name"]];
         [full_name appendString: @" "];
         cell.textLabel.text = full_name;
     }
     
     //[full_name appendString: _phoneContacts[indexPath.row][@"last_name"]];
     
     
 // Configure the cell...
 
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
