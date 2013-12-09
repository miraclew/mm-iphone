//
//  HomeViewController.m
//  MobileMessage
//
//  Created by yangw on 13-5-31.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import "HomeViewController.h"
#import "MMContactsViewController.h"
#import "MMChatListViewController.h"
#import "SRWebSocket.h"

@interface HomeViewController () <SRWebSocketDelegate>

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    MMChatListViewController * vc1 = [[MMChatListViewController alloc] init];
    MMContactsViewController * vc2 = [[MMContactsViewController alloc] init];
    self.viewControllers = [NSArray arrayWithObjects:vc1, vc2, nil];
    [vc1 release];
    [vc2 release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
