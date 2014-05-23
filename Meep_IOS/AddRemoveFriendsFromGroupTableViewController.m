//
//  AddRemoveFriendsFromGroupTableViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/10/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "AddRemoveFriendsFromGroupTableViewController.h"
#import "MEEPhttp.h"
#import "MEPTableCell.h"
#import "jsonParser.h"

@interface AddRemoveFriendsFromGroupTableViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation AddRemoveFriendsFromGroupTableViewController

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
    _friends = [jsonParser friendsArray:friends];

    /*NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_friends];
     [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"friends_list"];
     [NSUserDefaults resetStandardUserDefaults];*/
    
    [self.tableView reloadData];
    
}

- (void)backToGroupPage:(id)sender {
    
    // synchronous update of event
    NSMutableArray *invitedMembersToSend = [[NSMutableArray alloc] init];
    NSMutableArray *removedMembersToSend = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [_invitedMembers count]; i++){
        NSString *user_id = [NSString stringWithFormat: @"%i", [_invitedMembers[i] account_id]];
        [invitedMembersToSend addObject: user_id];
    }
    
    for (int k = 0; k < [_removedMembers count]; k++){
        NSString *user_id = [NSString stringWithFormat: @"%i", [_removedMembers[k] account_id]];
        //NSDictionary *friend_dict = [[NSDictionary alloc] initWithObjectsAndKeys:user_id,@"user_id", @"false", @"can_invite_friends", nil];
        //[removedMembersToSend addObject:friend_dict];
        [removedMembersToSend addObject:user_id];
    }
    
    NSString * requestURL = [NSString stringWithFormat:@"%@group/%i/add_remove_members",[MEEPhttp accountURL], _currentGroup.group_id];
    NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:removedMembersToSend, @"remove_members", invitedMembersToSend, @"add_members", nil];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData *return_data = [NSURLConnection sendSynchronousRequest:request
                                                returningResponse:&response
                                                            error:&error];
    
    //NSDictionary * jsonResponse = [NSJSONSerialization JSONObjectWithData:return_data options:0 error:&error];
    
    [_delegate backToGroupPage:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *customBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backToGroupPage:)];
    
    self.navigationItem.leftBarButtonItem = customBarItem;
    _removedMembers = [[NSMutableArray alloc] init];
    _invitedMembers = [[NSMutableArray alloc] init];
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

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{   
    /*search_friends_list = [[NSMutableArray alloc] init];
    for( int i = 0; i < [friends_list count]; i++){
        if([[friends_list[i] name] hasPrefix:searchText]){
            [search_friends_list addObject:friends_list[i]];
        }
    }
    
    [self.searchDisplayController.searchResultsTableView reloadData];*/
}


#pragma mark - Table view data source
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *friend_name;
    Friend *selectedFriend;
    
    if (indexPath.section == 1){
        selectedFriend = _friends[indexPath.row];
        friend_name = selectedFriend.name;
        
        
        if (![_invitedMembers containsObject:selectedFriend]){
            
            if([_removedMembers containsObject:selectedFriend]){
                [_removedMembers removeObject:selectedFriend];
            }
            [tableView beginUpdates];
            [_invitedMembers addObject:selectedFriend];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:([_invitedMembers count] -1) inSection:0]]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }
        else{
            if(![_removedMembers containsObject:selectedFriend]){
                [_removedMembers addObject:selectedFriend];
            }
            
            [tableView beginUpdates];
            NSInteger deleteRow = [_invitedMembers indexOfObject:selectedFriend];
            [_invitedMembers removeObjectAtIndex: deleteRow];
            [tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject:[NSIndexPath indexPathForRow:deleteRow inSection:0]]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }
    }
    else if(indexPath.section == 0){
        selectedFriend = _invitedMembers[indexPath.row];
        friend_name = selectedFriend.name;
        
        if ([_invitedMembers containsObject:selectedFriend]){
            if(![_removedMembers containsObject:selectedFriend]){
                [_removedMembers addObject:selectedFriend];
            }
        }
        
        [tableView beginUpdates];
        [_invitedMembers removeObjectAtIndex: indexPath.row];
        [tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]]
                         withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView endUpdates];
        
    }
    NSLog(@"removedFriends: %@", _removedMembers);
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MEPTableCell customFriendCellHeight];
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
        numRows = [_originalMembers count];
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
        header = @"Members";
    }
    else if(section == 1){
        header = @"Friends";
    }
    
    return header;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupMember" forIndexPath:indexPath];
    UITableViewCell *cell;
    BOOL selected = NO;
    // Configure the cell...
    if (indexPath.section == 0){
        Friend *currentFriend = _originalMembers[indexPath.row];
        cell = [MEPTableCell customFriendCell:currentFriend forTable:tableView selected:selected];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if (indexPath.section == 1){
        Friend *currentFriend = _friends[indexPath.row];
        cell = [MEPTableCell customFriendCell:currentFriend forTable:tableView selected:selected];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
