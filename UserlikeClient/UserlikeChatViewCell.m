//
//  UserlikeClient
//
//  Created by David on 10/5/11.
//  Copyright 2011 Devcores. All rights reserved.
//
//  Based on PTConversation by Lasha Dolidze 
//  Copyright 2010 Picktek LLC. All rights reserved.

#import "UserlikeChatViewCell.h"


@implementation UserlikeChatViewCell

@synthesize bubbleView,label,labelTimeStamp,operatorImageView,chatMessage;

- (NSString*)toConversationDateString:(NSDate *)date
{
    // Mar 9, 2010 1:22 PM
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *theString = [formatter stringFromDate:date];
    return theString;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
        // we get content view to place our ballon etc.
		UIView *myContentView = self.contentView;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
  
        // Create ballon view
        self.bubbleView = [[UIImageView alloc] init];
        
        // Create text lable
        self.label = [[UILabel alloc] init];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.numberOfLines = 0;
        self.label.lineBreakMode = UILineBreakModeWordWrap;
        self.label.font = [UIFont systemFontOfSize:14.0];
        
        // Create time stamp label
        self.labelTimeStamp = [[UILabel alloc] init];
        self.labelTimeStamp.backgroundColor = [UIColor clearColor];
        self.labelTimeStamp.textColor = [UIColor grayColor];
        self.labelTimeStamp.numberOfLines = 1;
        self.labelTimeStamp.lineBreakMode = UILineBreakModeWordWrap;
        self.labelTimeStamp.font = [UIFont boldSystemFontOfSize:12.0];
        
        
        // Create image view
        self.operatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT)];
        
        // Create message view (this is only container view for our controls)
        UIView *message = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        message.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        // Put all together

        [message addSubview:self.bubbleView];
        [message addSubview:self.operatorImageView];
        [message addSubview:self.label];
        [message addSubview:self.labelTimeStamp];
        
        // Add messge view in cell content view
        [myContentView addSubview:message];
        
        [self.bubbleView release];
        [self.label release];
        [self.operatorImageView release];
        [self.labelTimeStamp release];
        [message release];
    }
    
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}



/*
 this function will layout the subviews for the cell
 if the cell is not in editing mode we want to position them
 */
- (void)layoutSubviews {
    
    [super layoutSubviews];

	// getting the cell size
    CGRect contentRect = self.contentView.bounds;
	CGFloat leftImageMargin = 0;
    CGFloat leftTextMargin = 0;
    
    NSString *text = chatMessage.text;
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14.0] 
                   constrainedToSize:CGSizeMake(210.0f, 480.0f) 
                       lineBreakMode:UILineBreakModeCharacterWrap];
    
    NSString *textTime = [self toConversationDateString:chatMessage.date]; // e.g "Mar 9, 2010 1:22 PM";
    CGSize sizeTime = [textTime sizeWithFont:[UIFont systemFontOfSize:14.0] 
                           constrainedToSize:CGSizeMake(210.0f, 480.0f) 
                               lineBreakMode:UILineBreakModeCharacterWrap];

    if([chatMessage operatorImage] != nil) {
        if(size.height < chatMessage.operatorImage.size.height) {
            size.height = chatMessage.operatorImage.size.height;
        }     
        size.width += chatMessage.operatorImage.size.width + 15.0f;
        leftImageMargin = chatMessage.operatorImage.size.width + 7.0f;
        
        leftTextMargin = chatMessage.operatorImage.size.width + 4.0f;
    }
    
    UIImage *ballon;
    
    if (!self.editing) {
		    
        
        if(chatMessage.type == UserlikeChatMessageTypeOperatorTerminating) {
            
            ballon = [[UIImage imageNamed:@"UserlikeClient.bundle/images/bubble_blue.png"] 
                      stretchableImageWithLeftCapWidth:24.0 topCapHeight:15.0];
            
            self.bubbleView.frame = CGRectMake(contentRect.size.width - (size.width + 28.0f), 18.0f, size.width + 28.0f, size.height + 20.0f);
            self.bubbleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            
            self.label.frame = CGRectMake((contentRect.size.width - 13.0f) - (size.width + 5.0f), 8.0f, size.width + 5.0f - leftTextMargin, size.height + 35.0f);
            self.label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            
            self.operatorImageView.frame = CGRectMake((contentRect.size.width - 12.0f) - (IMAGE_WIDTH + 5.0f), 26.0f, IMAGE_WIDTH, IMAGE_HEIGHT);
            self.operatorImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;

            self.labelTimeStamp.frame = CGRectMake((contentRect.size.width - sizeTime.width) / 2, 0.0f, sizeTime.width + 5.0f, sizeTime.height);
            self.labelTimeStamp.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
            
        }
        else {
            
            ballon = [[UIImage imageNamed:@"UserlikeClient.bundle/images/bubble_grey.png"] 
                      stretchableImageWithLeftCapWidth:24.0 topCapHeight:15.0];;

            self.bubbleView.frame = CGRectMake(0.0, 18.0f, size.width + 28.0f, size.height + 20.0f);
            self.bubbleView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
            
            self.label.frame = CGRectMake(leftImageMargin + 16.0f, 8.0f, size.width + 5.0f, size.height + 35.0f);
            self.label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
            
            self.operatorImageView.frame = CGRectMake(16.0f, 26.0f, IMAGE_WIDTH, IMAGE_HEIGHT);
            self.operatorImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            
            self.labelTimeStamp.frame = CGRectMake((contentRect.size.width - sizeTime.width) / 2, 0.0f, sizeTime.width + 5.0f, sizeTime.height);
            self.labelTimeStamp.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
            
        }
        
	}
    
    
    self.bubbleView.image = ballon;
    self.label.text = text;
    self.operatorImageView.image = [chatMessage operatorImage];
    self.labelTimeStamp.text = textTime;
    
}


- (void)dealloc {
    [bubbleView release];
    [label release];
    [labelTimeStamp release];
    [operatorImageView release];
    [chatMessage release];
    [super dealloc];
}


@end
