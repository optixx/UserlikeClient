//
//  UserlikeClient
//
//  Created by David on 10/5/11.
//  Copyright 2011 Devcores. All rights reserved.
//
//  Based on PTConversation by Lasha Dolidze 
//  Copyright 2010 Picktek LLC. All rights reserved.

#import <UIKit/UIKit.h>


#define BAR_HEIGHT                 40.0f

#define BAR_SENDBUTTON_TAG         101
#define kPTEntryBarSendButtonTag   103

#define kSendButtonTitle                NSLocalizedString(@"Send", @"")

@interface BCZeroEdgeTextView : UITextView
@end



@protocol UserlikeChatBarViewControllerDelegate;

@interface UserlikeChatBarViewController : UIViewController <UITextViewDelegate> {
 

    id<UserlikeChatBarViewControllerDelegate> delegate;
    
    UIButton            *sendButton;
    BCZeroEdgeTextView  *textView;
    UIView              *contentView;
    
    
}

@property (nonatomic,assign) id<UserlikeChatBarViewControllerDelegate> delegate;
@property (nonatomic,retain) UIButton *sendButton;
@property (nonatomic,retain) BCZeroEdgeTextView  *textView;
@property (nonatomic,retain) UIView              *contentView;
@end


@protocol UserlikeChatBarViewControllerDelegate <NSObject>
- (BOOL)touchSend:(UserlikeChatBarViewController *)controller text:(NSString*)text;

@end