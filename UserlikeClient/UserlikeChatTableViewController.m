//
//  UserlikeClient
//
//  Created by David on 10/5/11.
//  Copyright 2011 Devcores. All rights reserved.
//
//  Based on PTConversation by Lasha Dolidze 
//  Copyright 2010 Picktek LLC. All rights reserved.

#import "UserlikeChatTableViewController.h"


@implementation UserlikeChatTableViewController

@synthesize delegate;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:219.0/255.0 green:226.0/255.0 blue:237.0/255.0 alpha:1.0];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.delegate messageCount:self];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UserlikeChatViewCell *cell = (UserlikeChatViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UserlikeChatViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    
    UserlikeChatMessage *message = [self.delegate messageAt:self row:indexPath.row];    
    cell.chatMessage = message;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    
    UserlikeChatMessage *message = [self.delegate messageAt:self row:indexPath.row];
     
    NSString *text = message.text;
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14.0] 
                   constrainedToSize:CGSizeMake(210.0f, 480.0f) 
                       lineBreakMode:UILineBreakModeWordWrap];
 
    // Calculate cell height
    CGFloat calculatedHeight = size.height;

    if([message operatorImage] != nil) {
        if(size.height < message.operatorImage.size.height) {
            calculatedHeight = message.operatorImage.size.height;
        }
    }
    
    return calculatedHeight + 45.0f;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    
}


- (void)dealloc {
    [super dealloc];
}


@end

