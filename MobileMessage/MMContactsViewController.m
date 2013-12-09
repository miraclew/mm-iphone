//
//  MMContactsViewController.m
//  MobileMessage
//
//  Created by yangw on 13-5-31.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import "MMContactsViewController.h"
#import "AppDelegate.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Utility.h"
#import "JsonData.h"
#import "NSDictionary+ValuePath.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequest.h"
#import "JsonData.h"

@interface MMContactsViewController ()

@end

@implementation MMContactsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        UITabBarItem * item = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:1];
        self.tabBarItem = item;
        [item release];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _dataArray = [[NSMutableArray alloc] init];
    
    _tableViewHelper = [[HDTableViewHelper alloc] init];
    _tableViewHelper.delegate = self;
    _tableViewHelper.tableView = self.tableView;
    _tableViewHelper.dragType = HDTableViewDragBoth;
    
    

}

- (void)dealloc {
    [_tableViewHelper release];
    [_dataArray release];
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_tableViewHelper startLoadingData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//- (void)

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    NSDictionary * dic = [_dataArray objectAtIndex:indexPath.row];
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
//        cell.imageView.image = [];
        cell.textLabel.text = [dic strValue:@"name"];
    }
    
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
    ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@friends?a=list",Base_URL]]];
    [request setCompletionBlock:^{
        JsonData * jsondata = [[[JsonData alloc] initWithString:[request responseString]] autorelease];
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
