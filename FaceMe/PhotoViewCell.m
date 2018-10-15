//
//  PhotoViewCell.m
//  FaceMe
//
//  Created by JIANBO WANG on 2018/9/9.
//  Copyright © 2018年 JIANBO WANG. All rights reserved.
//

#import "PhotoViewCell.h"
#import "UIImageView+WebCache.h"

@interface PhotoViewCell(){
    
}
@property (weak, nonatomic) IBOutlet UIView *headbox;
@property (weak, nonatomic) IBOutlet UIImageView *portrait;
@property (weak, nonatomic) IBOutlet UILabel *username_lb;
@property (weak, nonatomic) IBOutlet UILabel *publishTime_lb;
@property (weak, nonatomic) IBOutlet UIImageView *contentImage;
@property (weak, nonatomic) IBOutlet UILabel *contentText;
@property (weak, nonatomic) IBOutlet UIView *tags_box;
@property (weak, nonatomic) IBOutlet UILabel *publish_loc;
@property (weak, nonatomic) IBOutlet UILabel *comment_num_lb;
@property (weak, nonatomic) IBOutlet UIView *statusActions;
@property (weak, nonatomic) IBOutlet UILabel *favorite_num_lb;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UILabel *tag1;
@property (weak, nonatomic) IBOutlet UILabel *tag2;
@property (weak, nonatomic) IBOutlet UILabel *tag3;

@end

@implementation PhotoViewCell

+(instancetype)getCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    
    PhotoViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"www.kinpowoo.cell" forIndexPath:indexPath];
    if(cell == nil){
        cell = [[[NSBundle mainBundle]loadNibNamed:@"UITableCell" owner:nil
                                          options:nil] lastObject];
    }
    //让cell没有点击效果
    //cell.selected = NO;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}


-(void)setData:(BmobObject *)data{
    if(data){
   
        BmobUser *user = [data objectForKey:@"author"];
        BmobFile *head = [user objectForKey:@"portrait"];
        [_portrait sd_setImageWithURL:[NSURL URLWithString:head.url]];
        UIImage* oldImage = [ConstantUtil circleImage:_portrait.image] ;
        _portrait.image = oldImage;
        _username_lb.text=user.username;
        _publishTime_lb.text = [ConstantUtil stringFromDate:data.createdAt];
        
        BmobFile *photo = [data objectForKey:@"photo"];
        [_contentImage sd_setImageWithURL:[NSURL URLWithString:photo.url]];
        _contentText.text = [data objectForKey:@"text"];
        _publish_loc.text = [data objectForKey:@"locName"];
        
        //评论条数
        NSNumber *num = [data objectForKey:@"commentNum"];
        NSString *commentStr = [NSString stringWithFormat:@"%d条评论",num==nil?0:(num.intValue)];
        _comment_num_lb.text = commentStr;
        
        //点赞个数
        NSNumber *favNum = [data objectForKey:@"favoriteNum"];
        NSString *favStr = [NSString stringWithFormat:@"%d个赞",favNum==nil?0:(favNum.intValue)];
        _favorite_num_lb.text = favStr;
        
        //tag标签
        NSArray* tagArray = (NSArray *)[data objectForKey:@"tags"];
        if(tagArray){
            if(tagArray.count >= 1){
                _tag1.hidden = NO;
                _tag1.text = (NSString *)tagArray[0];
            }
            if(tagArray.count >= 2){
                _tag2.hidden = NO;
                _tag2.text = (NSString *)tagArray[1];
            }
            
            if(tagArray.count == 3){
                _tag3.hidden = NO;
                _tag3.text = (NSString *)tagArray[2];
            }
        }
        
        
        NSNumber *favByMe = [data objectForKey:@"favoritedByMe2"];
        BOOL isFavByMe = favByMe.boolValue;
        if(isFavByMe){
            [_likeBtn setImage:[UIImage imageNamed:@"favorite_red.png"] forState:UIControlStateNormal];
        }else{
            [_likeBtn setImage:[UIImage imageNamed:@"favorite.png"] forState:UIControlStateNormal];
        }
    }
}


//加载xib结束
- (void)awakeFromNib {
    [super awakeFromNib];
    
    _contentImage.contentMode = UIViewContentModeScaleAspectFill;
    _tag1.layer.cornerRadius = 3.0;
    _tag1.layer.borderColor = [UIColor orangeColor].CGColor;
    _tag1.layer.borderWidth = 0.5f;
    _tag2.layer.cornerRadius = 3.0;
    _tag2.layer.borderColor = [UIColor orangeColor].CGColor;
    _tag2.layer.borderWidth = 0.5f;
    _tag3.layer.cornerRadius = 3.0;
    _tag3.layer.borderColor = [UIColor orangeColor].CGColor;
    _tag3.layer.borderWidth = 0.5f;
}


//评论按钮被点击
- (IBAction)commentClick:(id)sender {
    if(self.commentClick){
        self.commentClick();
    }
}


//喜欢按钮被点击
- (IBAction)likeBtnClick:(id)sender {
    if(self.likeClick){
        self.likeClick();
    }
}


-(void)syncLikeStatus:(BmobObject *)data{
    NSNumber *favByMe = [data objectForKey:@"favoritedByMe2"];
    BOOL isFavByMe = favByMe.boolValue;
    NSLog(@"IS fav by Me %d",isFavByMe);
    
    NSNumber *favNumber = [data objectForKey:@"favoriteNum"];
    if(isFavByMe){
        [data setObject:@0 forKey:@"favoritedByMe2"];
        [data setObject:[NSNumber numberWithInt:(favNumber.intValue -1)] forKey:@"favoriteNum"];
        
        BmobObject *statusObj = [BmobObject objectWithoutDataWithClassName:@"Status"
                                                                  objectId:data.objectId];
        [statusObj decrementKey:@"favoriteNum"];
        [statusObj setObject:[NSNumber numberWithBool:NO] forKey:@"favoritedByMe2"];
        [statusObj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            if(isSuccessful){
                NSLog(@"更新喜欢状态成功");
                [_likeBtn setImage:[UIImage imageNamed:@"favorite.png"]
                          forState:UIControlStateNormal];
                
                NSNumber *favNum = [data objectForKey:@"favoriteNum"];
                NSString *favStr = [NSString stringWithFormat:@"%d个赞",favNum==nil?0:(favNum.intValue)];
                _favorite_num_lb.text = favStr;
            }else{
                NSLog(@"更新喜欢状态失败");
            }
        }];
        
    }else{
        [data setObject:@1 forKey:@"favoritedByMe2"];
        [data setObject:[NSNumber numberWithInt:(favNumber.intValue +1)] forKey:@"favoriteNum"];
        
        BmobObject *statusObj = [BmobObject objectWithoutDataWithClassName:@"Status"
                                                                  objectId:data.objectId];
        [statusObj incrementKey:@"favoriteNum"];
        [statusObj setObject:[NSNumber numberWithBool:YES] forKey:@"favoritedByMe2"];
        [statusObj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            if(isSuccessful){
                NSLog(@"更新喜欢状态成功");
                [_likeBtn setImage:[UIImage imageNamed:@"favorite_red.png"]
                          forState:UIControlStateNormal];
                
                NSNumber *favNum = [data objectForKey:@"favoriteNum"];
                NSString *favStr = [NSString stringWithFormat:@"%d个赞",favNum==nil?0:(favNum.intValue)];
                _favorite_num_lb.text = favStr;
            }else{
                NSLog(@"更新喜欢状态失败");
            }
        }];
    }
}

@end
