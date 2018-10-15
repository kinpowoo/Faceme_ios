//
//  ConstantUtil.h
//  FaceMe
//
//  Created by JIANBO WANG on 2018/9/8.
//  Copyright © 2018年 JIANBO WANG. All rights reserved.
//

#define SW [UIScreen mainScreen].bounds.size.width
#define SH [UIScreen mainScreen].bounds.size.height
#define __IPHONE_10_3  100300
//#define __IPHONE_11_0  110000


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@interface ConstantUtil : NSObject

+(void)alert:(UIViewController *)controller title:(NSString *)title msg:(NSString *)msg;
+(void)alert:(UIViewController *)controller title:(NSString *)title msg:(NSString *)msg action:(void(^)())handler;
+(void)choice:(UIViewController *)controller title:(NSString *)title msg:(NSString *)msg action:(void(^)())handler;
+(BmobUser *)getUser;
+(NSString *)stringFromDate:(NSDate *)date;
+(NSString *)stringFromDate:(NSDate *)date format:(NSString *)format;
+(NSDate *)dateFromString:(NSString *)string;
+(UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset;
+(UIImage *)circleImage:(UIImage *)image;
+(NSData *)compressQualityWithMaxLength:(UIImage *)image targetLen:(NSInteger)maxLength;
+(NSData *)compressBySizeWithMaxLength:(UIImage *)image targetLen:(NSUInteger)maxLength;
+(NSData *)compressWithMaxLength:(UIImage *)image targetLen:(NSUInteger)maxLength;
@end
