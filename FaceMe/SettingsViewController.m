//
//  SettingsViewController.m
//  FaceMe
//
//  Created by JIANBO WANG on 2018/9/15.
//  Copyright © 2018年 JIANBO WANG. All rights reserved.
//

#import "SettingsViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "RestPasswordViewController.h"
#import "UserSettingsViewController.h"


@interface SettingsViewController () <UITableViewDelegate,UITableViewDataSource>{
    NSArray* data;
    NSArray* group1;
    NSArray* group2;
}

@property (weak, nonatomic) IBOutlet UITableView *mtableView;
@property (weak, nonatomic) IBOutlet UIButton *logout_btn;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"设置";
    
    //init data source
    group1 = @[@{@"修改个人主页":@"user_settings.png"},@{@"修改密码":@"reset_password.png"}];
    group2 = @[@{@"缓存":@"cache.png"},@{@"反馈":@"feedback.png"},@{@"关于":@"about.png"}];
    data = @[group1,group2];
    
    //set logout btn style
    _logout_btn.layer.cornerRadius = 6.0;
    _logout_btn.layer.borderWidth = 1.0;
    _logout_btn.layer.borderColor = [UIColor redColor].CGColor;
   
    
    //uitableview attribute set
    _mtableView.delegate = self;
    _mtableView.dataSource = self;
    _mtableView.scrollEnabled = NO;
    [_mtableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"www.kinpowoo.settingsCell"];

}

- (IBAction)logout:(id)sender {
    
    [ConstantUtil choice:self title:@"退出提示" msg:@"您确定要退出登陆吗?" action:^(){
        [BmobUser logout];
        
        AppDelegate* app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  
        ViewController *loginVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"login_vc"];
        app.window.rootViewController = loginVC;
        [app.window makeKeyAndVisible];
    }];

}



#pragma mark <UITableViewDelegate>

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return data.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *items = [data objectAtIndex:section];
    return items.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"www.kinpowoo.settingsCell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"www.kinpowoo.settingsCell"];
    }
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

    NSArray* items = [data objectAtIndex:indexPath.section];
    NSDictionary* dic = [items objectAtIndex:indexPath.row];
    
    for(NSString *key in dic.allKeys){
        cell.imageView.image = [UIImage imageNamed:[dic objectForKey:key]];
        cell.textLabel.text = key;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            UserSettingsViewController *userSettingsVC =[[UserSettingsViewController alloc]init];
            [self.navigationController pushViewController:userSettingsVC animated:YES];
        }
        
        if(indexPath.row == 1){
            NSLog(@"RESET PASSWORD ITEM BE CLICKED");
            RestPasswordViewController *restPasswordVC = [[RestPasswordViewController alloc]init];
            [self.navigationController pushViewController:restPasswordVC animated:YES];
            
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
