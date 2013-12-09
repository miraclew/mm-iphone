//
//  MMContentListViewController.m
//  MobileMessage
//
//  Created by yangw on 13-5-31.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import "MMContentListViewController.h"
#import "MsgContentViewCell.h"
#import "AppDelegate.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Utility.h"
#import "JsonData.h"
#import "NSDictionary+ValuePath.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "JsonData.h"

@interface MMContentListViewController ()

@end

@implementation MMContentListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithTitle:@"send" style:UIBarButtonItemStyleBordered target:self action:@selector(sendMsg)];
    self.navigationItem.rightBarButtonItem = item;
    [item release];

    _dataArray = [[NSMutableArray alloc] init];
    
    _tableViewHelper = [[HDTableViewHelper alloc] init];
    _tableViewHelper.delegate = self;
    _tableViewHelper.tableView = self.tableView;
    _tableViewHelper.dragType = HDTableViewDragBoth;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMsgData:) name:@"ChatInfo" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_tableViewHelper release];
    [_dataArray release];
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.chatId > 0) {
        [_tableViewHelper startLoadingData];        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)receiveMsgData:(NSNotification *)notification {
    NSDictionary * dic = notification.userInfo;
//    NSLog(@"%@",dic);
    JsonData * jsondata = [[[JsonData alloc] initWithString:[dic strValue:@"msg"]] autorelease];
    dic = [jsondata dictValue:nil];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        [_dataArray addObject:dic];
        [_tableViewHelper endLoadData:YES];
    }
}

- (void)createChat {
    //chats?a=message_send
    ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@chats?a=create",Base_URL]]];
    [request setPostValue:[NSNumber numberWithInt:100008] forKey:@"members"];
    [request setCompletionBlock:^{
//        NSLog(@"%@",[request responseString]);
        JsonData * jsondata = [[[JsonData alloc] initWithString:[request responseString]] autorelease];
        if ([jsondata intValue:@"code" default:-1] >= 0) {
            NSDictionary * dic = [jsondata dictValue:@"data.chat"];
            self.chatId = [dic intValue:@"id"];
            if (self.chatId > 0) {
                [self sendMsg];
                return ;
            }
        }
        NSLog(@"create chat error");
    }];
    [request startAsynchronous];
    
}

- (void)sendMsg {
    if (self.chatId <= 0) {
        [self createChat];
    }
    ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@chats?a=message_send",Base_URL]]];
    [request setPostValue:[NSNumber numberWithInt:self.chatId] forKey:@"chatid"];
    [request setPostValue:@"hahahahah" forKey:@"text"];
    [request setCompletionBlock:^{
//        NSLog(@"%@",[request responseString]);
        
        JsonData * jsondata = [[[JsonData alloc] initWithString:[request responseString]] autorelease];
        if ([jsondata intValue:@"code" default:-1] >= 0) {
            NSDictionary * dic = [jsondata dictValue:@"data.message"];
            NSLog(@"%@",dic);
            if (dic && [dic isKindOfClass:[NSDictionary class]]) {
                [_dataArray addObject:dic];
                [_tableViewHelper endLoadData:YES];
            }
        }else {
            NSLog(@"send msg error");
        }
    }];
    [request startAsynchronous];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MsgContentViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    MsgContentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[[MsgContentViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary * dic = [_dataArray objectAtIndex:indexPath.row];
    [cell setMsgText:[dic strValue:@"text"]];
        
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - HDTableViewHelperDelegate
- (NSInteger)accessoryCellFlagForSection:(NSInteger)section {
    return HDTableViewCellFlagNeedNoData | HDTableViewCellFlagNeedLoadingMore;
}

- (void)didTriggerTableRefresh:(HDTableViewHelper*)helper dragType:(HDTableViewDragType)dragType {
    [helper beginLoadData];
    if (dragType == HDTableViewDragDown) {
        [self reloadTableViewDataSource:YES];
    }
    else
        [self reloadTableViewDataSource:NO];
}

- (void)reloadTableViewDataSource : (BOOL)dragDown
{
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@chats?a=message_list&chatid=%d",Base_URL,self.userId]]];
    [request setCompletionBlock:^{
        JsonData * jsondata = [[JsonData alloc] initWithString:[request responseString]];
        NSDictionary * dic = [jsondata dictValue:nil];
        NSLog(@"%@",dic);
        [_dataArray removeAllObjects];
        NSArray * array = [jsondata arrayValue:@"data.items"];
        [_dataArray addObjectsFromArray:array];
        [_tableViewHelper endLoadData:YES];
    }];
    [request setFailedBlock:^{
        
    }];
    [request startAsynchronous];
}

@end
