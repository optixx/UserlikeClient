//
//  UserlikeSlot.m
//  UserlikeClient
//
//  Created by David on 10/5/11.
//  Copyright 2011 Devcores. All rights reserved.
//

#import "UserlikeSlot.h"
#import "ULLog.h"
#import "SocketIO.h"
#import "ASIS3Request.h"
#import "SBJson.h"
#import "UserlikeLocationController.h"

@implementation UserlikeSlot

@synthesize delegate;
@synthesize slot;
@synthesize operator;
@synthesize applicationConfig;
@synthesize applicationStorage;

#define kApplicationConfig @"UserlikeApplicationConfig.plist"
#define kStorage @"UserlikeStorage.plist"


- (BOOL)transferPlistToDocumentDirectory:(NSString*)fileName {
    NSError **error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName]; 
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath: path])
    {
        NSString *bundle =  [[ NSBundle mainBundle] pathForResource:[fileName stringByDeletingPathExtension] ofType:[fileName pathExtension]];
        [fileManager copyItemAtPath:bundle toPath:path error:error];

        return YES;
    }
    return NO;
}
- (NSString *)applicationConfigFilePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:kApplicationConfig];
}

- (NSString *)applicationStorageFilePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:kStorage];
}

- (void)saveApplicationStorage
{
	ULLog(@"Save applicationStorage");
    [applicationStorage writeToFile:[self applicationStorageFilePath] atomically:YES];
}

- (id)init
{
    socketIO = [[SocketIO alloc] initWithDelegate:self];
    
    [self transferPlistToDocumentDirectory:kApplicationConfig];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self applicationConfigFilePath]]) {
		applicationConfig = [[NSDictionary alloc] initWithContentsOfFile:[self applicationConfigFilePath]];
    } else {
        ULLog(@"Error opening application config");
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self applicationStorageFilePath]]) {
        applicationStorage = [[NSMutableDictionary alloc] initWithContentsOfFile:[self applicationStorageFilePath]];
    } else {
        ULLog(@"Creating inital Storage");
        applicationStorage = [[NSMutableDictionary alloc] init];
        [self.applicationStorage setObject:@"" forKey:@"uuid"];
        [self.applicationStorage setObject:@"" forKey:@"session"];
        [self.applicationStorage setObject:@"" forKey:@"ip"];
        [self.applicationStorage setObject:[NSNumber numberWithInt:0]  forKey:@"visits"];
        [self.applicationStorage setObject:[NSNumber numberWithDouble:0.0f] forKey:@"latitude"];
        [self.applicationStorage setObject:[NSNumber numberWithDouble:0.0f] forKey:@"longitude"];
    }
    sendNotifications = NO;
    locationController = [[UserlikeLocationController alloc] init];
    locationController.delegate = self;
	[locationController.locationManager startUpdatingLocation];
    return self;
}


#pragma mark -
- (void)viewDidLoad {
	
    
	
}

- (void)locationUpdate:(CLLocation *)location {
    ULLog(@"%@",[location description]);
    [self.applicationStorage setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"latitude"];
    [self.applicationStorage setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"longitude"];
    [self saveApplicationStorage];
}

- (void)locationError:(NSError *)error {
	ULLog(@"%@",[error description]);
}

