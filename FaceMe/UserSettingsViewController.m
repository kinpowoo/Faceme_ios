//
//  UserSettingsViewController.m
//  FaceMe
//
//  Created by JIANBO WANG on 2018/9/13.
//  Copyright © 2018年 JIANBO WANG. All rights reserved.
//

#import "UserSettingsViewController.h"
#import "LZImageCropper.h"
#import "UIImage+Compressor.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"

@interface UserSettingsViewController ()  <LZImageCroppingDelegate,UIImagePickerControllerDelegate,
                            UITextFieldDelegate>{
    LZImageCropper *cropperController;
    UIImagePickerController *imagePickController;
    
    BmobUser *user;
    BOOL isHeadChanage;
}


@property (weak, nonatomic) IBOutlet UIButton *save_btn;
@property (weak, nonatomic) IBOutlet UIImageView *portrait_iv;
@property (weak, nonatomic) IBOutlet UILabel *change_portrait_lb;
@property (weak, nonatomic) IBOutlet UITextField *username_tf;
@property (weak, nonatomic) IBOutlet UITextField *nickname_tf;
@property (weak, nonatomic) IBOutlet UITextField *gender_tf;
@property (weak, nonatomic) IBOutlet UITextField *phone_number_tf;
@property (weak, nonatomic) IBOutlet UITextField *email_tf;

@end

@implementation UserSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // hidden navigation bar
    [self.navigationController.navigationBar setHidden:YES];

    //add tap gesture to lable
    _change_portrait_lb.userInteractionEnabled = YES;
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(choosePhoto)];
    tapGesture.numberOfTapsRequired = 1;
    [_change_portrait_lb addGestureRecognizer:tapGesture];
    
    
    //init data
    user = [ConstantUtil getUser];
    BmobFile *headfile = [user objectForKey:@"portrait"];
    [_portrait_iv sd_setImageWithURL:[NSURL URLWithString:headfile.url]];
    
    _username_tf.text = user.username;
    _nickname_tf.text = [user objectForKey:@"nickname"];
    _gender_tf.text = [user objectForKey:@"gender"];
    _phone_number_tf.text = [user objectForKey:@"mobilePhoneNumber"];
    _email_tf.text = [user objectForKey:@"email"];
    
    
    //disable username_tf
    _username_tf.enabled = NO;
    _username_tf.delegate = self;
    _nickname_tf.delegate = self;
    _gender_tf.delegate = self;
    _phone_number_tf.delegate = self;
    _email_tf.delegate = self;
}


//choose photo
-(void)choosePhoto{
    NSUInteger sourceType = 0;
    // 判断系统是否支持相机
    if(imagePickController == nil){
        imagePickController = [[UIImagePickerController alloc] init];
        imagePickController.delegate = self; //设置代理
    }
    
    //相册
    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickController.sourceType = sourceType;
    [self presentViewController:imagePickController animated:YES completion:nil];
    
}


- (IBAction)back:(id)sender {
    [self.navigationController.navigationBar setHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
    _save_btn.enabled = NO;
    [SVProgressHUD showWithStatus:@"正在保存..."];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
    if(isHeadChanage){
        //设置图片对象
        NSString* userId = user.objectId;
        NSString *fileName = [userId stringByAppendingString:@".jpg"];
        NSData *data = UIImagePNGRepresentation(_portrait_iv.image);
        BmobFile* photo = [[BmobFile alloc]initWithFileName:fileName withFileData:data];
        
        //先上传图片
        [photo saveInBackground:^(BOOL isSuccessful, NSError *error) {
            //dismiss progress
            [SVProgressHUD dismiss];
            _save_btn.enabled = YES;
           
            // upload photo success
            if(isSuccessful) {
                [user setObject:photo forKey:@"portrait"];
                [user setObject:_nickname_tf.text forKey:@"nickname"];
                [user setObject:_gender_tf.text forKey:@"gender"];
                [user setEmail:_email_tf.text];
                [user setMobilePhoneNumber:_phone_number_tf.text];
            

                [user updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    if(isSuccessful){
                        [ConstantUtil alert:self title:@"更新提示" msg:@"用户信息更新成功!" action:^(){
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                    }else{
                        [ConstantUtil alert:self title:@"更新提示" msg:@"用户信息更新失败!"];
                    }
                }];
            }
        }];
    }else{
        //[user setEmail:_email_tf.text];
        //[user setMobilePhoneNumber:_phone_number_tf.text];
        user.email = _email_tf.text;
        user.mobilePhoneNumber = _phone_number_tf.text;
        [user setObject:_nickname_tf.text forKey:@"nickname"];
        [user setObject:_gender_tf.text forKey:@"gender"];
        
        [user updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            //dismiss loading
            [SVProgressHUD dismiss];
            _save_btn.enabled = YES;
            NSLog(@"%@",error);
            
            if(isSuccessful){
                [ConstantUtil alert:self title:@"更新提示" msg:@"用户信息更新成功!" action:^(){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserUpdate" object:nil];
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }else{
                NSString *before = @"用户信息更新失败!";
                NSString* erroMsg =[before stringByAppendingString:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
                [ConstantUtil alert:self title:@"更新提示" msg:erroMsg];
            }
        }];
    }
}



#pragma mark <UIImagePickerControllerDelegate>
//选择图片返回回调方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage]; //通过key值获取到图片
    
    //NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    
    
    if(cropperController == nil){
        cropperController = [[LZImageCropper alloc]init];
        //设置代理
        cropperController.delegate = self;
        //设置自定义裁剪区域大小
        cropperController.cropSize = CGSizeMake(SW/2,SW/2);
    }
    //设置图片
    cropperController.image = image;
    //是否需要圆形
    cropperController.isRound = NO;
    [self presentViewController:cropperController animated:YES completion:nil];
    
}


//当用户取消选择图片的时候，调用该方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{}];
}





#pragma mark <UITextFieldDelegate>
-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}



#pragma mark <LZImageCropperDelegate>
//裁剪取消
-(void)lzImageCroppingDidCancle:(LZImageCropper *)cropping{
    //退出裁剪器
    [cropperController dismissViewControllerAnimated:YES completion:nil];
}

//裁剪完成
-(void)lzImageCropping:(LZImageCropper *)cropping didCropImage:(UIImage *)image{
    //退出裁剪器
    [cropperController dismissViewControllerAnimated:YES completion:nil];
    
    NSData *data = [image compressQualityWithMaxLength:300*1024];
   
    UIImage *compressedIMG = [UIImage imageWithData:data];
    
    _portrait_iv.image = compressedIMG;
    isHeadChanage = true;
}

@end
