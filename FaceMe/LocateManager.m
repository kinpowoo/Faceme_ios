//
//  LocateManager.m
//  FaceMe
//
//  Created by JIANBO WANG on 2018/9/9.
//  Copyright © 2018年 JIANBO WANG. All rights reserved.
//

#import "LocateManager.h"

@interface LocateManager (){
    
}

@end

@implementation LocateManager

static AMapLocationManager *locationManager = nil;
static LocateManager * instance = nil;

+(instancetype)getInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^(){
        if(locationManager == nil){
            locationManager = [[AMapLocationManager alloc]init];
            [locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
            //   定位超时时间，最低2s，此处设置为2s
            locationManager.locationTimeout =2;
            //   逆地理请求超时时间，最低2s，此处设置为2s
            locationManager.reGeocodeTimeout = 2;
        }
        if(instance == nil){
            instance = [[LocateManager alloc]init];
        }
    });
    return instance;
}


-(void)locate:(void(^)(CLLocation *))callback{
    
    [AMapServices sharedServices].apiKey =@"0b1d7d0b917465bbfcf57db029a62c4f";
    // 带逆地理信息的一次定位（返回坐标和地址信息）
    
    // 带逆地理（返回坐标和地址信息）。将下面代码中的 YES 改成 NO ，则不会返回地址信息。
    [locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        
        if (error)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            
            if (error.code == AMapLocationErrorLocateFailed)
            {
                return;
            }
        }
        
        NSLog(@"location:%@", location);
        
        if(callback){
            callback(location);
        }
        
        if (regeocode)
        {
            NSLog(@"reGeocode:%@", regeocode);
        }
    }];
    
}

@end