- (void) handlePacket:(NSMutableDictionary*)dict
{
    ULLog(@"dict=%@", dict);
    // Error
    if ([[dict objectForKey:@"error"] isEqualToString: @"NO_SLOT"]) {
        [self.delegate chatSlotAvailable:NO with:NSLocalizedString(@"No Operator available.",@"")];
    }
    else if ([[dict objectForKey:@"error"] isEqualToString: @"ERR_CLIENTINFO"]) {
        [self.delegate chatSlotAvailable:NO with:NSLocalizedString(@"No Operator available.",@"")];
    }
    else if ([dict objectForKey:@"error"] != nil) {
        [self.delegate chatSlotAvailable:NO with:NSLocalizedString(@"No Operator available.",@"")];
    }
    
    // UUID
    if ([dict objectForKey:@"uuid"] != nil) {
        if ([self.applicationStorage objectForKey:@"uuid"] == nil || 
            ![[self.applicationStorage objectForKey:@"uuid"] length]){ 
            ULLog(@"Set UUID");
            [self.applicationStorage setObject:[dict objectForKey:@"uuid"] forKey:@"uuid"];
            [self saveApplicationStorage];
        }
    }
    // Session
    if ([dict objectForKey:@"session"] != nil) {
        ULLog(@"Set session");
        [self.applicationStorage setObject:[dict objectForKey:@"session"] forKey:@"session"];
        [self saveApplicationStorage];
    }
    // Inital Slot
    if ([dict objectForKey:@"slot"] != nil && [dict objectForKey:@"operator"] != nil) {
        self.operator = [dict objectForKey:@"operator"];
        self.slot = [dict objectForKey:@"slot"];
        if ([self.operator objectForKey:@"name"] != nil) {
            ULLog(@"Got slot");
            NSString *welcomeMessage = [NSString stringWithFormat:NSLocalizedString(@"You are talking to %@.",@""), [self.operator objectForKey:@"name"]];
            NSString *imageURL = [NSString stringWithFormat:@"http://%@", [self.operator objectForKey:@"url_image_small"]];
            [self.delegate receivedChatSlotWithMessage:welcomeMessage image:imageURL];
        }
    }
    // Replace Slot
    if ([[dict objectForKey:@"name"] isEqualToString: @"slot"]) {
        if ([dict objectForKey:@"args"] != nil){
            if ([[dict objectForKey:@"args"] isKindOfClass:[NSMutableArray class]] &&
                [[dict objectForKey:@"args"] objectAtIndex:0]!=nil) {
                if ([[[dict objectForKey:@"args"] objectAtIndex:0] objectForKey:@"slot"] != nil && 
                    [[[dict objectForKey:@"args"] objectAtIndex:0]  objectForKey:@"operator"] !=nil){
    
                    self.operator = [[[dict objectForKey:@"args"] objectAtIndex:0] objectForKey:@"operator"]; 
                    self.slot = [[[dict objectForKey:@"args"] objectAtIndex:0] objectForKey:@"slot"];
                    NSString *welcomeMessage = [NSString stringWithFormat:NSLocalizedString(@"You are talking to %@.",@""), [self.operator objectForKey:@"name"]];
                    NSString *imageURL = [NSString stringWithFormat:@"http://%@", [self.operator objectForKey:@"url_image_small"]];
                    [self.delegate receivedChatSlotWithMessage:welcomeMessage image:imageURL];
                }
            }
        }
        
    }
    // Message
    if ([[dict objectForKey:@"name"] isEqualToString: @"message"]) {
        
        if ([dict objectForKey:@"args"] != nil){
            if ([[dict objectForKey:@"args"] isKindOfClass:[NSMutableArray class]] &&
                [[dict objectForKey:@"args"] objectAtIndex:0]!=nil) {
                if ([[[dict objectForKey:@"args"] objectAtIndex:0] objectForKey:@"body"] != nil && 
                    [[[dict objectForKey:@"args"] objectAtIndex:0]  objectForKey:@"from"]){
                    [self.delegate receivedChatMessage:[[[dict objectForKey:@"args"] objectAtIndex:0] objectForKey:@"body"]
                                               from:[[[dict objectForKey:@"args"] objectAtIndex:0] objectForKey:@"from"]];
                
                }
            }
        }
    }
    // Push
    if ([[dict objectForKey:@"name"] isEqualToString: @"push"]) {
        
        if ([dict objectForKey:@"args"] != nil){
            if ([[dict objectForKey:@"args"] isKindOfClass:[NSMutableArray class]] &&
                [[dict objectForKey:@"args"] objectAtIndex:0]!=nil) {
                if ([[[dict objectForKey:@"args"] objectAtIndex:0] objectForKey:@"url"] != nil){
                    [[UIApplication sharedApplication] openURL:
                     [NSURL URLWithString:[[[dict objectForKey:@"args"] objectAtIndex:0] objectForKey:@"url"]]];                                             
                }
            }
        }
    }
    // Quit
    if ([[dict objectForKey:@"name"] isEqualToString: @"quit"]) {
        ULLog(@"Handle quit command");
        [self disconnectFromChatServerWithNotification:YES];
    }

}



#pragma mark -
#pragma mark SocketIODelegate

- (void) socketIOhandshakeFailed:(SocketIO *)socket{
    if (sendNotifications && [self.delegate respondsToSelector:@selector(chatServerConnectionError:)] ){
        [self.delegate chatServerConnectionError:NSLocalizedString(@"Connection error.",@"")];
    }
}    

- (void) socketIOconnectionFailed:(SocketIO *)socket{
    if (sendNotifications && [self.delegate respondsToSelector:@selector(chatServerConnectionError:)]){
        [self.delegate chatServerConnectionError:NSLocalizedString(@"Connection error.",@"")];
    }
}

- (void) callbackWithData:(NSMutableDictionary*)dict
{
    [self handlePacket:dict];
}


- (void) socketIODidConnect:(SocketIO *)socket
{
    ULLog(@" >>> socket: %@", socket);
    if (sendNotifications && [self.delegate respondsToSelector:@selector(connectedToChatServer)]){
        [self.delegate connectedToChatServer];
    }
}

- (void) socketIODidDisconnect:(SocketIO *)socket
{
    ULLog(@" >>> socket: %@", socket);
    if (sendNotifications && [self.delegate respondsToSelector:@selector(disconnectedFromChatServer:)]){
        [self.delegate disconnectedFromChatServer:NSLocalizedString(@"Connection terminated.",@"")];
    }

}

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet
{
    ULLog(@" >>> data: %@", packet.data);
    [self handlePacket: [packet dataAsJSON]];
}

- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet
{
    ULLog(@" >>> data: %@", packet.data);
    [self handlePacket: [packet dataAsJSON]];
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    ULLog(@" >>> data: %@", packet.data);
    [self handlePacket: [packet dataAsJSON]];
}

- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet
{
    ULLog(@" >>> data: %@", packet.data);
    [self handlePacket: [packet dataAsJSON]];
}

