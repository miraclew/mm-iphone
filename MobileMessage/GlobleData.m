//
//  GlobleData.m
//  MobileMessage
//
//  Created by yangw on 13-6-1.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import "GlobleData.h"
#import "NSDictionary+ValuePath.h"
#import "Utility.h"

@implementation UserItem

- (id)init {
    self = [super init];
    if (self) {
        self.UserName = @"";
        self.UserAvatar = @"";
    }
    return self;
}

- (void)setValuesWithDic:(NSDictionary *)dic {
    _UserId = [dic intValue:@"uid"];
    self.UserName = [dic strValue:@"name"];
    self.UserAvatar = [dic strValue:@"avatar"];
}

- (NSDictionary *)dictionary {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:self.UserId], @"uid",
            self.UserName, @"name",
            self.UserAvatar, @"avatar", nil];
}


- (void)dealloc {
    [_UserName release];
    [_UserAvatar release];
    [super dealloc];
}

@end

@implementation ChatItem

- (id)init {
    self = [super init];
    if (self) {
        self.ChatTitle = @"";
        self.ChatAvatar = @"";
    }
    return self;
}

- (NSDictionary *)dictionary {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:self.ChatId], @"id",
            [NSNumber numberWithInt:self.ChatCreatorid], @"creatorid",
            self.ChatTitle, @"title",
            self.ChatAvatar, @"avatar", nil];
}

- (void)dealloc {
    [super dealloc];
    [_ChatTitle release];
    [_ChatAvatar release];
}

@end

@implementation MessageItem

- (id)init {
    self = [super init];
    if (self) {
        _MsgUserInfo = [[UserItem alloc] init];
        self.MsgMedia = @"";
        self.MsgText = @"";
        self.MsgCreated = @"";
    }
    return self;
}

- (void)setValuesWithDic:(NSDictionary *)dic {
    self.MsgId = [dic intValue:@"id"];
    self.MsgChatId = [dic intValue:@"chatid"];
    self.MsgType = [dic intValue:@"media_type"];
    self.MsgMedia = [dic strValue:@"media_url"];
    [_MsgUserInfo setValuesWithDic:[dic valueForKey:@"user"]];
    self.MsgText = [dic strValue:@"text"];
    self.MsgCreated = [dic strValue:@"created_at"];
}

- (NSDictionary *)dictionary {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt:self.MsgId], @"id",
            [NSNumber numberWithInt:self.MsgChatId], @"chatid",
            [NSNumber numberWithInt:self.MsgType], @"media_type",
            [_MsgUserInfo dictionary], @"user",
            self.MsgMedia, @"media_url",
            self.MsgText, @"text",
            self.MsgCreated, @"created_at",
            nil];
}

- (void)dealloc {
    [super dealloc];
    [_MsgUserInfo release];
    [_MsgMedia release];
    [_MsgText release];
    [_MsgCreated release];
}

@end

@implementation GlobleData

- (id)init {
    self = [super init];
    if (self) {
        _userInfo = [[UserItem alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_webSocketUrl release];
    [_userInfo release];
    [super dealloc];
}

//
/*
 ChatItem
 
 "id": 109,
 "creatorid": 100003,
 "title": "a,b,c",
 "avatar": "http://ww4.sinaimg.cn/large/82450bb6jw1e4qhivbzfsg20ak05k10c.gif"

 
 MessageItem
 
 "id": 109,
 "uid": 109,
 "avatar": "http://ww4.sinaimg.cn/large/82450bb6jw1e4qhivbzfsg20ak05k10c.gif",
 "chatid": 109,
 "media_type": "text/plain",
 "media_url": "http://ww4.sinaimg.cn/large/82450bb6jw1e4qhivbzfsg20ak05k10c.gif",
 "text": "hello",
 "created_at": "2003-04-29 10:11:22"

 */
- (void)saveChatWithDic:(ChatItem *)chat { // update the chat info to the latest one
    NSString * key = [NSString stringWithFormat:@"%d",chat.ChatId];
    NSString * path = hdGetDocumentPath(ChatList);
    NSMutableDictionary * diclist = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSDictionary * dicmsg = [diclist valueForKey:key];
    if (dicmsg && [dicmsg isKindOfClass:[NSDictionary class]]) {
        [diclist removeObjectForKey:key];
    }
    [diclist setValue:[chat dictionary] forKey:key];
    [diclist writeToFile:path atomically:YES];
}

- (void)saveMsgWithDic:(MessageItem *)msg {
    NSString * key = [NSString stringWithFormat:@"%d",msg.MsgChatId];
    NSString * path = hdGetDocumentPath(MsgList);
    NSMutableDictionary * diclist = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (diclist == nil) {
        diclist = [NSMutableDictionary dictionary];
    }
    NSMutableArray * array = [diclist valueForKey:key];
    if (array == nil || [array count] == 0) {
        array = [NSMutableArray array];
    }
    [array insertObject:[msg dictionary] atIndex:0];
    [diclist setValue:array forKey:key];
    [diclist writeToFile:path atomically:YES];
}



@end
