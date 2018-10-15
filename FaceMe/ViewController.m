//
//  ViewController.m
//  FaceMe
//
//  Created by JIANBO WANG on 2018/9/8.
//  Copyright © 2018年 JIANBO WANG. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "MainPageTabBarController.h"
#import "RegisterViewController.h"

@interface ViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *outBox;
@property (weak, nonatomic) IBOutlet UITextField *username_tf;
@property (weak, nonatomic) IBOutlet UITextField *password_tf;

@property (weak, nonatomic) IBOutlet UISwitch *remember_pass;
@property (weak, nonatomic) IBOutlet UIButton *login_btn;
@property (weak, nonatomic) IBOutlet UILabel *regiseter_lb;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //边层盒子边框
    _outBox.layer.cornerRadius = 10.0;
    
    //输入框左侧view
    UIImageView *userLeft = [[UIImageView alloc]initWithFrame:CGRectMake(5,2,30,28)];
    userLeft.image = [UIImage imageNamed:@"user.png"];
    userLeft.contentMode = UIViewContentModeScaleAspectFit;
    _username_tf.leftView = userLeft;
    _username_tf.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview显示模式
    _username_tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    UIImageView *passLeft = [[UIImageView alloc]initWithFrame:CGRectMake(5,2,30,28)];
    passLeft.image = [UIImage imageNamed:@"password.png"];
    passLeft.contentMode = UIViewContentModeScaleAspectFit;
    _password_tf.leftView = passLeft;
    _password_tf.leftViewMode=UITextFieldViewModeAlways; //此处用来设置leftview显示模式
    _password_tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    //登陆按钮样式
    _login_btn.layer.borderWidth = 1.0;
    _login_btn.layer.borderColor = [UIColor whiteColor].CGColor;
    _login_btn.layer.cornerRadius = 8.0;
    [_login_btn setBackgroundColor:[UIColor clearColor]];
    
    
    //填充输入框
    NSUserDefaults *favor = [NSUserDefaults standardUserDefaults];
    [_username_tf setText:[favor objectForKey:@"user"]];
    [_password_tf setText:[favor objectForKey:@"pass"]];
    [_remember_pass setOn:[favor boolForKey:@"isRemember"]];
    
    
    //register gesture add
    _regiseter_lb.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goRegister)];
    tapGesture.numberOfTouchesRequired = 1;
    [_regiseter_lb addGestureRecognizer:tapGesture];
    
    
    //设置文本监听
    _username_tf.delegate = self;
    _password_tf.delegate = self;
}

//switch变化监听
- (IBAction)remember_change:(id)sender {
    
}


//登陆按钮点击监听
- (IBAction)login_action:(id)sender {
    NSString *username = [_username_tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *password = [_password_tf.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([username isEqualToString:@""] || [password isEqualToString:@""]){
        [ConstantUtil alert:self title:@"温馨提示" msg:@"用户名或密码不能为空!"];
    }
    
    
 

    
   // /**
    [BmobUser loginInbackgroundWithAccount:username andPassword:password block:^(BmobUser *user, NSError *error) {
        if (user) {
            NSUserDefaults* fav = [NSUserDefaults standardUserDefaults];
            if([_remember_pass isOn]){
                [fav setObject:username forKey:@"user"];
                [fav setObject:password forKey:@"pass"];
                [fav setBool:YES forKey:@"isRemember"];
            }else{
                [fav removeObjectForKey:@"pass"];
                [fav setBool:NO forKey:@"isRemember"];
            }
            [fav synchronize];
            
            // 这里进行页面跳转
            [ConstantUtil alert:self title:@"登陆提示" msg:@"登入成功!" action:^(){
                AppDelegate* app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                MainPageTabBarController *mainPage = [[MainPageTabBarController alloc]init];
                app.window.rootViewController = mainPage;
                [app.window makeKeyAndVisible];
                //NSLog(@"%@",user);
            }];
            
        } else {
            NSString* notice = [NSString stringWithFormat:@"登陆失败，错误码为: %ld",(long)error.code];
            [ConstantUtil alert:self title:@"登陆提示" msg:notice];
        }
    }];
    // */
    
}


//跳转到注册页面
-(void)goRegister{
    RegisterViewController* registerVC = [[RegisterViewController alloc]init];
    [self presentViewController:registerVC animated:YES completion:nil];
}



//输入完成监听
-(void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
