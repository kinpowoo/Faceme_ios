//
//  CommentViewController.m
//  FaceMe
//
//  Created by JIANBO WANG on 2018/10/13.
//  Copyright © 2018年 JIANBO WANG. All rights reserved.
//

#import "CommentViewController.h"
#import "UIImageView+WebCache.h"

@interface CommentViewController () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    NSMutableArray *comments;
    BmobUser* atObject;    //@某人的对象
}
@property (weak, nonatomic) IBOutlet UIImageView *portrait;
@property (weak, nonatomic) IBOutlet UILabel *nickname;
@property (weak, nonatomic) IBOutlet UILabel *statusContent;
@property (weak, nonatomic) IBOutlet UITableView *commentList;
@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;


@end

@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化数组
    comments = [NSMutableArray array];
    
    atObject = nil;
    
    //填充单条动态信息
    if(_item){
        BmobUser *user = [_item objectForKey:@"author"];
        BmobFile *head = [user objectForKey:@"portrait"];
        [_portrait sd_setImageWithURL:[NSURL URLWithString:head.url]];
        UIImage* oldImage = [ConstantUtil circleImage:_portrait.image] ;
        _portrait.image = oldImage;
        _nickname.text=user.username;
        _statusContent.text = [_item objectForKey:@"text"];
    }
    
    
    //设置tableView属性及注册cell
    _commentList.delegate = self;
    _commentList.dataSource = self;
    [_commentList registerClass:[UITableViewCell class] forCellReuseIdentifier:@"comment.cell"];
    
    
    //拉取评论数据
    [self pullRelevantComment];
    
    
    //设置评论输入文本的变化 注意：事件类型是：`UIControlEventEditingChanged`
    [_inputField addTarget:self action:@selector(passConTextChange:) forControlEvents:UIControlEventEditingChanged];
    
    
    //设置输入框边框效果
    _inputField.layer.borderColor = [UIColor blueColor].CGColor;
    _inputField.layer.borderWidth = 1.0;
    _inputField.delegate = self;
}




//内容输入变化监听
-(void)passConTextChange:(id)sender {
    UITextField* target=(UITextField*)sender;
    
    NSString *commentStr = target.text;
    if(![commentStr containsString:@"@"]){
        if(atObject != nil){
            atObject = nil;
        }
    }
}





//查询与动态相关的评论信息
-(void)pullRelevantComment{
    BmobQuery *query = [[BmobQuery alloc]initWithClassName:@"Comment"];
    [query whereKey:@"toStatus" equalTo:_item];
    [query includeKey:@"commentor,replyToUser"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if(array){
            [comments addObjectsFromArray:array];
            [_commentList reloadData];
        }
    }];
}


//提交评论内容
- (IBAction)commitComment:(id)sender {
    //如果评论内容为空则直接返回
    NSString *commentContent = [_inputField.text stringByTrimmingCharactersInSet:
                                [NSCharacterSet whitespaceCharacterSet]];
    if([commentContent isEqualToString:@""]){
        [ConstantUtil alert:self title:@"提示" msg:@"评论内容不能为空"];
        return;
    }
    
    //点击提交后将提交按钮置为不可选状态
    [_sendBtn setEnabled:false];
    
    //构建评论对象
    BmobObject *comment = [BmobObject objectWithClassName:@"Comment"];
    [comment setObject:commentContent forKey:@"text"];
    [comment setObject:[ConstantUtil getUser] forKey:@"commentor"];   //设置评论人
    if(atObject != nil){   //如果有@的对象
        [comment setObject:atObject forKey:@"replyToUser"];
    }else{
        //没有就等于回复自己
        [comment setObject:[ConstantUtil getUser] forKey:@"replyToUser"];
    }
    [comment setObject:_item forKey:@"toStatus"];

    [comment saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        //不管是否提交成功，将提交按钮还原
        [_sendBtn setEnabled:YES];
        
        if(isSuccessful){
            //如果成功了，将这新的一条加到数组中，刷新table
            
            BmobQuery *query = [BmobQuery queryWithClassName:@"Comment"];
            [query includeKey:@"commentor,replyToUser"];
            [query getObjectInBackgroundWithId:comment.objectId block:^(BmobObject *object, NSError *error) {
                
                [comments insertObject:object atIndex:0];
                [_commentList reloadData];
                
                //清空输入框
                _inputField.text =@"";
                
                //增加 status的评论数
                BmobObject *statusToBeChanged = [BmobObject objectWithoutDataWithClassName:@"Status"
                              objectId:_item.objectId];
                [statusToBeChanged incrementKey:@"commentNum"];
                [statusToBeChanged updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    if (isSuccessful) {
                        NSLog(@"增加数量成功");
                    } else {
                        NSLog(@"增加数量失败");
                    }
                }];
            }];
        }
    }];
}



