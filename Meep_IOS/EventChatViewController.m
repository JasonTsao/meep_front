//
//  EventChatViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/17/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "EventChatViewController.h"
#import "EventChatMessage.h"
#import "MEEPhttp.h"

@interface EventChatViewController ()
@property (weak, nonatomic) IBOutlet UITextField *chatMessageToSend;
@property(nonatomic, strong) NSMutableArray *chatMessages;
@property (weak, nonatomic) IBOutlet UILabel *textAndButtonHolder;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (weak, nonatomic) IBOutlet UITableView *chatMessageTable;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textboxVerticalTopSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textBoxTableConstraint;
@property (nonatomic, assign) BOOL keyboardShowed;
@end

@implementation EventChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) getPreviousChats{
    NSString *event_id = [NSString stringWithFormat:@"%i", _currentEvent.event_id];
    NSString * requestURL = [NSString stringWithFormat:@"%@%@/chat_messages",[MEEPhttp eventURL], event_id];
    NSDictionary * postDict = [[NSDictionary alloc] init];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (IBAction)sendMessage:(id)sender {
    NSLog(@"%@", _chatMessageToSend.text);
    NSString *event_id = [NSString stringWithFormat:@"%i", _currentEvent.event_id];
    NSString * requestURL = [NSString stringWithFormat:@"%@%@/chat_message/new",[MEEPhttp eventURL], event_id];
    NSLog(@"create message request url:%@", requestURL);
    NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:_chatMessageToSend.text,@"message", nil];
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
    NSLog(@"%@",jsonResponse[@"success"] );
    
    if([jsonResponse objectForKey:@"chat_saved"] != nil){
        [self.chatMessageTable reloadData];
    }
    else if([jsonResponse objectForKey:@"event_messages"] != nil){
        NSArray *chatMessageArray = jsonResponse[@"event_messages"];
        
        for(int i = 0; i < [chatMessageArray count]; i++){
            EventChatMessage * message = [[EventChatMessage alloc] init];
            
            message.event_id = _currentEvent.event_id;
            message.creator_id = [chatMessageArray[i][@"creator_id"] integerValue];
            message.creator_name = chatMessageArray[i][@"creator_name"];
            message.message = chatMessageArray[i][@"description"];
            message.time_stamp = chatMessageArray[i][@"created"];
            
            [_chatMessages addObject:message];
        }
        [self.chatMessageTable reloadData];
    }
}

- (void) observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void) keyboardWillShow:(NSNotification *)notification {
    if(_keyboardShowed)
        return;
    NSDictionary * info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    CGFloat height = keyboardFrame.size.height;
    _keyboardHeight.constant = height;
    CGRect frameRect = self.textAndButtonHolder.frame;
    frameRect.origin.y = self.textAndButtonHolder.frame.origin.y - height;
    _textAndButtonHolder.frame = frameRect;
    
    CGRect textframeRect = self.chatMessageToSend.frame;
    textframeRect.origin.y = self.chatMessageToSend.frame.origin.y - height;
    _chatMessageToSend.frame = textframeRect;
    
    CGRect buttonframeRect = self.sendButton.frame;
    //textframeRect.size.height = (self.chatMessageToSend.frame.size.height - height);
    buttonframeRect.origin.y = self.sendButton.frame.origin.y - height;
    _sendButton.frame = buttonframeRect;
    
    CGRect tableFrameRect = self.chatMessageTable.frame;
    tableFrameRect.size.height = (self.chatMessageTable.frame.size.height - (height/2));
    tableFrameRect.origin.y = self.chatMessageTable.frame.origin.y - (height/2);
    _chatMessageTable.frame = tableFrameRect;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
    self.keyboardShowed = YES;
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
    return [_chatMessages count];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatMessage" forIndexPath:indexPath];
    UIView * lineRemoval = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height, cell.frame.size.width, 1)];
    [cell addSubview:lineRemoval];
    //cell = [self clearCell:cell];
    cell.textLabel.text = [_chatMessages[indexPath.row] message];
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.keyboardShowed = NO;
    [self observeKeyboard];
    self.title = @"Chat";
    _chatMessages = [[NSMutableArray alloc] init];
    
    [self getPreviousChats];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
