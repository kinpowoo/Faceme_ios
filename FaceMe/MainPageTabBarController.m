//
//  MainPageTabBarController.m
//  FaceMe
//
//  Created by JIANBO WANG on 2018/9/8.
//  Copyright © 2018年 JIANBO WANG. All rights reserved.
//

#import "MainPageTabBarController.h"
#import "UserViewController.h"
#import "PhotoListViewController.h"
#import "PostViewController.h"
#import "LZImageCropper.h"

#import <AssetsLibrary/AssetsLibrary.h>


@interface MainPageTabBarController () <UITabBarControllerDelegate,UIImagePickerControllerDelegate,
            LZImageCroppingDelegate>{
    UINavigationController *photoListNav;
    UINavigationController *userNav;
    UserViewController *userVC;
    PhotoListViewController *photoVC;
    UIImagePickerController *imagePickerController;     //图片选择器
    LZImageCropper *imageBrowser;                   //图片裁剪器
    
    UIViewController *middleVC;
}

@end

@implementation MainPageTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // photo view controller
    photoVC = [[PhotoListViewController alloc]init];
    photoListNav = [[UINavigationController alloc]initWithRootViewController:photoVC];
    UITabBarItem *photoItem = [[UITabBarItem alloc]initWithTitle:@"" image:[UIImage imageNamed:@"home_gray.png"] selectedImage:[UIImage imageNamed:@"home.png"]];
    photoListNav.tabBarItem = photoItem;
    
    //中间的拍照按钮
    userVC = [[UserViewController alloc]init];
    UINavigationController *camNav = [[UINavigationController alloc]initWithRootViewController:userVC];
    UITabBarItem *camItem = [[UITabBarItem alloc]initWithTitle:@"" image:[UIImage imageNamed:@""] selectedImage:[UIImage imageNamed:@""]];
    camNav.tabBarItem = camItem;
    
    //user view controller
    userVC = [[UserViewController alloc]init];
    userNav = [[UINavigationController alloc]initWithRootViewController:userVC];
    UITabBarItem *userItem = [[UITabBarItem alloc]initWithTitle:@"" image:[UIImage imageNamed:@"user2_gray.png"] selectedImage:[UIImage imageNamed:@"user2.png"]];
    userNav.tabBarItem = userItem;
    
    self.viewControllers = @[photoListNav,camNav,userNav];
    
    
    
    //自定义按钮,将UIView设为外层view，以免触发中间tab的viewController
    UIView *preventClick = [[UIView alloc]initWithFrame:CGRectMake(SW/3,0,SW/3,44)];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((SW/3-40)/2,0,40,40)];
    [preventClick addSubview:btn];
    [btn setImage:[UIImage imageNamed:@"cam.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
    [self.tabBar addSubview:preventClick];
}



//点击中间拍照按钮响应
-(void)takePicture{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *photoLibrarySource = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self choosePhoto:1];
    }];
    UIAlertAction *camLibrarySource = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self choosePhoto:0];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:nil];
    [alert addAction:photoLibrarySource];
    [alert addAction:camLibrarySource];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}




//设置tabbar上第二个按钮为不可选中状态，其他的按钮为可选择状态
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    return ![viewController isEqual:tabBarController.viewControllers[1]];
}


//将点击在中间tar上的手势转移到 btn 上
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];   //视图中的所有对象
    CGPoint point = [touch locationInView:[touch view]]; //返回触摸点在视图中的当前坐标
    
    CGRect area = CGRectMake(SW/3,SH-44,SW/3,44);
    if(CGRectContainsPoint(area, point)){
        NSLog(@"确实点在了矩形内");
        [self takePicture];
    }
    
}


#pragma mark -消息框代理实现-
-(void)choosePhoto:(NSInteger)source{
    if(source >1 || source < 0){
        return;
    }
    
    NSUInteger sourceType = 0;
    // 判断系统是否支持相机
    if(imagePickerController == nil){
        imagePickerController = [[UIImagePickerController alloc] init];
        __weak typeof(self) weakSelf = self;
        imagePickerController.delegate = self; //设置代理
    }
    
    if(source == 0){
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imagePickerController.allowsEditing = YES;
        
            //拍照
            sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.sourceType = sourceType;
            [self presentViewController:imagePickerController animated:YES completion:nil];
        }
    }
    if(source == 1){
        //相册
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerController.sourceType = sourceType;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}


//选择图片返回回调方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage]; //通过key值获取到图片
    
    //NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    
 
    if(imageBrowser == nil){
        imageBrowser = [[LZImageCropper alloc]init];
        //设置代理
        imageBrowser.delegate = self;
        //设置自定义裁剪区域大小
        imageBrowser.cropSize = CGSizeMake(SW/2,SW/2);
    }
    //设置图片
    imageBrowser.image = image;
    //是否需要圆形
    imageBrowser.isRound = NO;
    [self presentViewController:imageBrowser animated:YES completion:nil];
   
}


//当用户取消选择图片的时候，调用该方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{}];
}




#pragma mark <LZCropperDelegate>

//裁剪取消
-(void)lzImageCroppingDidCancle:(LZImageCropper *)cropping{
    //退出裁剪器
    [imageBrowser dismissViewControllerAnimated:YES completion:nil];
}

//裁剪完成
-(void)lzImageCropping:(LZImageCropper *)cropping didCropImage:(UIImage *)image{
    //退出裁剪器
    [imageBrowser dismissViewControllerAnimated:YES completion:nil];
    
    NSData *data = [ConstantUtil compressWithMaxLength:image targetLen:300*1024];
    NSLog(@"DATA SIZE :%ld",(unsigned long)data.length);
    UIImage *compressedIMG = [UIImage imageWithData:data];
    
    PostViewController *VC = [[PostViewController alloc]init];
    VC.image = compressedIMG;
    NSLog(@"相片已选完毕");
    [self presentViewController:VC animated:YES completion:nil];
    NSLog(@"应该跳转到下一页面");
    //上传图片到服务器--在这里进行图片上传的网络请求，这里不再介绍
}




@end
