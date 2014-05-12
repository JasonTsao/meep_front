//
//  AddRemoveFriendsFromEventTableViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/9/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "AddRemoveFriendsFromEventTableViewController.h"
#import "Friend.h"
#import "InvitedFriend.h"
#import "Group.h"
#import "MEEPhttp.h"

@interface AddRemoveFriendsFromEventTableViewController ()

@end

@implementation AddRemoveFriendsFromEventTableViewController

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
}
-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    [self handleData]; // Deal with the data
}


-(void)handleData{
    NSError* error;
    NSDictionary * jsonResponse = [NSJSONSerialization JSONObjectWithData:_data options:0 error:&error];
    NSArray * friends = jsonResponse[@"friends"];
    _friends = [[NSMutableArray alloc]init];

    for( int i = 0; i< [friends count]; i++){
        //Friend *new_friend = [[Friend alloc]init];
        InvitedFriend *new_friend = [[InvitedFriend alloc]init];
        
        NSDictionary * new_friend_dict = [NSJSONSerialization JSONObjectWithData: [friends[i] dataUsingEncoding:NSUTF8StringEncoding]
                                                                         options: NSJSONReadingMutableContainers
                                                                           error: &error];
        new_friend.name = new_friend_dict[@"name"];
        //new_friend.imageFileName = new_friend_dict[@"pf_pic"];
        new_friend.account_id = [new_friend_dict[@"account_id"] intValue];
        [_friends addObject:new_friend];
        
        for(int k = 0; k < [_originalInvitedFriends count]; k++){
            if([_originalInvitedFriends[k] account_id] == new_friend.account_id){
                [_invitedFriends addObject:new_friend];
            }
        }
    }
    
    /*NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_friends];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"friends_list"];
    [NSUserDefaults resetStandardUserDefaults];*/
    
    [self.tableView reloadData];
    
}

- (void)backToEventPage:(id)sender {
    
    // synchronous update of event
    NSMutableArray *invitedFriendsToSend = [[NSMutableArray alloc] init];
    NSMutableArray *removedFriendsToSend = [[NSMutableArray alloc] init];
    
    NSLog(@"removed friends: %@", _removedFriends);
    NSLog(@"invited friends:%@", _invitedFriends);
    NSLog(@"original invited friends: %@", _originalInvitedFriends);
    
    for (int i = 0; i < [_invitedFriends count]; i++){
        NSString *user_id = [NSString stringWithFormat: @"%i", [_invitedFriends[i] account_id]];
        NSDictionary *friend_dict = [[NSDictionary alloc] initWithObjectsAndKeys:user_id,@"user_id", @"false", @"can_invite_friends", nil];
        [invitedFriendsToSend addObject:friend_dict];
        NSLog(@"invited friend: %i", [_invitedFriends[i] account_id]);
    }
    
    for (int k = 0; k < [_removedFriends count]; k++){
        NSString *user_id = [NSString stringWithFormat: @"%i", [_removedFriends[k] account_id]];
        NSDictionary *friend_dict = [[NSDictionary alloc] initWithObjectsAndKeys:user_id,@"user_id", @"false", @"can_invite_friends", nil];
        [removedFriendsToSend addObject:friend_dict];
        NSLog(@"invited friend: %i", [_removedFriends[k] account_id]);
    }
    
    NSString * requestURL = [NSString stringWithFormat:@"%@add_remove_friends/%i",[MEEPhttp eventURL], _currentEvent.event_id];
    //NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"user", messageText, @"description", invitedFriendsToSend, @"invited_friends", nil];
    NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:removedFriendsToSend, @"removed_friends", invitedFriendsToSend, @"invited_friends", nil];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData *return_data = [NSURLConnection sendSynchronousRequest:request
                                                returningResponse:&response
                                                            error:&error];
    
    NSDictionary * jsonResponse = [NSJSONSerialization JSONObjectWithData:return_data options:0 error:&error];
    NSLog(@"jsonResponse: %@", jsonResponse);

    
    [_delegate backToEventPage:self];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _removedFriends = [[NSMutableArray alloc]init];
    _invitedFriends = [[NSMutableArray alloc]init];
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backToEventPage:)];
    
    self.navigationItem.leftBarButtonItem = customBarItem;
    [self getFriendsList];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *friend_name;
    Friend *selectedFriend;
    
    if (indexPath.section == 1){
        selectedFriend = _friends[indexPath.row];
        friend_name = selectedFriend.name;
        
        
        if (![_invitedFriends containsObject:selectedFriend]){
            
            if([_removedFriends containsObject:selectedFriend]){
                [_removedFriends removeObject:selectedFriend];
            }
            [tableView beginUpdates];
            [_invitedFriends addObject:selectedFriend];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:([_invitedFriends count] -1) inSection:0]]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }
        else{
            if(![_removedFriends containsObject:selectedFriend]){
                [_removedFriends addObject:selectedFriend];
            }
            
            [tableView beginUpdates];
            NSInteger deleteRow = [_invitedFriends indexOfObject:selectedFriend];
            [_invitedFriends removeObjectAtIndex: deleteRow];
            [tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject:[NSIndexPath indexPathForRow:deleteRow inSection:0]]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }
    }
    else if(indexPath.section == 0){
        selectedFriend = _invitedFriends[indexPath.row];
        friend_name = selectedFriend.name;
        
        if ([_invitedFriends containsObject:selectedFriend]){
            if(![_removedFriends containsObject:selectedFriend]){
                [_removedFriends addObject:selectedFriend];
            }
        }
        
        [tableView beginUpdates];
        [_invitedFriends removeObjectAtIndex: indexPath.row];
        [tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]]
                         withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView endUpdates];
        
    }
    NSLog(@"removedFriends: %@", _removedFriends);
    
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
    NSInteger numRows = 1;
    if (section == 0){
        numRows = [_invitedFriends count];
    }
    else if(section == 1){
        numRows = [_friends count];
    }
    return numRows;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *header;
    if (section == 0){
        header = @"Selected";
    }
    else if(section == 1){
        header = @"Friends";
    }
    
    return header;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventFriendCell" forIndexPath:indexPath];
    
    // Configure the cell...
    if (indexPath.section == 0){
        Friend *currentFriend = _invitedFriends[indexPath.row];
        cell.textLabel.text = currentFriend.name;
    }
    else if (indexPath.section == 1){
        Friend *currentFriend = _friends[indexPath.row];
        cell.textLabel.text = currentFriend.name;
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
