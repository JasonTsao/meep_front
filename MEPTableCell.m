//
//  MEPTableCell.m
//  Meep_IOS
//
//  Created by Ryan Sharp on 5/21/14.
//  Copyright (c) 2014 futoi. All rights reserved.
//

#import "MEPTableCell.h"
#import "Colors.h"
#import "MEPTextParse.h"
#import "MEPLocationService.h"
#import "ImageCache.h"

#define FRIEND_MAIN_TEXT_COLOR "000000"
#define FRIEND_HEADER_TEXT_COLOR "ffffff"
#define FRIEND_SEPARATOR_BACKGROUND_COLOR "000000"
#define FRIEND_TABLE_BACKGROUND_COLOR "000000"


#define BORDER_WIDTH 1
#define LINE_WIDTH 1
#define BORDER_COLOR "ffffff"
#define LINE_COLOR "ffffff"
#define STATIC_IMAGE_COLOR "ffffff"
#define TABLE_BACKGROUND_COLOR "ffffff"
#define HEADER_TEXT_COLOR "000000"
#define CONTENT_BACKGROUND_COLOR "ffffff"
#define ICON_BACKGROUND_COLOR "000000"
#define MAIN_TEXT_COLOR "000000"
#define NAV_BAR_COLOR "ffffff"
#define RECIEVED_NOTIFICATION_COLOR "#FF0000"


//also defined in CenterPanelViewController
#define TABLE_SECTION_HEADER_BACKGROUND_COLOR "FFFFFF"
#define TABLE_SECTION_HEADER_TEXT_COLOR "019875"

#define TABLE_DATA_BACKGROUND_COLOR "3FC380"
#define TABLE_DATA_TEXT_COLOR "FFFFFF"

#define CELL_SELECT_COLOR "89C4F4"


@implementation MEPTableCell

