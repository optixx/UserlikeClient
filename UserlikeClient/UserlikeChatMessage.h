//
//  PTConversationMessage.h
//  PTConversationView
//
//  Created by Lasha Dolidze on 4/22/10.
//  Copyright 2010 Picktek LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


typedef enum {
    UserlikeChatMessageTypeClientTerminating = 0,
    UserlikeChatMessageTypeOperatorTerminating = 1,
} UserlikeChatMessageType;

@interface UserlikeChatMessage : NSObject {
    NSString                        *text;
    UIImage                         *operatorImage;
    NSDate                          *date;
    UserlikeChatMessageType       type;    
    int                             tag;
}

@property (nonatomic,copy) NSString *text;
@property (nonatomic,assign) UserlikeChatMessageType type;
@property (nonatomic,retain) UIImage  *operatorImage;
@property (nonatomic,retain) NSDate *date;
@property (nonatomic,assign) int  tag;


+ (UserlikeChatMessage*)initWithText:(NSString*)text type:(UserlikeChatMessageType)type;
+ (UserlikeChatMessage*)initWithText:(NSString*)text type:(UserlikeChatMessageType)type operatorImage:(UIImage*)thumbnailImage;
@end
