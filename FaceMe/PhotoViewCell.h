//
//  PhotoViewCell.h
//  FaceMe
//
//  Created by JIANBO WANG on 2018/9/9.
//  Copyright © 2018年 JIANBO WANG. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PhotoViewCell : UITableViewCell
//设置点击评论图标回调block
@property(nonatomic,copy) void (^commentClick)();
@property(nonatomic,copy) void (^likeClick)();

+(instancetype)getCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
-(void)setData:(BmobObject *)data;
-(void)syncLikeStatus:(BmobObject *)data;

@end
