//
//  PTConversationMessage.m
//  PTConversationView
//
//  Created by Lasha Dolidze on 4/22/10.
//  Copyright 2010 Picktek LLC. All rights reserved.
//

#import "UserlikeChatMessage.h"

@implementation UserlikeChatMessage

@synthesize text,operatorImage,type,date,tag;


+ (UserlikeChatMessage*)initWithText:(NSString*)text type:(UserlikeChatMessageType)type
{
    UserlikeChatMessage *instance = [[UserlikeChatMessage alloc] init];
    [instance setText:text];
    [instance setOperatorImage:nil];
    [instance setType:type];
    [instance setDate:[NSDate date]];
    return instance;
}

+ (UserlikeChatMessage*)initWithText:(NSString*)text type:(UserlikeChatMessageType)type operatorImage:(UIImage*)thumbnailImage
{
    UserlikeChatMessage *instance = [[UserlikeChatMessage alloc] init];
    [instance setText:text];
    [instance setOperatorImage:thumbnailImage];
    [instance setType:type];
    [instance setDate:[NSDate date]];
    return instance;
}


- (id)init
{
    self = [super init];    
    return self;
}

- (void)dealloc {
    [operatorImage release];
    [date release];
    [operatorImage release];
    [super dealloc];
}

@end