#pragma mark -
#pragma mark Connection handling


- (void)disconnectFromChatServerWithNotification:(BOOL)notify;
{
    sendNotifications = notify;
    [socketIO disconnect];
}

- (void)connectToChatServer
{
    sendNotifications = YES;
    int visits = [[applicationStorage objectForKey:@"visits"] intValue] + 1; 
    [applicationStorage setObject:[NSNumber numberWithInt:visits] forKey:@"visits"];  
    [self performSelector:@selector(checkChatSlotAvailable) withObject:nil afterDelay:0.5f];
}

- (void)checkChatSlotAvailable {
    
    NSMutableDictionary *packet = [NSMutableDictionary dictionary];
    [packet setObject:[applicationConfig objectForKey:@"widget_key"] forKey:@"widget_key"];
    [packet setObject:[applicationConfig objectForKey:@"app_key"]  forKey:@"app_key"];
    NSURL *url;
    if ([[applicationConfig  objectForKey:@"support_ssl"] boolValue]){
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/api/slot/available",  
                                       [applicationConfig objectForKey:@"domain_api"]]];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/api/slot/available",  
                                    [applicationConfig objectForKey:@"domain_api"]]];
    }
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    //[request setValidatesSecureCertificate:NO];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request appendPostData:[packet.JSONRepresentation dataUsingEncoding:NSUTF8StringEncoding]];
    [request setRequestMethod:@"POST"];
    [request startSynchronous];
    NSError *error = [request error];
    
    if (!error) {
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSDictionary * response = [jsonParser objectWithString:[request responseString]];
        [jsonParser release];
        if ([response objectForKey:@"ip"] != nil) {
            [self.applicationStorage setObject:[response objectForKey:@"ip"] forKey:@"ip"];
            [self saveApplicationStorage];
        }
        ULLog(@"Response=%@", response);
        if ([[response objectForKey:@"error"] isEqualToString: @"NO_SLOT"]) {
            [self.delegate chatSlotAvailable:NO with:NSLocalizedString(@"No Operator available.",@"")];
        } else if ([response objectForKey:@"error"] !=nil) {
            [self.delegate chatSlotAvailable:NO with:NSLocalizedString(@"No Operator available.",@"")];
        } else {
            [self createNewChatSlot];
        }
    } else {
        ULLog(@"HTTP Request Error") ;
        if ([self.delegate respondsToSelector:@selector(chatServerConnectionError:)]){
            [self.delegate chatServerConnectionError:NSLocalizedString(@"Connection error.",@"")];
        }
    }    
}

- (void)createNewChatSlot
{
    if ([[applicationConfig  objectForKey:@"support_ssl"] boolValue]){
        [socketIO connectToHost:[applicationConfig objectForKey:@"domain_socketio"] onPort:
         [[applicationConfig  objectForKey:@"socketio_port_ssl"]intValue] withSSL:YES];
    } else {
        [socketIO connectToHost:[applicationConfig objectForKey:@"domain_socketio"] onPort:
         [[applicationConfig  objectForKey:@"socketio_port_http"]intValue] withSSL:NO];
    }
        
    NSLocale *locale = [NSLocale currentLocale]; 
    NSMutableDictionary *clientinfo = [NSMutableDictionary dictionary];
    [clientinfo setObject:[applicationStorage objectForKey:@"session"] forKey:@"session"];
    [clientinfo setObject:[applicationStorage objectForKey:@"uuid"] forKey:@"client_uuid"];
    [clientinfo setObject:[applicationStorage objectForKey:@"visits"] forKey:@"visits"];
    [clientinfo setObject:[applicationStorage objectForKey:@"ip"] forKey:@"ip"];
    [clientinfo setObject:[locale localeIdentifier] forKey:@"locale"];
    [clientinfo setObject:[[UIDevice currentDevice] model] forKey:@"ios_model"];
    [clientinfo setObject:[[UIDevice currentDevice] systemVersion] forKey:@"ios_system_version"];
    [clientinfo setObject:[[UIDevice currentDevice] name] forKey:@"ios_name"];
    [clientinfo setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"ios_uid"];
    [clientinfo setObject:[applicationStorage objectForKey:@"longitude"] forKey:@"ios_longitude"];
    [clientinfo setObject:[applicationStorage objectForKey:@"latitude"]  forKey:@"ios_latitude"];
    
    
    NSMutableDictionary *packet = [NSMutableDictionary dictionary];
    [packet setObject:clientinfo forKey:@"clientinfo"];
    [packet setObject:[applicationConfig objectForKey:@"widget_key"] forKey:@"widget_key"];
    [packet setObject:[applicationConfig objectForKey:@"app_key"]  forKey:@"app_key"];

    
    SEL selc = @selector(callbackWithData:);
    [socketIO sendEvent:@"create" withData:packet andAcknowledge:selc];
}

- (void)sendChatMessage:(NSString*)bodyText
{
    [socketIO sendEvent:@"message" withData:bodyText andAcknowledge:nil];
}


- (void)dealloc {
    [socketIO release];
    [slot release];
    [operator release];
    [applicationStorage release];
    [applicationConfig release];
    [super dealloc];
}

@end

