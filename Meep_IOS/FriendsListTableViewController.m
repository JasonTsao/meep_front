//
//  FriendsListTableViewController.m
//  Friends
//
//  Created by Jason Tsao on 4/24/14.
//  Copyright (c) 2014 Jason Tsao. All rights reserved.
//

#import "FriendsListTableViewController.h"
#import "jsonParser.h"
#import "MEPTableCell.h"
#import "MEEPhttp.h"

@interface FriendsListTableViewController (){
    NSMutableArray *friends_list;
}

@end

@implementation FriendsListTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)backToMain:(id)sender {
    [self.delegate backToCenterFromFriends:self];
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
    friends_list = [jsonParser friendsArray:friends];
    
    [self.tableView reloadData];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:friends_list];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"friends_list"];
    [NSUserDefaults resetStandardUserDefaults];

}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [self getFriendsList];
    [refreshControl endRefreshing];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    self.title = @"Friends";
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    friends_list = [[NSMutableArray alloc]init];
    
    NSData *friendsListData = [[NSUserDefaults standardUserDefaults] objectForKey:@"friends_list"];
    [self getFriendsList];
    
    
    /*
    Code for caching friends list
     
    //NSMutableArray *user_friends_list = [NSKeyedUnarchiver unarchiveObjectWithData:friendsListData];
    //friends_list = user_friends_list;

    if (!user_friends_list){
        NSLog(@"There is no friends list stored already");
        [self getFriendsList];
    }
    else{
        NSLog(@"There was friends list data stored already");
    }
    friends_list = user_friends_list;*/

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"toFriendProfilePage" sender:self];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MEPTableCell customFriendCellHeight];
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
    return [friends_list count];
}

- (UITableViewCell*)clearCell:(UITableViewCell *)cell{
    for(UIView *view in cell.contentView.subviews){
        if ([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview];
        }
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    //cell = [self clearCell:cell];
    
    Friend *currentFriend = [friends_list objectAtIndex:indexPath.row];
    BOOL selected = NO;
    UITableViewCell *cell = [MEPTableCell customFriendCell:currentFriend forTable:tableView selected:selected];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
    //toFriendProfilePage
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    FriendProfileViewController * friend_profile = [segue destinationViewController];
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    Friend *selected_friend = friends_list[path.row];
    friend_profile.currentFriend = selected_friend;
}


@end
