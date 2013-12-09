//
//  AppDelegate.m
//  MobileMessage
//
//  Created by yangw on 13-5-31.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "LoginViewController.h"
#import "JsonData.h"

@implementation AppDelegate

AppDelegate* MMGetAppDelegate(void) {
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
    
}

GlobleData * MMGetGlobleData(void) {
    return MMGetAppDelegate().globleData;
}

- (void)dealloc {
    [_loginViewController release];
    [_rootViewController release];
    [_globleData release];
    [super dealloc];
}

- (void)showTabBarVC {
    if (nil == _rootViewController) {
        _rootViewController = [[HomeViewController alloc] init];
    }
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:_rootViewController];
    self.window.rootViewController = nav;
    [nav release];
}

- (void)showLoginVC {
    if (nil == _loginViewController) {
        _loginViewController = [[LoginViewController alloc] init];
    }
    self.window.rootViewController = _loginViewController;
}

- (void)connectSocket {
    if (MMGetGlobleData().webSocketUrl && [MMGetGlobleData().webSocketUrl length] > 0) {
        SRWebSocket * socket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:MMGetGlobleData().webSocketUrl]];
        socket.delegate = self;
        [socket open];
        [socket release];
    }
}

- (void)logInSuccess {
    // connect to web socket
    [self connectSocket];
    [self showTabBarVC];
}

#pragma mark - SRWebSocketDelegate
- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
//    _webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSLog(@"Received \"%@\"", message);
    NSDictionary * dic = [NSDictionary dictionaryWithObject:message forKey:@"msg"];
    JsonData * jsondata = [[[JsonData alloc] initWithString:message] autorelease];
    MessageItem * item = [[MessageItem alloc] init];
    [item setValuesWithDic:[jsondata dictValue:nil]];
    [MMGetGlobleData() saveMsgWithDic:item];
    [item release];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatInfo" object:nil userInfo:dic];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed");
//    _webSocket = nil;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    _globleData = [[GlobleData alloc] init];
    
    [self showLoginVC];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
