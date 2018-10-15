//
//  LocateManager.h
//  FaceMe
//
//  Created by JIANBO WANG on 2018/9/9.
//  Copyright © 2018年 JIANBO WANG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

@interface LocateManager : NSObject
+(instancetype)getInstance;
-(void)locate :(void(^)(CLLocation *))callback;
@end
