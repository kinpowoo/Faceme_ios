//
//  User.m
//  FaceMe
//
//  Created by JIANBO WANG on 2018/9/9.
//  Copyright © 2018年 JIANBO WANG. All rights reserved.
//

#import "User.h"

@implementation User

+(BmobUser *)getUser{
    static BmobUser *user = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^(){
        if(user == nil){
            user = [BmobUser currentUser];
        }
    });
    return user;
}


@end
