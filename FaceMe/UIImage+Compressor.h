//
//  UIImage+Compressor.h
//  FaceMe
//
//  Created by JIANBO WANG on 2018/9/13.
//  Copyright © 2018年 JIANBO WANG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Compressor)
-(NSData *)compressQualityWithMaxLength:(NSInteger)maxLength;
-(NSData *)compressBySizeWithMaxLength:(NSUInteger)maxLength;
-(NSData *)compressWithMaxLength:(NSUInteger)maxLength;
@end
