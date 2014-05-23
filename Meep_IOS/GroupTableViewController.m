//
//  GroupTableViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/3/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "GroupTableViewController.h"
#import "EditGroupViewController.h"
#import "FriendProfileViewController.h"
#import "AddRemoveFriendsFromGroupTableViewController.h"
#import "jsonParser.h"
#import "MEPTableCell.h"

@interface GroupTableViewController ()
@property (nonatomic, strong) EditGroupViewController *editGroupViewController;
@property (nonatomic, assign) BOOL showingEditPage;

@property (nonatomic, strong) AddRemoveFriendsFromGroupTableViewController *addRemoveFriendsFromGroupTableViewController;
@property (nonatomic, assign) BOOL showingAddRemoveFriendsPage;

@property(nonatomic) BOOL groupPropertyChanged;

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

- (void)backToGroupPage:(EditGroupViewController*)controller
{
    if (controller.savedGroupName != nil){
        self.title = controller.savedGroupName;
        _group.name = controller.savedGroupName;
        _groupPropertyChanged = YES;
    }

    [self getGroupMembers];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        NSString * requestURL = [NSString stringWithFormat:@"%@group/%i/remove_self",[MEEPhttp accountURL], _group.group_id];
        NSDictionary * postDict = [[NSDictionary alloc] init];
        NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
        NSURLResponse * response = nil;
        NSError * error = nil;
        NSData *return_data = [NSURLConnection sendSynchronousRequest:request
                                                    returningResponse:&response
                                                                error:&error];
        
        //[_delegate backToGroupsPage:self];
        _groupPropertyChanged = YES;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) removeSelfFromGroup
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Leave Group"
                          message:@"Are you sure you want to leave group?"
                          delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"OK",nil];
    [alert show];
}

- (void) openEditGroupPage
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CenterStoryboard" bundle:nil];
    _editGroupViewController = (EditGroupViewController *)[storyboard instantiateViewControllerWithIdentifier:@"editGroup"];
    
    UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:_editGroupViewController];
    [_editGroupViewController setDelegate:self];
    _editGroupViewController.currentGroup = _group;
    _editGroupViewController.originalName = _group.name;
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
                    [self removeSelfFromGroup];
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
    _groupMembers = [jsonParser friendsArrayNoEncoding:members];
    /*_groupMembers = [[NSMutableArray alloc]init];
    for( int i = 0; i< [members count]; i++){
        Friend *new_friend = [[Friend alloc]init];
        
        //NSDictionary * new_friend_dict = [NSJSONSerialization JSONObjectWithData: [members[i] dataUsingEncoding:NSUTF8StringEncoding]
        //options: NSJSONReadingMutableContainers
        //error: &error];
        NSDictionary * new_friend_dict = members[i];
        new_friend.name = new_friend_dict[@"user_name"];
        new_friend.bio = new_friend_dict[@"bio"];
        new_friend.account_id = [new_friend_dict[@"id"] intValue];
        
        if ([new_friend_dict[@"pf_pic"] length] == 0){
            UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 40, 40)];
            img.image = [UIImage imageNamed:@"ManSilhouette"];
            //new_friend.profilePic = img;
            new_friend.profilePic = img.image;
        }
        else{
            NSURL *url = [[NSURL alloc] initWithString:new_friend_dict[@"fb_pfpic_url"]];
            //NSURL *url = [[NSURL alloc] initWithString:@"https://graph.facebook.com/jason.s.tsao/picture"];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
            //NSData *urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:nil];
            NSData *urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            new_friend.profilePic = image;
        }
        
        //NSURL *url = [[NSURL alloc] initWithString:new_friend_dict[@"fb_pfpic_url"]];
         //NSURL *url = [[NSURL alloc] initWithString:@"https://graph.facebook.com/jason.s.tsao/picture"];
        //NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
         //NSData *urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:nil];
        //NSData *urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
        //UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        //new_friend.profilePic = image;
        //NSLog(@"new friend pf pic %@", new_friend.profilePic);
        
        [_groupMembers addObject:new_friend];
    }*/

    [self.tableView reloadData];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _group.name;
    
    if (!_groupMembers){
        [self getGroupMembers];
    }
    
    _groupPropertyChanged = NO;
    
    //self.navigationItem
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"group property changed %hhd", _groupPropertyChanged );
    if(_groupPropertyChanged == YES){
        [_delegate updatedGroupName:self];
    }
    [super viewWillDisappear:animated];
    //[self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"toGroupMemberProfilePage" sender:self];
}

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
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupMember" forIndexPath:indexPath];
    UITableViewCell *cell;
    // Configure the cell...
    if (indexPath.section == 0){
        Friend *currentFriend = _groupMembers[indexPath.row];
        BOOL selected = NO;
        cell = [MEPTableCell customFriendCell:currentFriend forTable:tableView selected:selected];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        /*//cell.textLabel.text = currentFriend.name;
        UILabel *friendHeader = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 235, 21)];
        friendHeader.text = currentFriend.name;
        [friendHeader setFont:[UIFont systemFontOfSize:18]];
        [cell.contentView addSubview:friendHeader];
        UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 40, 40)];
        img.image = currentFriend.profilePic;
        [cell.contentView addSubview:img];*/
    }
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    FriendProfileViewController * friend_profile = [segue destinationViewController];
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    Friend *selected_friend = _groupMembers[path.row];
    friend_profile.currentFriend = selected_friend;
}


@end
