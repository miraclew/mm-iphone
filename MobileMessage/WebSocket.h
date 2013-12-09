//
//  WebSocket.h
//  MobileMessage
//
//  Created by yangw on 13-6-1.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

@interface WebSocket : NSObject <SRWebSocketDelegate> {
    SRWebSocket * _socket;
}

+ (id)shareSocket;

- (void)connectWithUrl:(NSString *)url;
- (void)close;

@end
