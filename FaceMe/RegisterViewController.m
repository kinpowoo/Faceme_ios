//
//  RegisterViewController.m
//  FaceMe
//
//  Created by JIANBO WANG on 2018/9/13.
//  Copyright © 2018年 JIANBO WANG. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *username_tf;
@property (weak, nonatomic) IBOutlet UITextField *password_tf;
@property (weak, nonatomic) IBOutlet UIButton *login_btn;
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //登陆按钮样式
    _login_btn.layer.cornerRadius = 8.0;
    _login_btn.layer.borderWidth = 2.0;
    _login_btn.layer.borderColor = [UIColor blueColor].CGColor;
    
}


- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)login:(id)sender {
    NSString* username = [_username_tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString* password = [_password_tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([username isEqualToString:@""] || [password isEqualToString:@""]) {
        // alert that username and password can't be empty
        [ConstantUtil alert:self title:@"注册提示" msg:@"用户名和密码不能为空!"];
    }
    \
    BmobUser *bUser = [[BmobUser alloc] init];
    [bUser setUsername:username];
    [bUser setPassword:password];
    [bUser signUpInBackgroundWithBlock:^ (BOOL isSuccessful, NSError *error){
        if (isSuccessful){
            NSLog(@"Sign up successfully");
            [ConstantUtil alert:self title:@"注册提示" msg:@"注册成功!" action:^(){
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        } else {
            NSLog(@"%@",error);
            [ConstantUtil alert:self title:@"注册提示" msg:@"注册失败!"];
        }
    }];
    
}

@end
