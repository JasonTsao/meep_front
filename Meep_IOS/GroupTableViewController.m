//
//  GroupTableViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/3/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "GroupTableViewController.h"
#import "EditGroupViewController.h"
#import "AddRemoveFriendsFromGroupTableViewController.h"

@interface GroupTableViewController ()
@property (nonatomic, strong) EditGroupViewController *editGroupViewController;
@property (nonatomic, assign) BOOL showingEditPage;

@property (nonatomic, strong) AddRemoveFriendsFromGroupTableViewController *addRemoveFriendsFromGroupTableViewController;
@property (nonatomic, assign) BOOL showingAddRemoveFriendsPage;

@end

@implementation GroupTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) leaveEvent
{
    // remove user from event
}

- (void)backToGroupPage:(EditGroupViewController*)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) openEditGroupPage
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    _editGroupViewController = (EditGroupViewController *)[storyboard instantiateViewControllerWithIdentifier:@"editGroup"];
    
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_editGroupViewController];
    [_editGroupViewController setDelegate:self];
    _editGroupViewController.currentGroup = _group;
    [self presentViewController:navigation animated:YES completion:nil];
}

- (void) openAddRemoveFriendsPage
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    _addRemoveFriendsFromGroupTableViewController = (AddRemoveFriendsFromGroupTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"addRemoveFriendsFromGroup"];
    
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_addRemoveFriendsFromGroupTableViewController];
    [_addRemoveFriendsFromGroupTableViewController setDelegate:self];
    //_addRemoveFriendsFromEventTableViewController.invitedFriends = _invitedFriends;
    _addRemoveFriendsFromGroupTableViewController.originalMembers = _groupMembers;
    _addRemoveFriendsFromGroupTableViewController.currentGroup = _group;
    [self presentViewController:navigation animated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"clicked button at index: %i", buttonIndex);
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    NSLog(@"Removing user from group");
                    //[self logoutSelect];
                    break;
                case 1:
                    NSLog(@"going to edit view page");
                    [self openEditGroupPage];
                    break;
                case 2:
                    NSLog(@"going to invite more friends page");
                    [self openAddRemoveFriendsPage];
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}


- (IBAction)groupOptions:(id)sender {
    
    UIActionSheet *groupOptionsPopup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Leave Group", @"Edit Group Name", @"Add/Remove Friends",nil];
    //else
    //UIActionSheet *eventOptionsPopup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Leave Event",nil];
    groupOptionsPopup.tag = 1;
    [groupOptionsPopup showInView:self.view];
}


- (void)getGroupMembers
{
    NSString * requestURL = [NSString stringWithFormat:@"%@group/%i/members",[MEEPhttp accountURL], _group.group_id];
    NSDictionary * postDict = [[NSDictionary alloc] init];
    //NSDictionary *postDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"2",@"user", nil];
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
    NSArray * members = jsonResponse[@"members"];
    _groupMembers = [[NSMutableArray alloc]init];
    for( int i = 0; i< [members count]; i++){
        Friend *new_friend = [[Friend alloc]init];
        
        /*NSDictionary * new_friend_dict = [NSJSONSerialization JSONObjectWithData: [members[i] dataUsingEncoding:NSUTF8StringEncoding]
                                                                         options: NSJSONReadingMutableContainers
                                                                           error: &error];*/
        NSDictionary * new_friend_dict = members[i];
        new_friend.name = new_friend_dict[@"user_name"];
        new_friend.bio = new_friend_dict[@"bio"];
        new_friend.account_id = [new_friend_dict[@"account_id"] intValue];
        
        /*NSURL *url = [[NSURL alloc] initWithString:new_friend_dict[@"fb_pfpic_url"]];
        //NSURL *url = [[NSURL alloc] initWithString:@"https://graph.facebook.com/jason.s.tsao/picture"];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        //NSData *urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:nil];
        NSData *urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        new_friend.profilePic = image;
        NSLog(@"new friend pf pic %@", new_friend.profilePic);*/
        
        [_groupMembers addObject:new_friend];
    }
    
    [self.tableView reloadData];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _group.name;
    
    if (!_groupMembers){
        [self getGroupMembers];
    }
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [_groupMembers count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupMember" forIndexPath:indexPath];
    // Configure the cell...
    if (indexPath.section == 0){
        Friend *currentFriend = _groupMembers[indexPath.row];
        cell.textLabel.text = currentFriend.name;
    }
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    NSLog(@"can edit index path : %@", indexPath);
    return YES;
}



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
