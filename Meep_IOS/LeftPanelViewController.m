//
//  LeftPanelViewController.m
//  SlideoutNavigation
//
//  Created by Tammy Coron on 1/10/13.
//  Copyright (c) 2013 Tammy L Coron. All rights reserved.
//

#import "LeftPanelViewController.h"
#import "DjangoAuthClient.h"

@interface LeftPanelViewController ()

@property (nonatomic, weak) IBOutlet UITableView *myTableView;
@property (nonatomic, weak) IBOutlet UITableViewCell *cellMain;
@property (weak, nonatomic) IBOutlet UITableView *navTable;
@property(nonatomic, strong) DjangoAuthClient * authClient;
@property (nonatomic, strong) NSArray *navItems;
@property (nonatomic, strong) NSMutableArray *arrayOfAnimals;

@end

@implementation LeftPanelViewController
- (IBAction)openAccountSettings:(id)sender {
    [_delegate openAccountSettings];
}
- (IBAction)openFriendsListPage:(id)sender {
    [_delegate openFriendsListPage];
}

- (IBAction)openGroupsPage:(id)sender {
    [_delegate openGroupsPage];
}


- (IBAction)openAddFriendsPage:(id)sender {
    [_delegate openAddFriendsPage];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

/*-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *header;
    
    if(section == 0){
        NSData *authenticated = [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_client"];
        _authClient = [NSKeyedUnarchiver unarchiveObjectWithData:authenticated];
        header = _authClient.enc_username;
    }
    	
    return header;
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = [_navItems count];
    
    if(section == 0){
        numRows = 1;
    }
    else if(section == 1){
        numRows = numRows -1;
    }
    else{
        numRows = 1;
    }
    return numRows;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if( indexPath.section == 0){
        [_delegate openProfilePage];
    }
    
    if (indexPath.section == 1){
        NSLog(@"cell was 1");
        if(indexPath.row == 1){
            [_delegate openGroupsPage];
        }
        else if(indexPath.row == 2){
            [_delegate openFriendsListPage];
        }
        else if(indexPath.row == 3){
            [_delegate openAddFriendsPage];
        }
    }
    
    else if(indexPath.section == 2){
        if(indexPath.row == 0){
            [_delegate openAccountSettings];
        }
    }
    
}


-(void)openProfilePage:(id)sender{
    NSLog(@"in openprofile page sender");
    //[_delegate openProfilePage];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"navItem" forIndexPath:indexPath];
    //initWithFrame:CGRectMake(cell.bounds.size.width-10,-10,23,23) == top right
    
    cell.contentView.backgroundColor = [UIColor darkGrayColor];
    cell.textLabel.backgroundColor = [UIColor darkGrayColor];
    cell.textLabel.textColor = [UIColor lightGrayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0){
        NSString *name;
        NSData *authenticated = [[NSUserDefaults standardUserDefaults] objectForKey:@"auth_client"];
        _authClient = [NSKeyedUnarchiver unarchiveObjectWithData:authenticated];
        name = _authClient.enc_username;
        
        //UILabel *userHeader = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 235, 21)];
        UILabel *userHeader = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 50, 21)];
        userHeader.text = name;
        [userHeader setFont:[UIFont systemFontOfSize:18]];
        userHeader.textColor = [UIColor lightGrayColor];

        userHeader.tag = 1;
        [cell.contentView addSubview:userHeader];
        
        //NEED TO ACTUALLY GET REAL PF PIC LATER!
        UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 40, 40)];
        img.image = [UIImage imageNamed:@"ManSilhouette"];
        [cell.contentView addSubview:img];
    }
    else if(indexPath.section == 1){
        cell.textLabel.text = _navItems[indexPath.row];
    }
    else if(indexPath.section == 2){
        NSInteger index = indexPath.row + 4;
        cell.textLabel.text = _navItems[index] ;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section != 0){
        return 1;
    }
    return 0;
}


#pragma mark -
#pragma mark View Did Load/Unload

- (void)viewDidLoad
{
    [super viewDidLoad];
    _navItems = [[NSArray alloc] initWithObjects:@"Home",@"Groups", @"Friends",@"Add Friends", @"Settings" ,nil];
    [self.navTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"navItem"];
    self.navTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

#pragma mark -
#pragma mark View Will/Did Appear

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

#pragma mark -
#pragma mark View Will/Did Disappear

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Default System Code

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
