//
//  GlobleData.h
//  MobileMessage
//
//  Created by yangw on 13-6-1.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ChatList @"chatList.plist"
#define MsgList @"msgList.plist"


@interface UserItem : NSObject

@property (nonatomic, assign) int UserId;
@property (nonatomic, retain) NSString * UserName;
@property (nonatomic, retain) NSString * UserAvatar;

- (void)setValuesWithDic:(NSDictionary *)dic;

@end


@interface ChatItem : NSObject

@property (nonatomic, assign) int ChatId;
@property (nonatomic, assign) int ChatCreatorid;
@property (nonatomic, retain) NSString * ChatTitle;
@property (nonatomic, retain) NSString * ChatAvatar;

@end

@interface MessageItem : NSObject

@property (nonatomic, assign) int MsgId;
@property (nonatomic, retain) UserItem * MsgUserInfo;
@property (nonatomic, assign) int MsgChatId;
@property (nonatomic, assign) int MsgType;
@property (nonatomic, retain) NSString * MsgMedia;
@property (nonatomic, retain) NSString * MsgText;
@property (nonatomic, retain) NSString * MsgCreated;

- (void)setValuesWithDic:(NSDictionary *)dic;

@end

@interface GlobleData : NSObject

@property (nonatomic, retain) UserItem * userInfo;
@property (nonatomic, retain) NSString * webSocketUrl;

- (void)saveChatWithDic:(ChatItem *)chat;
- (void)saveMsgWithDic:(MessageItem *)msg;

@end
