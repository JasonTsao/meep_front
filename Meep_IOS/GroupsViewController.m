//
//  GroupsViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/1/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "GroupsViewController.h"
#import "jsonParser.h"
#import "MEPTableCell.h"

@interface GroupsViewController (){
    NSMutableArray *groups_list;
}

@end

@implementation GroupsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)backToMain:(id)sender {
    [self.delegate backToCenterFromGroups:self];
}


- (void)getGroupList
{
    NSString * requestURL = [NSString stringWithFormat:@"%@group/list",[MEEPhttp accountURL]];
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
    NSArray * groups = jsonResponse[@"groups"];
    
    groups_list = [jsonParser groupsArray:groups];

   /* NSData *data = [NSKeyedArchiver archivedDataWithRootObject:groups_list];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"groups"];
    [NSUserDefaults resetStandardUserDefaults];*/
    
    [self.tableView reloadData];

}

- (void)updatedGroupName:(id)sender {
    NSLog(@"updated group name in groupsviewcontroller");
    [self getGroupList];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [self getGroupList];
    [refreshControl endRefreshing];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    self.title = @"My Groups";
    [self getGroupList];
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
    return [groups_list count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"group" forIndexPath:indexPath];
    
    // Configure the cell...
    Group *currentGroup = [groups_list objectAtIndex:indexPath.row];
    cell = [MEPTableCell customGroupCell:currentGroup forCell:cell forTable:tableView selected:NO];
    /*UILabel *groupHeader = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 235, 21)];
    groupHeader.text = currentGroup.name;
    [groupHeader setFont:[UIFont systemFontOfSize:18]];
    [cell.contentView addSubview:groupHeader];
    UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 40, 40)];
    img.image = currentGroup.groupProfilePic;
    [cell.contentView addSubview:img];*/

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
    
    if (![[segue identifier] isEqualToString:@"createGroup"]){
        
        GroupEventsTableViewController * groupEvents = [segue destinationViewController];
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        [groupEvents setDelegate:self];
        Group *selected_group = groups_list[path.row];
        groupEvents.group = selected_group;
        
        /*GroupTableViewController * groupPage = [segue destinationViewController];
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        [groupPage setDelegate:self];
        Group *selected_group = groups_list[path.row];
        groupPage.group = selected_group;*/
        
    }else{
        CreateGroupViewController *createGroupPage = [segue destinationViewController];
        [createGroupPage setDelegate:self.delegate];
    }

}


@end
