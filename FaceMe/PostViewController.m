//
//  PostViewController.m
//  FaceMe
//
//  Created by JIANBO WANG on 2018/9/11.
//  Copyright © 2018年 JIANBO WANG. All rights reserved.
//

#import "PostViewController.h"
#import "LocateManager.h"
#import "SVProgressHUD.h"
#import "UIImage+Compressor.h"

@interface PostViewController () <UITextViewDelegate,UITextViewDelegate>{
    BmobUser *user;
    CLLocation* loc;
    BOOL isLocUpdated;
    UILabel *hintLB;        //提示的控件
    NSMutableArray* tags;   //标签
}

@property (weak, nonatomic) IBOutlet UIImageView *postContentImg;
@property (weak, nonatomic) IBOutlet UITextView *postContentText;
@property (weak, nonatomic) IBOutlet UILabel *hintText;
@property (weak, nonatomic) IBOutlet UIButton *selfie_tag;
@property (weak, nonatomic) IBOutlet UIButton *baby_tag;
@property (weak, nonatomic) IBOutlet UIButton *view_tag;
@property (weak, nonatomic) IBOutlet UIButton *star_tag;
@property (weak, nonatomic) IBOutlet UIButton *boy_tag;
@property (weak, nonatomic) IBOutlet UIButton *girl_tag;
@property (weak, nonatomic) IBOutlet UIButton *food_tag;
@property (weak, nonatomic) IBOutlet UIButton *travel_tag;
@property (weak, nonatomic) IBOutlet UIButton *more_tag;
@property (weak, nonatomic) IBOutlet UILabel *current_loc_lb;

@end

@implementation PostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    user = [ConstantUtil getUser];
    tags = [NSMutableArray array];
    
    if(self.image != nil){
        _postContentImg.image = self.image;
        _postContentImg.contentMode = UIViewContentModeScaleToFill;
    }
    
    
    
    //提示控件初始化及配置
    hintLB = [[UILabel alloc]initWithFrame:CGRectMake(SW/4,SH-90,SW/2,30)];
    hintLB.backgroundColor = [UIColor whiteColor];
    hintLB.layer.cornerRadius = 10;
    hintLB.textAlignment = NSTextAlignmentCenter;
    hintLB.hidden = YES;
    [self.view addSubview:hintLB];
    
    //设置输入文本框代理
    _postContentText.delegate = self;
    
    
    //开始定位
    loc = nil;
    LocateManager* manager = [LocateManager getInstance];
    [manager locate:^(CLLocation *location){
        loc = location;
        isLocUpdated = YES;
        _current_loc_lb.text = [NSString stringWithFormat:@"%.3f,%.3f",location.coordinate.longitude,
                                location.coordinate.latitude];
        [self toast:@"位置已更新!"];
    }];
    
    
    //给textView输入框设置代理
    _postContentText.delegate = self;
    
}


-(void)toast:(NSString *)msg{
    hintLB.text = msg;
    hintLB.hidden = NO;
    dispatch_time_t t = dispatch_time(DISPATCH_TIME_NOW,(int64_t)NSEC_PER_SEC*2);
    dispatch_after(t, dispatch_get_main_queue(),^(){
        hintLB.hidden = YES;
    });
}



//返回按钮退出
- (IBAction)backClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



//上传按钮点击回调
- (IBAction)upload:(id)sender {

    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [Bmob setBmobRequestTimeOut:10];
    if(!isLocUpdated){  //等待位置更新
        [self toast:@"地址未更新!"];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        return;
    }else{
        if(loc == nil){
            //....
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [self toast:@"地址不能为空!"];
        }else{
            NSDate *now = [NSDate date];
            
            [SVProgressHUD showWithStatus:@"正在发布..."];
            [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeGradient];
            
            BmobObject *obj = [[BmobObject alloc]initWithClassName:@"Status"];
            obj.createdAt = [[NSDate alloc]init];
            //设置发布者
            [obj setObject:user forKey:@"author"];
            //设置字段值
            [obj setObject:_postContentText.text forKey:@"text"];
            
            //设置tag数组
            [obj setObject:tags forKey:@"tags"];
            
            
            NSString* timeStr = [ConstantUtil stringFromDate:[[NSDate alloc]init] format:@"yyyyMMddHHmmss"];
            NSString *fileName = [timeStr stringByAppendingString:@".jpg"];
            //设置图片对象
            NSData *data = UIImagePNGRepresentation(self.image);
            BmobFile* photo = [[BmobFile alloc]initWithFileName:fileName withFileData:data];
           
            //先上传图片
            [photo saveInBackground:^(BOOL isSuccessful, NSError *error) {
                //dismiss progress
                [SVProgressHUD dismiss];
                self.navigationItem.rightBarButtonItem.enabled = YES;
                
                //如果文件保存成功，则把文件添加到filetype列
                if (isSuccessful) {
                    //上传文件
                    [obj setObject:photo forKey:@"photo"];
                    
                    //设置位置
                    BmobGeoPoint *geo = [[BmobGeoPoint alloc]initWithLongitude:loc.coordinate.longitude WithLatitude:loc.coordinate.latitude];
                    [obj setObject:geo forKey:@"location"];
                    [obj setObject:@"广东省深圳市" forKey:@"locName"];
                    //执行保存操作
                    [obj saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                        if (!error) {
                            //其他代码，发送广播，退出当前页面
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusAdd" object:nil
                                    userInfo:@{@"createTime":now}];
                            
                            [self dismissViewControllerAnimated:YES completion:nil];
                            
                        }else{
                            NSLog(@"ERROR :%@",error);
                            [self toast:@"发布动态失败!"];
                        }
                        
                    }];
                }else{
                    //进行处理
                    [self toast:@"图片上传失败!"];
                }
            }];
            
            
        
        }
    }
}




- (IBAction)btnClick:(id)sender {
    UIView *v = (UIView *)sender;
    if(v.tag <= 1000 || v.tag > 1008){
        return;
    }
    NSLog(@"TAGS : %@",tags);
    UIButton* btn = (UIButton*)v;
    NSString *tagText = btn.titleLabel.text;
    if([tags containsObject:tagText]){
        btn.backgroundColor = [UIColor colorWithRed:0.7254 green:0.7255 blue:0.7254 alpha:1.0];
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [tags removeObject:tagText];
    }else{
        if(tags.count >= 3){
            [self toast:@"最多三个标签"];
        }else{
            UIButton* btn = (UIButton*)v;
            btn.backgroundColor = [UIColor colorWithRed:0.1799 green:0.5895 blue:0.8588 alpha:1.0];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
            
            [tags addObject:tagText];
        }
    }
}



-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}


//点击空白区域按钮隐藏键盘
- (IBAction)dismissKeyBoard:(id)sender {
    [_postContentText resignFirstResponder];
}




#pragma mark <UITextViewDelegate>

- (void)textViewDidBeginEditing:(UITextView *)textView{
    NSLog(@"START EDITING");
}

-(void)textViewDidChange:(UITextView *)textView{
    if(textView.text.length > 0){
        _hintText.hidden = YES;
        if(textView.text.length>100){
            [self toast:@"字数已达上限!"];
        }
    }else{
        _hintText.hidden = NO;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    NSLog(@"END EDITING");
}

@end
