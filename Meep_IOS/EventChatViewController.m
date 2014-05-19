//
//  EventChatViewController.m
//  Meep_IOS
//
//  Created by Jason Tsao on 5/17/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "EventChatViewController.h"
#import "EventChatMessage.h"
#import "CenterViewController.h"
#import "Friend.h"
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

#define BORDER_COLOR "3FC380"
@implementation EventChatViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)putMessageOnTable:(NSString *)message
{
    EventChatMessage * chatMessage = [[EventChatMessage alloc] init];
    NSInteger creator_id = 1;
    NSInteger creator_name = @"Jason";
    NSString * currentTime = @"2014-05-15 04:33:22";
    
    chatMessage.event_id = _currentEvent.event_id;
    chatMessage.creator_id = creator_id;
    chatMessage.creator_name = @"Jason";
    chatMessage.message = message;
    chatMessage.time_stamp = currentTime;
    chatMessage.new_message = YES;
    
    [_chatMessages addObject:message];
}

- (void) getPreviousChats{
    NSString *event_id = [NSString stringWithFormat:@"%ld", _currentEvent.event_id];
    NSString * requestURL = [NSString stringWithFormat:@"%@chat_messages/%@",[MEEPhttp eventURL], event_id];
    NSDictionary * postDict = [[NSDictionary alloc] init];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (IBAction)sendMessage:(id)sender {
    NSLog(@"%@", _chatMessageToSend.text);
    NSString *event_id = [NSString stringWithFormat:@"%ld", _currentEvent.event_id];
    NSString * requestURL = [NSString stringWithFormat:@"%@chat_message/%@/new",[MEEPhttp eventURL], event_id];
    NSLog(@"create message request url:%@", requestURL);
    NSDictionary * postDict = [[NSDictionary alloc] initWithObjectsAndKeys:_chatMessageToSend.text,@"message", nil];
    NSMutableURLRequest * request = [MEEPhttp makePOSTRequestWithString:requestURL postDictionary:postDict];
    NSURLConnection * conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
    
    [self putMessageOnTable:_chatMessageToSend.text];
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
    
    NSLog(@"jsonResponse: %@", jsonResponse);
    if([jsonResponse objectForKey:@"chat_saved"] != nil){
        [self.chatMessageTable reloadData];
    }
    else if([jsonResponse objectForKey:@"comments"] != nil){
        NSArray *chatMessageArray = jsonResponse[@"comments"];
        
        for(int i = 0; i < [chatMessageArray count]; i++){
            NSLog(@"chat message: %@", chatMessageArray[i]);
            EventChatMessage * message = [[EventChatMessage alloc] init];
            
            message.event_id = _currentEvent.event_id;
            message.creator_id = [chatMessageArray[i][@"creator_id"] integerValue];
            message.creator_name = chatMessageArray[i][@"creator_name"];
            message.message = chatMessageArray[i][@"message"];
            message.time_stamp = chatMessageArray[i][@"created"];
            
            [_chatMessages addObject:message];
        }
        [self.chatMessageTable reloadData];
    }
}

- (void) observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing: YES];
}

