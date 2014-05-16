//
//  FriendsListTableViewController.m
//  Friends
//
//  Created by Jason Tsao on 4/24/14.
//  Copyright (c) 2014 Jason Tsao. All rights reserved.
//

#import "FriendsListTableViewController.h"
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
    friends_list = [[NSMutableArray alloc]init];
    for( int i = 0; i< [friends count]; i++){
        Friend *new_friend = [[Friend alloc]init];
        
        NSDictionary * new_friend_dict = [NSJSONSerialization JSONObjectWithData: [friends[i] dataUsingEncoding:NSUTF8StringEncoding]
                                                                         options: NSJSONReadingMutableContainers
                                                                           error: &error];
        
        
        new_friend.name = new_friend_dict[@"name"];
        new_friend.numTimesInvitedByMe = new_friend_dict[@"invited_count"];
        new_friend.phoneNumber= new_friend_dict[@"phone_number"];
        new_friend.imageFileName = new_friend_dict[@"pf_pic"];
        new_friend.bio = new_friend_dict[@"bio"];
        new_friend.account_id = [new_friend_dict[@"account_id"] intValue];
        
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
  
        [friends_list addObject:new_friend];
    }
    
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
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    friends_list = [[NSMutableArray alloc]init];
    
    NSData *friendsListData = [[NSUserDefaults standardUserDefaults] objectForKey:@"friends_list"];
    NSMutableArray *user_friends_list = [NSKeyedUnarchiver unarchiveObjectWithData:friendsListData];
    [self getFriendsList];
    friends_list = user_friends_list;
    
    /*if (!user_friends_list){
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell = [self clearCell:cell];
    Friend *currentFriend = [friends_list objectAtIndex:indexPath.row];
    UILabel *friendHeader = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 235, 21)];
    friendHeader.text = currentFriend.name;
    [friendHeader setFont:[UIFont systemFontOfSize:18]];
    [cell.contentView addSubview:friendHeader];
    UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 40, 40)];
    img.image = currentFriend.profilePic;
    [cell.contentView addSubview:img];
    
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
    Friend *selected_friend = friends_list[path.row];
    friend_profile.currentFriend = selected_friend;
}


@end
