//
//  EditStatusViewController.m
//  FaceMe
//
//  Created by JIANBO WANG on 2018/10/14.
//  Copyright © 2018年 JIANBO WANG. All rights reserved.
//

#import "EditStatusViewController.h"
#import "UIImageView+WebCache.h"
#import "CommentViewController.h"

#define SW [UIScreen mainScreen].bounds.size.width

@interface EditStatusViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *potrait;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UIImageView *contentImag;
@property (weak, nonatomic) IBOutlet UITextField *contentText;
@property (weak, nonatomic) IBOutlet UILabel *locAddr;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UILabel *publishTime;
@property (weak, nonatomic) IBOutlet UIButton *editDoneBtn;
@property (weak, nonatomic) IBOutlet UIButton *menuBtn;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation EditStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(_status){
        BmobUser *user = [_status objectForKey:@"author"];
        BmobFile *head = [user objectForKey:@"portrait"];
        [_potrait sd_setImageWithURL:[NSURL URLWithString:head.url]];
        UIImage* oldImage = [ConstantUtil circleImage:_potrait.image] ;
        _potrait.image = oldImage;
        _nickname.text=user.username;
        _publishTime.text = [ConstantUtil stringFromDate:_status.createdAt];
        
        BmobFile *photo = [_status objectForKey:@"photo"];
        [_contentImag sd_setImageWithURL:[NSURL URLWithString:photo.url]];
        _contentText.text = [_status objectForKey:@"text"];
        _locAddr.text = [_status objectForKey:@"locName"];
        
        //内容不可写
        _contentText.enabled = NO;
        _contentText.delegate = self;
        
        NSNumber *favByMe = [_status objectForKey:@"favoritedByMe2"];
        BOOL isFavByMe = favByMe.boolValue;
        if(isFavByMe){
            [_likeBtn setImage:[UIImage imageNamed:@"favorite_red.png"] forState:UIControlStateNormal];
        }
    }
    
    //将编辑完成按钮先隐藏
    _editDoneBtn.hidden = YES;
}


//所有页面组件完成布局后重新计算 ScrollView中 ContainerView的高度,用container中最底部View
//的Y值 + 你想留的padding
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    float bottomY = CGRectGetMaxY(_publishTime.frame) + 50;
    //self.scrollView.contentSize = CGSizeMake(SW,bottomY);
    //self.containerView.frame = CGRectMake(0,0,SW,bottomY);
}



//返回键被点击
- (IBAction)backClick:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"itemUpdate" object:nil
              userInfo:@{@"row":[NSNumber numberWithInt:_indexRow]}];
    [self dismissViewControllerAnimated:YES completion:nil];
}


//编辑完成按钮被点击
- (IBAction)editDoneClick:(id)sender {
    NSLog(@"完成按钮被点击");
    
    NSString *editedContent = _contentText.text;
    
    BmobObject *statusObj = [BmobObject objectWithoutDataWithClassName:@"Status"
                                                              objectId:_status.objectId];
    [statusObj setObject:editedContent forKey:@"text"];
    [statusObj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        _editDoneBtn.hidden = YES;     //隐藏编辑按钮
        _menuBtn.hidden = NO;        //显示菜单栏
        _contentText.enabled = NO;    //不允许编辑
        if(isSuccessful){
            [ConstantUtil alert:self title:@"编辑提示" msg:@"编辑动态成功"];
        }else{
            [ConstantUtil alert:self title:@"编辑提示" msg:@"编辑动态失败"];
        }
    }];
}



//菜单被点击
- (IBAction)menuClick:(id)sender {
    NSLog(@"菜单按钮被点击");
    
    UIAlertController *statusEditMenu = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionEdit = [UIAlertAction actionWithTitle:@"编辑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _contentText.enabled = YES;
        _menuBtn.hidden = YES;
        _editDoneBtn.hidden = NO;
    }];
    UIAlertAction *actionDelete = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [ConstantUtil choice:self title:@"删除提示" msg:@"您确定要删除本动态吗?" action:^{
            BmobObject *bmobObject = [BmobObject objectWithoutDataWithClassName:@"Status"
                                                                       objectId:_status.objectId];
            [bmobObject deleteInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error){
                if(isSuccessful){
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusDelete"
                            object:nil userInfo:@{@"row":[NSNumber numberWithInt:self.indexRow]}];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }else{
                    [ConstantUtil alert:self title:@"删除提示" msg:@"删除动态失败"];
                }
            }];
        }];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [statusEditMenu addAction:actionEdit];
    [statusEditMenu addAction:actionDelete];
    [statusEditMenu addAction:actionCancel];
    [self presentViewController:statusEditMenu animated:YES completion:nil];
}



//点击喜欢按钮
- (IBAction)likeClick:(id)sender {
    NSLog(@"喜欢按钮被点击");
    NSNumber *favByMe = [_status objectForKey:@"favoritedByMe2"];
    BOOL isFavByMe = favByMe.boolValue;
    NSLog(@"IS fav by Me %d",isFavByMe);
    if(isFavByMe){
        [_status setObject:@0 forKey:@"favoritedByMe2"];
        
        BmobObject *statusObj = [BmobObject objectWithoutDataWithClassName:@"Status"
                     objectId:_status.objectId];
        [statusObj decrementKey:@"favoriteNum"];
        [statusObj setObject:[NSNumber numberWithBool:NO] forKey:@"favoritedByMe2"];
        [statusObj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            if(isSuccessful){
                NSLog(@"更新喜欢状态成功");
                [_likeBtn setImage:[UIImage imageNamed:@"favorite.png"]
                          forState:UIControlStateNormal];
            }else{
                NSLog(@"更新喜欢状态失败");
            }
        }];
        
    }else{
        [_status setObject:@1 forKey:@"favoritedByMe2"];
        
        BmobObject *statusObj = [BmobObject objectWithoutDataWithClassName:@"Status"
                                                                  objectId:_status.objectId];
        [statusObj incrementKey:@"favoriteNum"];
        [statusObj setObject:[NSNumber numberWithBool:YES] forKey:@"favoritedByMe2"];
        [statusObj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            if(isSuccessful){
                NSLog(@"更新喜欢状态成功");
                [_likeBtn setImage:[UIImage imageNamed:@"favorite_red.png"]
                          forState:UIControlStateNormal];
            }else{
                NSLog(@"更新喜欢状态失败");
            }
        }];
    }
}



//点击评论按钮
- (IBAction)commentClick:(id)sender {
    NSLog(@"评论按钮被点击");
    CommentViewController* vc = [[CommentViewController alloc] init];
    vc.item = _status;
    [self presentViewController:vc animated:YES completion:nil];
}



#pragma mark <UITextFieldDelegate>
-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}


@end