- (void) keyboardWillShow:(NSNotification *)notification {
    if(_keyboardShowed){
        NSLog(@"keyboard going away!!");
        NSDictionary * info = [notification userInfo];
        NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
        NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGRect keyboardFrame = [kbFrame CGRectValue];
        CGFloat height = keyboardFrame.size.height;
        _keyboardHeight.constant = height;
        CGRect frameRect = self.textAndButtonHolder.frame;
        frameRect.origin.y = self.textAndButtonHolder.frame.origin.y + height;
        _textAndButtonHolder.frame = frameRect;
        
        CGRect textframeRect = self.chatMessageToSend.frame;
        textframeRect.origin.y = self.chatMessageToSend.frame.origin.y + height;
        _chatMessageToSend.frame = textframeRect;
        
        CGRect buttonframeRect = self.sendButton.frame;
        //textframeRect.size.height = (self.chatMessageToSend.frame.size.height - height);
        buttonframeRect.origin.y = self.sendButton.frame.origin.y + height;
        _sendButton.frame = buttonframeRect;
        
        CGRect tableFrameRect = self.chatMessageTable.frame;
        tableFrameRect.size.height = (self.chatMessageTable.frame.size.height + (height/2));
        tableFrameRect.origin.y = self.chatMessageTable.frame.origin.y + (height/2);
        _chatMessageTable.frame = tableFrameRect;
        
        [UIView animateWithDuration:animationDuration animations:^{
            [self.view layoutIfNeeded];
        }];
        
        NSLog(@"keyboard now gone!");
        self.keyboardShowed = NO;
    }
    else{
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    NSString *eventInfoType;
    EventChatMessage *currentMessage = _chatMessages[indexPath.row];
    NSInteger message_length = [[currentMessage message] length];
    NSInteger numRows = message_length % 40;
    
    NSLog(@"numRows : %i", numRows);
    
    if( [currentMessage creator_id] != 1){
        height = 40;
        if( message_length > 35){
            height *= 2;
        }
    }
    else{
        height = 30;

        if( message_length > 35){
            height *= 2;
        }
    }

    return height;
}

- (NSInteger)getMessagePixelLength:(NSInteger) messageLength
{
    NSInteger message_pixel_length;
    
    message_pixel_length = messageLength * 6;
    
    if(messageLength < 40){
       message_pixel_length = messageLength * 7;
    }
    else if(messageLength >= 40 && messageLength < 150){
        message_pixel_length = messageLength * 8;
    }
    
    return message_pixel_length;
}

- (NSInteger)getMessagePixelHeight:(NSInteger) messageLength
{
    NSInteger message_pixel_height;
    NSInteger multiplier = messageLength /21;
    
    if( multiplier < 1){
        message_pixel_height = 25;
    }
    else{
        message_pixel_height = 25 * multiplier;
    }
    
    
    return message_pixel_height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatMessage" forIndexPath:indexPath];

    cell = [self clearCell:cell];
    //Friend *currentFriend = [friends_list objectAtIndex:indexPath.row];
    CGRect cellFrameRect = cell.contentView.frame;
    cellFrameRect.size.height = (cell.contentView.frame.size.height + 10 );
    cell.contentView.frame = cellFrameRect;
    
    EventChatMessage *currentMessage = _chatMessages[indexPath.row];
    NSInteger message_length = [currentMessage.message length];
    NSInteger message_height = 21;
    //NSInteger message_pixel_length = message_length * 6;
    NSInteger message_pixel_length = [self getMessagePixelLength:message_length];
    NSInteger message_pixel_height = [self getMessagePixelHeight:message_length];

    /*if( message_length > 25){
        message_height *= 1.5;
    }*/

    if( [currentMessage creator_id] != 1){
        
        UILabel *currentMessageHeader = [[UILabel alloc] initWithFrame:CGRectMake(35, 10, message_pixel_length, message_height)];
        currentMessageHeader.layer.cornerRadius = 5;
        currentMessageHeader.layer.masksToBounds = YES;
        currentMessageHeader.text = [currentMessage message];
        currentMessageHeader.backgroundColor = [UIColor lightGrayColor];
        
        [currentMessageHeader setFont:[UIFont systemFontOfSize:13]];
        [cell.contentView addSubview:currentMessageHeader];
        
        UILabel *messageCreatorName = [[UILabel alloc] initWithFrame:CGRectMake(35, -6, 100, 21)];
        messageCreatorName.text = [currentMessage creator_name];
        [messageCreatorName setTextColor:[UIColor lightGrayColor]];
        [messageCreatorName setFont:[UIFont systemFontOfSize:11]];
        [cell.contentView addSubview:messageCreatorName];
        
        UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 0, 25, 25)];
        img.image = [UIImage imageNamed:@"ManSilhouette"];
        //img.image = currentFriend.profilePic;
        [cell.contentView addSubview:img];
    }
    else{
        UILabel *currentMessageHeader = [[UILabel alloc] initWithFrame:CGRectMake(self.chatMessageTable.frame.size.width - (message_pixel_length) -  (self.chatMessageTable.frame.size.width/30), 0, message_pixel_length, message_pixel_height)];
        
        //currentMessageHeader.numberOfLines = 0;
        currentMessageHeader.layer.cornerRadius = 5;
        currentMessageHeader.layer.masksToBounds = YES;
        
        if([_chatMessages[indexPath.row] new_message]){
            UIColor *self_message_color = [UIColor blackColor];
        }
        else{
            UIColor *self_message_color = [CenterViewController colorWithHexString:[NSString stringWithFormat:@"%s",BORDER_COLOR]];
        }
        
        UIColor *self_message_color = [CenterViewController colorWithHexString:[NSString stringWithFormat:@"%s",BORDER_COLOR]];
        //UILabel *currentMessageHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.chatMessageTable.frame.size.width - 10, 21)];

        currentMessageHeader.text = [currentMessage message];
        currentMessageHeader.numberOfLines = 0;
        //[currentMessageHeader sizeToFit];
        [currentMessageHeader setFont:[UIFont systemFontOfSize:13]];
        currentMessageHeader.textColor = [UIColor whiteColor];
        currentMessageHeader.backgroundColor = self_message_color;
        [cell.contentView addSubview:currentMessageHeader];
        
    }
    
    //UIView * lineRemoval = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height, cell.frame.size.width, 1)];
    //[cell addSubview:lineRemoval];
    //cell = [self clearCell:cell];
    //cell.textLabel.text = [_chatMessages[indexPath.row] message];
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
