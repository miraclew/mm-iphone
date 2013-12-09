//
//  LoginViewController.m
//  MobileMessage
//
//  Created by yangw on 13-6-1.
//  Copyright (c) 2013年 yangw. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Utility.h"
#import "JsonData.h"
#import "NSDictionary+ValuePath.h"

@interface LoginViewController () <UITextFieldDelegate> {
    UITextField * _uidTextF;
    UITextField * _pswTextF;
}

@end

@implementation LoginViewController

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
//    self.view.backgroundColor = [UIColor blackColor];
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:button];
    button.frame = CGRectMake(100, 100, 70, 30);
    [button setTitle:@"Login" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    
    NSString * uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"uid"];
    NSString * psw = [[NSUserDefaults standardUserDefaults] objectForKey:@"psw"];
    if (uid == nil || [uid length] == 0) {
        uid = @"100006";
    }
    if (psw == nil || [psw length] == 0) {
        psw = @"123";
    }
    
    _uidTextF = [[UITextField alloc] initWithFrame:CGRectMake(50, 20, 100, 30)];
    _uidTextF.borderStyle = UITextBorderStyleRoundedRect;
    _uidTextF.delegate = self;
    _uidTextF.text = uid;
    [self.view addSubview:_uidTextF];
    
    _pswTextF = [[UITextField alloc] initWithFrame:CGRectMake(50, 60, 100, 30)];
    _pswTextF.borderStyle = UITextBorderStyleRoundedRect;
    _pswTextF.delegate = self;
    _pswTextF.text = psw;
    [self.view addSubview:_pswTextF];
    
}

- (void)dealloc {
    [_uidTextF release];
    [_pswTextF release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)login {    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",Base_URL,@"users?"]]];
    [request setPostValue:@"login" forKey:@"a"];
    [request setPostValue:_uidTextF.text forKey:@"uid"];
    [request setPostValue:_pswTextF.text forKey:@"password"];
    [request setCompletionBlock:^{
        NSString * respondstring = [request responseString];
        NSLog(@"%@",respondstring);
        JsonData * jsonData = [[JsonData alloc] initWithString:[request responseString]];
        //        NSInteger code = [jsonData intValue:@"code" default:-1];
        NSDictionary * dic = [jsonData dictValue:@"data.profile"];
        [MMGetGlobleData().userInfo setValuesWithDic:dic];
        MMGetGlobleData().webSocketUrl = [[jsonData dictValue:@"data"] strValue:@"ws"];
        [self loginSuccess];        
        
    }];
    [request setFailedBlock:^{
        [self loginFailed];
    }];
    [request startAsynchronous];

}

- (void)loginSuccess {
    [[NSUserDefaults standardUserDefaults] setObject:_uidTextF.text forKey:@"uid"];
    [[NSUserDefaults standardUserDefaults] setObject:_pswTextF.text forKey:@"psw"];

    [MMGetAppDelegate() logInSuccess];
}

- (void)loginFailed {
    NSLog(@"login failed");
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _uidTextF) {
        [_pswTextF becomeFirstResponder];
    }else {
        [textField resignFirstResponder];
        if ([_uidTextF.text length] > 0 && [_pswTextF.text length] > 0) {
            [self login];
        }
    }
    return YES;
}

@end