+(UIView*)eventCell:(Event*)event userLatitude:(float)lat userLongitude:(float)lng hasNotification:(BOOL)notification{
    // UITableViewCell * cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
    UIView * cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
    NSString * description = event.description;
    NSString * category = [MEPTextParse identifyCategory:description];
    NSString * imageFileName = @"tree60.png";
    if ([category isEqualToString:@"meal"]) {
        imageFileName = @"fork.png";
    }
    else if ([category isEqualToString:@"nightlife"]) {
        imageFileName = @"jumping2.png";
    }
    else if ([category isEqualToString:@"drinks"]) {
        imageFileName = @"glass16";
    }
    else if ([category isEqualToString:@"meeting"]) {
        imageFileName = @"communities.png";
    }
    else if ([category isEqualToString:@"outdoors"]) {
        imageFileName = @"sun23.png";
    }
    
    UIImage * image = [UIImage imageNamed:imageFileName];
    float imageHeight = 40;
    float imageXCoord = 8;
    float imageYCoord = (cell.frame.size.height/2) - (imageHeight/2);
    float bgndImgScale = BORDER_WIDTH;
    float lineWeight = LINE_WIDTH;
    UIColor * framingColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",BORDER_COLOR]];
    UIColor * lineColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",LINE_COLOR]];
    UIColor * staticImageColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",STATIC_IMAGE_COLOR]];
    float vertLineXCoord = (imageHeight/2) + imageXCoord;
    float contentBoxXCoord = imageXCoord + imageHeight + 12;
    float contentBoxYCoord = 12;
    float contentBoxWidth = cell.frame.size.width - contentBoxXCoord - 15;
    float contentBoxHeight = cell.frame.size.height - (contentBoxYCoord * 2);
    UIColor * backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",TABLE_BACKGROUND_COLOR]];
    UIColor * contentBackgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",CONTENT_BACKGROUND_COLOR]];
    UIColor * iconBackgroundColor;
    
    if(notification){
        //iconBackgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",RECIEVED_NOTIFICATION_COLOR]];
        iconBackgroundColor = [UIColor redColor];
    }
    else{
        iconBackgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",ICON_BACKGROUND_COLOR]];
    }
    
    
    cell.backgroundColor = backgroundColor;
    
    // This view covers the line separator between the cells.
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 1, cell.frame.size.width, 1)];
    separatorLineView.backgroundColor = backgroundColor;
    [cell addSubview:separatorLineView];
    
    // This view creates the vertical line that lies behind the image.

    //UIView * verticalLine = [[UIView alloc] initWithFrame:CGRectMake(vertLineXCoord + 1, 0, bgndImgScale, cell.frame.size.height)];
    UIView * verticalLine = [[UIView alloc] initWithFrame:CGRectMake(-5, 0, bgndImgScale, cell.frame.size.height)];
    
    verticalLine.backgroundColor = lineColor;
    [cell addSubview:verticalLine];
    
    // This view creates the horizontal line between the image and the content frames.
    
    //(cell.frame.size.width/2)
    UIView * horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(21, (cell.frame.size.height/2), 52, lineWeight)];
    horizontalLine.backgroundColor = lineColor;
    
    //horizontal line gradient
    CAGradientLayer *horizontalLineGradient = [CAGradientLayer layer];
    horizontalLineGradient.frame = CGRectMake(0, 0, horizontalLine.frame.size.width, horizontalLine.frame.size.height);
    [horizontalLineGradient setStartPoint:CGPointMake(0.5, 0.5)];
    [horizontalLineGradient setEndPoint:CGPointMake(1.0, 0.5)];
    horizontalLineGradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], [[UIColor blackColor] CGColor], nil];
    
    
    //[_bannerView.layer addSublayer:gradient];
    
    [horizontalLine.layer addSublayer:horizontalLineGradient];
    [cell addSubview:horizontalLine];
    
    
    // This view creates the black background which the image and mid ground line on top of.
    UIView * imageBackGround = [[UIView alloc] initWithFrame:CGRectMake(imageXCoord - bgndImgScale, imageYCoord - bgndImgScale, imageHeight + (bgndImgScale*2), imageHeight + (bgndImgScale*2))];
    imageBackGround.layer.cornerRadius = 21;
    imageBackGround.backgroundColor = framingColor;
    [cell addSubview:imageBackGround];
    
    // This view creates the white background for the image.
    UIView * imageBackMid = [[UIView alloc] initWithFrame:CGRectMake(imageXCoord, imageYCoord, imageHeight, imageHeight)];
    imageBackMid.backgroundColor = iconBackgroundColor;
    imageBackMid.layer.cornerRadius = 20;
    [cell addSubview:imageBackMid];
    
    // This view creates uses the image provided in the parameters to display the image on top of the background and midground
    UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(imageXCoord + 10, imageYCoord + 10, imageHeight - 20, imageHeight - 20)];
    if (![event.yelpImageLink isEqual:[NSNull null]] && [event.yelpImageLink length] > 1 && YES) {
        // OLD CODE FOR GETTING IMAGES FROM AN OUTSIDE SOURCE.
        // DO THIS ON THE TABLE ITSELF NOW
        /*img = [[UIImageView alloc] initWithFrame:CGRectMake(imageXCoord-0.75, imageYCoord-0.75, imageHeight+1.5, imageHeight+1.5)];
        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:event.yelpImageLink]]];
        img.layer.masksToBounds = imageHeight/2;*/
    }
    else {
        CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextClipToMask(context, rect, image.CGImage);
        CGContextSetFillColorWithColor(context, [staticImageColor CGColor]);
        CGContextFillRect(context, rect);
        UIImage *image2 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        image = [UIImage imageWithCGImage:image2.CGImage scale:1.0 orientation: UIImageOrientationDownMirrored];
    }
    img.image = image;
    img.layer.cornerRadius = imageHeight/2;
    //img.layer.masksToBounds = YES;
    [cell addSubview:img];

    // This view creates the background for the content
    /*UIView * contentFrame = [[UIView alloc] initWithFrame:CGRectMake(contentBoxXCoord - bgndImgScale, contentBoxYCoord - bgndImgScale + 1, contentBoxWidth + (bgndImgScale*2) - 2, contentBoxHeight + (bgndImgScale*2) - 2)];
    contentFrame.layer.cornerRadius = 6;
    contentFrame.backgroundColor = framingColor;
    // [cell addSubview:contentFrame];*/
    
    // This view contains the data fields and is placed on top of the background view.
    
    //
    //    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(contentBoxXCoord, contentBoxYCoord, contentBoxWidth, contentBoxHeight)];
    //    contentView.backgroundColor = contentBackgroundColor;
    //    contentView.layer.cornerRadius = 0;
    
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(contentBoxXCoord+12, contentBoxYCoord, contentBoxWidth, contentBoxHeight)];
    contentView.backgroundColor = contentBackgroundColor;
    contentView.layer.cornerRadius = 0;
    
    //label position
    //    float detailXCoord = 10;
    //    float detailYCoord = contentView.frame.size.height * 6/8 - 5;
    
    float detailXCoord = 10;
    float detailYCoord = contentView.frame.size.height * 6/8 - 5;
    UILabel * eventDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(detailXCoord, detailYCoord, (contentView.frame.size.width/2 ) - 20, 21)];
    
    NSTimeInterval startedTime = [event.start_time doubleValue];
    NSDate *startedDate = [[NSDate alloc] initWithTimeIntervalSince1970:startedTime];
    NSString * eventDateMessage = [MEPTextParse getTimeUntilDateTime:startedDate];
    
    eventDetailLabel.text = eventDateMessage;
    eventDetailLabel.textColor = [Colors colorWithHexString:[NSString stringWithFormat:@"#95a5a6"]];
    [eventDetailLabel setFont:[UIFont systemFontOfSize:8.5]];
    [contentView addSubview:eventDetailLabel];
    
    UILabel *eventHeader = [[UILabel alloc] initWithFrame:CGRectMake(8, 3, contentView.frame.size.width - 12, 40)];
    eventHeader.text = event.description;
    // [eventHeader setFont:[UIFont systemFontOfSize:14]];
    
    [eventHeader setFont:[UIFont fontWithName:@"AppleSDGothicNeo-Light" size:14.0f]];
    
    
    
    
    eventHeader.lineBreakMode = NSLineBreakByWordWrapping;
    eventHeader.numberOfLines = 0;
    eventHeader.textColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",MAIN_TEXT_COLOR]];
    [contentView addSubview:eventHeader];
    
    if (![event.locationLongitude isEqual:[NSNull null]]) {
        UILabel *distance = [[UILabel alloc] initWithFrame:CGRectMake(0, detailYCoord, (contentView.frame.size.width) - 6, 21)];
        NSString * distanceInMiles = [MEPLocationService distanceBetweenCoordinatesWithLatitudeOne:lat longitudeOne:lng latitudeTwo:[event.locationLatitude floatValue] longitudeTwo:[event.locationLongitude floatValue]];
        distance.text = distanceInMiles;
        distance.textColor = [Colors colorWithHexString:[NSString stringWithFormat:@"#95a5a6"]];
        [distance setFont:[UIFont systemFontOfSize:8.5]];
        distance.textAlignment = NSTextAlignmentRight;
        [contentView addSubview:distance];
    }
    [cell addSubview:contentView];
    
    return cell;
}

