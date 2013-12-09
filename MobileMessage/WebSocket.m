//
//  WebSocket.m
//  MobileMessage
//
//  Created by yangw on 13-6-1.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import "WebSocket.h"

@implementation WebSocket

static id instance = nil;

- (id)init {
    self = [super init];
    if (self) {
        _socket = [[SRWebSocket alloc] init];
    }
    return self;
}

+ (id)shareSocket {
    if (nil == instance) {
        instance = [[WebSocket alloc] init];
    }
    return instance;
}

+ (void)destory {
    if (instance) {
        [instance release];
        instance = nil;
    }
}

- (void)dealloc {
    [super dealloc];
}

@end