//返回按钮被点击
- (IBAction)backClick:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"itemUpdate" object:nil userInfo:
     @{@"row":[NSNumber numberWithInt:_indexRow]}];
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark <UITableViewDelegate,DataSource>


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return comments.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"comment.cell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier:@"comment.cell"];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    BmobObject *comment = [comments objectAtIndex:indexPath.row];
    //设置头像
    BmobUser *user = [comment objectForKey:@"commentor"];
    BmobFile *head = [user objectForKey:@"portrait"];
    if(head){
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:head.url]];
    }else{
        cell.imageView.image = [UIImage imageNamed:@"portrait.png"];
    }
    
    //设置回复的内容
    BmobUser *replyTo = [comment objectForKey:@"replyToUser"];
    if([replyTo.objectId isEqualToString:user.objectId]){
        cell.textLabel.text = (NSString *)[comment objectForKey:@"text"];
    }else{
        
        /**
         NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"点击代表您已阅读并同意用户规则和协议"];
         NSRange range1 = [[str string] rangeOfString:@"点击代表您已阅读并同意"];
         [str addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:range1];
         NSRange range2 = [[str string] rangeOfString:@"用户规则"];
         [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range2];
         NSRange range3 = [[str string] rangeOfString:@"协议"];
         [str addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range3];
          label.attributedText = str;
         */
       
        NSString *prefix = [NSString stringWithFormat:@"@%@ ",replyTo.username];
        NSString *content = [prefix stringByAppendingString:(NSString *)[comment objectForKey:@"text"]];
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:content];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:NSMakeRange(0,prefix.length)];
        cell.textLabel.attributedText = str;
    }
    
    //设置回复的日期
    NSString *time = [ConstantUtil stringFromDate:comment.createdAt];
    cell.detailTextLabel.text = time;
    
    // to support ios8.0
    [cell layoutSubviews];
    
    return cell;
}



//选中cell回调
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(atObject!=nil){
        [ConstantUtil alert:self title:@"提示" msg:@"每条评论只能@一位用户"];
        return;
    }
    
    BmobObject *commentItem = [comments objectAtIndex:indexPath.row];
    BmobUser *user = [commentItem objectForKey:@"commentor"];
    
    NSString* inputedStr = _inputField.text;
    NSString* atStr = [NSString stringWithFormat:@"@%@",user.username];
    NSString *commentStr = [inputedStr stringByAppendingString:atStr];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:commentStr];
    NSRange range1 = [[str string] rangeOfString:atStr];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:range1];
    _inputField.attributedText = str;
    
    atObject = user;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


//是否允许编辑行
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    BmobObject *comment = [comments objectAtIndex:indexPath.row];
    
    BmobUser* author = [comment objectForKey:@"commentor"];
    BmobUser* currentUser = [ConstantUtil getUser];
    if([author.objectId isEqualToString:currentUser.objectId]){
        return true;
    }else{
        return false;
    }
}


//左滑菜单
-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
 

    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
             title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
                 BmobObject* commentItem = [comments objectAtIndex:indexPath.row];
                 BmobObject *bmobObject = [BmobObject objectWithoutDataWithClassName:@"Comment"
                                                                    objectId:commentItem.objectId];
                 [bmobObject deleteInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
                 if (isSuccessful) {
                     //删除成功后的动作,更新视图
                     NSLog(@"delete comment successful");
                     [comments removeObjectAtIndex:indexPath.row];
                     [_commentList reloadData];
                     
                     //减少status的评论数
                     BmobObject *statusToBeChanged = [BmobObject objectWithoutDataWithClassName:@"Status"
                                                                                       objectId:_item.objectId];
                     [statusToBeChanged decrementKey:@"commentNum"];
                     [statusToBeChanged updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                         if (isSuccessful) {
                             NSLog(@"减少数量成功");
                         } else {
                             NSLog(@"减少数量失败");
                         }
                     }];
                 } else if (error){
                     NSLog(@"%@",error);
                 } else {
                     NSLog(@"UnKnow error");
                 }
         }];
    }];
    // UITableViewRowActionStyleDestructive 是红色背景的方形按钮

    //返回按钮数组
    return @[action];
}



-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}


@end