+(UIView*)eventHeaderCell:(NSString*)dateText {
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 22)];
    UIColor * framingColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",BORDER_COLOR]];
    
    UIView * horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(28, headerView.frame.size.height/2 + 1 - (BORDER_WIDTH/2), headerView.frame.size.width/-28, BORDER_WIDTH)];
    horizontalLine.backgroundColor = framingColor;
    UIView * verticalLine = [[UIView alloc] initWithFrame:CGRectMake(30 - BORDER_WIDTH, 0, BORDER_WIDTH, headerView.frame.size.height)];
    verticalLine.backgroundColor = framingColor;
    UIView * headerContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, headerView.frame.size.height)];
    UILabel * headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerContainer.frame.size.width - 15, headerContainer.frame.size.height)];
    headerTitle.textAlignment = NSTextAlignmentRight;
    // headerContainer.backgroundColor = [UIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.f];
    headerTitle.text = dateText;
    // [headerTitle setFont:[UIFont fontWithName:@"GurmukhiMN" size:10]];
    // headerTitle.textColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",HEADER_TEXT_COLOR]];
    [headerContainer addSubview:headerTitle];
    
    [headerView addSubview:headerContainer];
    [headerView addSubview:verticalLine];
    // [headerView addSubview:horizontalLine];
    headerView.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",TABLE_BACKGROUND_COLOR]];
    
    return headerView;
}

+ (CGFloat) customFriendCellHeight
{
    return 60;
}

+ (CGFloat) customLeftPanelBarHeight
{
    return 70;
}

+ (UITableViewCell*) customFriendCell:(Friend*)friend
                             forTable:(UITableView*)tableView
                             selected:(BOOL)sel {
    UITableViewCell * cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 54)];
    cell.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",FRIEND_TABLE_BACKGROUND_COLOR]];
    UIView * lineMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 1)];
    lineMask.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",FRIEND_SEPARATOR_BACKGROUND_COLOR]];
    [cell addSubview:lineMask];
    UIView * cellContents = [[UIView alloc] initWithFrame:CGRectMake(3, 3, cell.frame.size.width - 6, cell.frame.size.height + 6)];
    if (!sel) {
        cellContents.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",TABLE_BACKGROUND_COLOR]];
    }
    else {
        cellContents.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",FRIEND_MAIN_TEXT_COLOR]];
    }
    cellContents.layer.cornerRadius = 10;
    UILabel *friendHeader = [[UILabel alloc] initWithFrame:CGRectMake(60, 14, 235, 21)];
    friendHeader.text = friend.name;
    friendHeader.textColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",FRIEND_HEADER_TEXT_COLOR]];
    [friendHeader setFont:[UIFont systemFontOfSize:18]];
    [cellContents addSubview:friendHeader];
    UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 40, 40)];
    img.image = friend.profilePic;
    img.layer.cornerRadius = img.frame.size.height/2;
    img.layer.masksToBounds = YES;
    [cellContents addSubview:img];
    [cell addSubview:cellContents];
    return cell;
}

