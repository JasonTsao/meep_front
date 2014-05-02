//
//  CreateGroupViewController.m
//  Group
//
//  Created by Jason Tsao on 4/30/14.
//  Copyright (c) 2014 Jason Tsao. All rights reserved.
//

#import "CreateGroupViewController.h"
#import "MEEPhttp.h"
#import "Friend.h"

@interface CreateGroupViewController ()
@property (weak, nonatomic) IBOutlet UITableView *friendTable;
@property (weak, nonatomic) IBOutlet UITextField *nameField;

@end

@implementation CreateGroupViewController{
    NSMutableArray *friends_list;
    NSMutableArray *selected_friends_list;
    dispatch_queue_t networkQueue;

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    NSLog(@"connection did recieve response");
    _data = [[NSMutableData alloc] init]; // _data being an ivar
}
-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    NSLog(@"connection did recieve data");
    [_data appendData:data];
}
-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    // Handle the error properly
    NSLog(@"Call Failed");
}
-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    NSLog(@"connection did finish loading");
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
        
        [friends_list addObject:new_friend];
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:friends_list];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"friends_list"];
    [NSUserDefaults resetStandardUserDefaults];
    
}

- (IBAction)createGroup:(id)sender {
    NSLog(@"Name: %@", self.nameField.text);
    for (int i = 0; i < [selected_friends_list count]; i++){
        NSLog(@"%@", [selected_friends_list[i] name]);
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *friend_name;
    Friend *selectedFriend;
    
    [_nameField resignFirstResponder];
    if (indexPath.section == 1){
        selectedFriend = friends_list[indexPath.row];
        friend_name = selectedFriend.name;

        if (![selected_friends_list containsObject:selectedFriend]){
            [tableView beginUpdates];
            [selected_friends_list addObject:selectedFriend];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:([selected_friends_list count] -1) inSection:0]]
                            withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }
        else{
            [tableView beginUpdates];
            NSInteger deleteRow = [selected_friends_list indexOfObject:selectedFriend];
            [selected_friends_list removeObjectAtIndex: deleteRow];
            [tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject:[NSIndexPath indexPathForRow:deleteRow inSection:0]]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }
    }
    else if(indexPath.section == 0){
        selectedFriend = selected_friends_list[indexPath.row];
        friend_name = selectedFriend.name;
        [tableView beginUpdates];
        [selected_friends_list removeObjectAtIndex: indexPath.row];
        [tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]]
                         withRowAnimation:UITableViewRowAnimationFade];

        [tableView endUpdates];
    }

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 1;
    if (section == 0){
        numRows = [selected_friends_list count];
    }
    else if(section == 1){
        numRows = [friends_list count];
    }
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectCell"];

    if (indexPath.section == 0){
        Friend *currentFriend = selected_friends_list[indexPath.row];
        cell.textLabel.text = currentFriend.name;
    }
    else if (indexPath.section == 1){
        Friend *currentFriend = friends_list[indexPath.row];
        cell.textLabel.text = currentFriend.name;
    }

    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Create Group";
    friends_list = [[NSMutableArray alloc]init];
    selected_friends_list = [[NSMutableArray alloc]init];
    NSData *friendsListData = [[NSUserDefaults standardUserDefaults] objectForKey:@"friends_list"];
    NSMutableArray *user_friends_list = [NSKeyedUnarchiver unarchiveObjectWithData:friendsListData];
    self.friendTable.allowsMultipleSelectionDuringEditing=YES;
    if(!networkQueue){
        networkQueue = dispatch_queue_create("Network.Queue", NULL);
    }
    
    if(!user_friends_list){
        [self getFriendsList];
        //dispatch_async(networkQueue, ^{[self getFriendsList];});
    }
    else{
        //friends_list = user_friends_list;
    }
    friends_list = user_friends_list;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
