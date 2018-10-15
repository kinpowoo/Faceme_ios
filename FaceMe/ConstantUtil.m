//
//  ConstantUtil.m
//  FaceMe
//
//  Created by JIANBO WANG on 2018/9/8.
//  Copyright © 2018年 JIANBO WANG. All rights reserved.
//

#import "ConstantUtil.h"

@interface ConstantUtil (){
}

@end

@implementation ConstantUtil



//弹窗
+(void)alert:(UIViewController *)controller title:(NSString *)title msg:(NSString *)msg{
    [self alert:controller title:title msg:msg action:nil];
}

+(void)alert:(UIViewController *)controller title:(NSString *)title msg:(NSString *)msg action:(void(^)())handler{
    if(controller == nil || title == nil || msg == nil){
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if(handler){
            handler();
        }
    }];
    __weak typeof(controller) weakController = controller;    //弱引用，防止内存泄露
    [alert addAction:action];
    [weakController presentViewController:alert animated:YES completion:nil];
}


//双选项提示
+(void)choice:(UIViewController *)controller title:(NSString *)title msg:(NSString *)msg action:(void(^)())handler{
    if(controller == nil || title == nil || msg == nil){
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if(handler){
            handler();
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    [alert addAction:cancel];
     __weak typeof(controller) weakController = controller;    //弱引用，防止内存泄露
    [weakController presentViewController:alert animated:YES completion:nil];
}


//获得当前用户
+(BmobUser *)getUser{
    /**
    static BmobUser *user;
    static dispatch_once_t token;
    dispatch_once(&token, ^(){
        if(user == nil){
            user = [BmobUser currentUser];
        }
    });
     */
    return [BmobUser currentUser];
}


//NSDate转NSString
+ (NSString *)stringFromDate:(NSDate *)date
{
    if(date == nil){
        return nil;
    }
    //用于格式化NSDate对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置格式：zzz表示时区
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //NSDate转NSString
    NSString *currentDateString = [dateFormatter stringFromDate:date];
    
    return currentDateString;
}

//NSDate转NSString
+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format
{
    if(date == nil){
        return nil;
    }
    //用于格式化NSDate对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置格式：zzz表示时区
    [dateFormatter setDateFormat:format];
    //NSDate转NSString
    NSString *currentDateString = [dateFormatter stringFromDate:date];
    
    return currentDateString;
}


//NSString转NSDate
+ (NSDate *)dateFromString:(NSString *)string
{
    //需要转换的字符串
    //NSString *dateString = @"2015-06-26 08:08:08";
    //设置转换格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSString转NSDate
    NSDate *date=[formatter dateFromString:string];
    return date;
}



//裁剪imageview为圆形
+(UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset {
    
    UIGraphicsBeginImageContext(image.size);
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    //圆的边框宽度为2，颜色为红色
    
    CGContextSetLineWidth(context,2);
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGRect rect = CGRectMake(inset, inset, image.size.width - inset *2.0f, image.size.height - inset *2.0f);
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextClip(context);
    
    //在圆区域内画出image原图
    
    [image drawInRect:rect];
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextStrokePath(context);
    
    //生成新的image
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newimg;
    
}


+(UIImage *)circleImage:(UIImage *)image{
    UIGraphicsBeginImageContext(image.size);
    
    //1.3利用贝塞尔曲线,设置一个圆形裁剪区域(设置一个矩形的内切圆/内切椭圆);
    UIBezierPath *path =[UIBezierPath bezierPathWithOvalInRect:CGRectMake( 0, 0, image.size.width, image.size.height)];
    //1.4拿到贝塞尔曲线对象 添加裁剪;
    [path addClip];
    //1.5将图片画到图像上下文上
    //由于图像上下文size和图片的size设置一样 所以可以设置point为零点;
    [image drawAtPoint:CGPointZero];
    UIImage *newimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimage;
}



//循环压缩图片质量，减小图片大小
+(NSData *)compressQualityWithMaxLength:(UIImage *)image targetLen:(NSInteger)maxLength{
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return data;
    CGFloat max = 1;
    CGFloat min = 0;
    
    UIImage* pres = image;
    
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(pres, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
            pres = [UIImage imageWithData:data];
        } else if (data.length > maxLength) {
            max = compression;
            pres = [UIImage imageWithData:data];
        } else {
            break;
        }
    }
    return data;
}


//压缩图片尺寸，减小图片大小
+(NSData *)compressBySizeWithMaxLength:(UIImage *)image targetLen:(NSUInteger)maxLength{
    UIImage *resultImage = image;
    NSData *data = UIImageJPEGRepresentation(resultImage, 1);
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        // Use image to draw (drawInRect:), image is larger but more compression time
        // Use result image to draw, image is smaller but less compression time
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, 1);
    }
    return data;
}


+(NSData *)compressWithMaxLength:(UIImage *)image targetLen:(NSUInteger)maxLength{
    // Compress by quality
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    //NSLog(@"Before compressing quality, image size = %ld KB",data.length/1024);
    if (data.length < maxLength) return data;
    
    UIImage* pres = image;
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(pres, compression);
        //NSLog(@"Compression = %.1f", compression);
        //NSLog(@"In compressing quality loop, image size = %ld KB", data.length / 1024);
        if (data.length < maxLength * 0.9) {
            min = compression;
            pres = [UIImage imageWithData:data];
        } else if (data.length > maxLength) {
            max = compression;
            pres = [UIImage imageWithData:data];
        } else {
            break;
        }
    }
    //NSLog(@"After compressing quality, image size = %ld KB", data.length / 1024);
    if (data.length < maxLength/10) return data;
    UIImage *resultImage = [UIImage imageWithData:data];
    // Compress by size
    NSUInteger lastDataLength = 0;
    NSUInteger newTargetLen = maxLength/10;
    while (data.length > newTargetLen && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)newTargetLen / data.length;
        //NSLog(@"Ratio = %.1f", ratio);
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, compression);
        //NSLog(@"In compressing size loop, image size = %ld KB", data.length / 1024);
    }
    //NSLog(@"After compressing size loop, image size = %ld KB", data.length / 1024);
    return data;
}


@end