+ (UITableViewCell*) customGroupCell:(Group*)group forCell:(UITableViewCell*)cell forTable:(UITableView*)tableView selected:(BOOL)sel
{
    UIView * lineSeparatorMask = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height-1, cell.frame.size.width, 1)];
    lineSeparatorMask.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",FRIEND_SEPARATOR_BACKGROUND_COLOR]];
    [cell addSubview:lineSeparatorMask];
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(3, 3, tableView.frame.size.width - 6, cell.frame.size.height - 6)];
    
    contentView.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",FRIEND_TABLE_BACKGROUND_COLOR]];
    contentView.layer.cornerRadius = 10;
    [contentView setTag:1];
    
    //Group *currentGroup = groups_list[indexPath.row];
    UILabel *groupHeader = [[UILabel alloc] initWithFrame:CGRectMake(60, 14, 235, 21)];
    groupHeader.text = group.name;
    groupHeader.textColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",FRIEND_HEADER_TEXT_COLOR]];
    [groupHeader setFont:[UIFont systemFontOfSize:18]];
    [contentView addSubview:groupHeader];
    UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 40, 40)];
    img.image = group.groupProfilePic;
    img.layer.cornerRadius = img.frame.size.height/2;
    img.layer.masksToBounds = YES;
    [contentView addSubview:img];
    [cell addSubview:contentView];
    return cell;
}


//invited friends collection cell view

+(UIView*) invitedFriendCell:(InvitedFriend*)friend {
    UIView * cell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 60)];
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, cell.frame.size.width - 4, cell.frame.size.width - 4)];
    imageView.image = friend.profilePic;
    imageView.layer.cornerRadius = imageView.frame.size.width/2;
    imageView.layer.masksToBounds = YES;
    [cell addSubview:imageView];
    
    UILabel * userName = [[UILabel alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 14, cell.frame.size.width, 14)];
    userName.text = friend.name;
    userName.textAlignment = NSTextAlignmentCenter;
    [userName setFont:[UIFont systemFontOfSize:10]];
    userName.textColor = [Colors colorWithHexString:@"FFFFFF"];
    [cell addSubview:userName];
    
    return cell;
}

+ (UITableViewCell*) customNotificationcell:(Notification*)notification
                             forTable:(UITableView*)tableView
                             selected:(BOOL)sel {
    UITableViewCell * cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 54)];
    cell.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",FRIEND_TABLE_BACKGROUND_COLOR]];
    UIView * lineMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 1)];
    lineMask.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",TABLE_BACKGROUND_COLOR]];
    [cell addSubview:lineMask];
    UIView * cellContents = [[UIView alloc] initWithFrame:CGRectMake(3, 3, cell.frame.size.width - 6, cell.frame.size.height + 6)];
    if (!sel) {
        cellContents.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",FRIEND_TABLE_BACKGROUND_COLOR]];
    }
    else {
        cellContents.backgroundColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",CELL_SELECT_COLOR]];
    }
    cellContents.layer.cornerRadius = 10;
    UILabel *notificationHeader = [[UILabel alloc] initWithFrame:CGRectMake(60, 14, 235, 21)];
    notificationHeader.text = notification.message;
    notificationHeader.textColor = [Colors colorWithHexString:[NSString stringWithFormat:@"%s",FRIEND_HEADER_TEXT_COLOR]];
    [notificationHeader setFont:[UIFont systemFontOfSize:12]];
    [cellContents addSubview:notificationHeader];
    
    
    UIImageView * img = [[UIImageView alloc] initWithFrame:CGRectMake(8, 4, 40, 40)];
    img.image = [UIImage imageNamed:@"ManSilhouette"];
    img.layer.cornerRadius = img.frame.size.height/2;
    img.layer.masksToBounds = YES;
    [cellContents addSubview:img];
    
    
    [cell addSubview:cellContents];
    return cell;
}

@end
