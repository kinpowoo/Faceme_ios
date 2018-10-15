//
//  RestPasswordViewController.m
//  FaceMe
//
//  Created by JIANBO WANG on 2018/9/15.
//  Copyright © 2018年 JIANBO WANG. All rights reserved.
//

#import "RestPasswordViewController.h"
#import "AppDelegate.h"
#import "ViewController.h"

@interface RestPasswordViewController (){
    BmobUser *user;
}

@property (weak, nonatomic) IBOutlet UITextField *oldPass;
@property (weak, nonatomic) IBOutlet UITextField *nPass;
@property (weak, nonatomic) IBOutlet UITextField *nPassAgain;

@end

@implementation RestPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    //navigation bar settings
    self.navigationItem.title = @"修改密码";
    //self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
 
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0,0,44,44)];
    UIButton* commit = [[UIButton alloc]initWithFrame:CGRectMake(0,7,44, 30)];
    [commit setTitle:@"提交" forState:UIControlStateNormal];
    [commit setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [commit addTarget:self action:@selector(commitReset) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:commit];
    
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:view];
    self.navigationItem.rightBarButtonItem = rightBarButton;
  
    //get user
    user = [ConstantUtil getUser];
}


-(void)commitReset{
    NSString *oldPassText = [_oldPass.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *nPassText = [_nPass.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *nPassAgainText = [_nPassAgain.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if([oldPassText isEqualToString:@""]){
        [ConstantUtil alert:self title:@"重置密码提示" msg:@"原密码不能为空!"];
    }
    
    if([nPassText isEqualToString:@""] || [nPassAgainText isEqualToString:@""]){
        [ConstantUtil alert:self title:@"重置密码提示" msg:@"新密码不能为空!"];
    }
    
    /**
    if(![oldPassText isEqualToString:(NSString*)user.password]){
        [ConstantUtil alert:self title:@"重置密码提示" msg:@"原密码错误!"];
    }*/
    
    if(nPassText.length<6 || nPassText.length>18 || nPassAgainText.length<6 || nPassAgainText.length>18){
        [ConstantUtil alert:self title:@"重置密码提示" msg:@"新密码长度不符合规范!"];
    }
    
    if(![nPassText isEqualToString:nPassAgainText]){
        [ConstantUtil alert:self title:@"重置密码提示" msg:@"两次填写的密码不一致!"];
    }
    
    if([nPassText isEqualToString:oldPassText]){
        [ConstantUtil alert:self title:@"重置密码提示" msg:@"新密码与原密码不能相同!"];
    }
    
    [ConstantUtil choice:self title:@"重置密码提示" msg:@"您确定要重置密码吗?" action:^(){
        [user updateCurrentUserPasswordWithOldPassword:oldPassText newPassword:nPassText block:^(BOOL isSuccessful, NSError *error) {
            if(isSuccessful){
                [ConstantUtil alert:self title:@"重置密码提示" msg:@"重置密码成功,请重新登录!" action:^(){
                    AppDelegate *app =(AppDelegate*)[[UIApplication sharedApplication]delegate];
                    ViewController* loginVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"login_vc"];
                    app.window.rootViewController = loginVC;
                    [app.window makeKeyAndVisible];
                }];
            }else{
                NSString *errorMsg = [NSString stringWithFormat:@"%@",error];
                NSString *alertMsg = [errorMsg stringByAppendingString:@"重置密码失败!"];
                [ConstantUtil alert:self title:@"重置密码提示" msg:alertMsg];
            }
        }];
    }];
    
}

@end
