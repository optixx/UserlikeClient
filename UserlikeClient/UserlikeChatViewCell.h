//
//  UserlikeClient
//
//  Created by David on 10/5/11.
//  Copyright 2011 Devcores. All rights reserved.
//
//  Based on PTConversation by Lasha Dolidze 
//  Copyright 2010 Picktek LLC. All rights reserved.

#import <UIKit/UIKit.h>
#import "UserlikeChatMessage.h"

#define IMAGE_WIDTH     60.0f
#define IMAGE_HEIGHT    60.0f


@interface UserlikeChatViewCell : UITableViewCell {

    UIImageView *bubbleView;
    UILabel     *label;
    UILabel     *labelTimeStamp;
    UIImageView *operatorImageView;
    
    UserlikeChatMessage *chatMessage;
}

@property (nonatomic,retain) UIImageView *bubbleView;
@property (nonatomic,retain) UILabel     *label;
@property (nonatomic,retain) UILabel     *labelTimeStamp;
@property (nonatomic,retain) UIImageView *operatorImageView;

@property (nonatomic,retain) UserlikeChatMessage *chatMessage;

@end
