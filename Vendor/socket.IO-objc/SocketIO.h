//
//  SocketIO.h
//  v.01
//
//  based on 
//  socketio-cocoa https://github.com/fpotter/socketio-cocoa
//  by Fred Potter <fpotter@pieceable.com>
//
//  using
//  https://github.com/erichocean/cocoa-websocket
//  http://regexkit.sourceforge.net/RegexKitLite/
//  https://github.com/stig/json-framework/
//  http://allseeing-i.com/ASIHTTPRequest/
//
//  reusing some parts of
//  /socket.io/socket.io.js
//
//  Created by Philipp Kyeck http://beta_interactive.de
//

#import <Foundation/Foundation.h>

@class WebSocket;
@class SocketIO;
@class SocketIOPacket;


@protocol SocketIODelegate <NSObject>
@optional
- (void) socketIODidConnect:(SocketIO *)socket;
- (void) socketIODidDisconnect:(SocketIO *)socket;
- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet;
- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet;
- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet;
- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet;
- (void) socketIOhandshakeFailed:(SocketIO *)socket;
- (void) socketIOconnectionFailed:(SocketIO *)scket;
@end


@interface SocketIO : NSObject 
{
    @private
    NSString *_host;
    NSInteger _port;
    NSString *_sid;
    
    id<SocketIODelegate> _delegate;
    
    WebSocket *_webSocket;
    
    BOOL _isConnected;
    BOOL _isConnecting;
    BOOL _isSSL;
    
    // heartbeat
    NSTimeInterval _heartbeatTimeout;
    NSTimer *_timeout;
    
    NSMutableArray *_queue;
    
    // acknowledge
    NSMutableDictionary *_acks;
    NSInteger _ackCount;
}

- (id) initWithDelegate:(id<SocketIODelegate>)delegate;
- (void) connectToHost:(NSString *)host onPort:(NSInteger)port withSSL:(BOOL)ssl;
- (void) disconnect;

- (void) sendMessage:(NSString *)data;
- (void) sendMessage:(NSString *)data withAcknowledge:(SEL)function;
- (void) sendJSON:(NSDictionary *)data;
- (void) sendJSON:(NSDictionary *)data withAcknowledge:(SEL)function;
- (void) sendEvent:(NSString *)eventName withData:(NSDictionary *)data;
- (void) sendEvent:(NSString *)eventName withData:(NSDictionary *)data andAcknowledge:(SEL)function;

@end


@interface SocketIOPacket : NSObject
{
    NSString *type;
    NSString *pId;
    NSString *ack;
    NSString *name;
    NSString *data;
    NSArray *args;
    
    @private
    NSArray *_types;
}

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *pId;
@property (nonatomic, copy) NSString *ack;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *data;
@property (nonatomic, copy) NSArray *args;

- (id) initWithType:(NSString *)packetType;
- (id) initWithTypeIndex:(int)index;
- (id) dataAsJSON;
- (NSNumber *) typeAsNumber;
- (NSString *) typeForIndex:(int)index;

@end