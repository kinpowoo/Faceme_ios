//
//  UserViewController.m
//  FaceMe
//
//  Created by JIANBO WANG on 2018/9/8.
//  Copyright © 2018年 JIANBO WANG. All rights reserved.
//

#import "UserViewController.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "UserSettingsViewController.h"
#import "SettingsViewController.h"
#import "EditStatusViewController.h"

@interface UserViewController () <UICollectionViewDelegate,UICollectionViewDataSource,
        UICollectionViewDelegateFlowLayout>{
    NSMutableArray *dataSource;
    BmobUser *user;
}
@property (weak, nonatomic) IBOutlet UIImageView *portrait;
@property (weak, nonatomic) IBOutlet UILabel *publishNum;
@property (weak, nonatomic) IBOutlet UILabel *stars;
@property (weak, nonatomic) IBOutlet UILabel *fans;
@property (weak, nonatomic) IBOutlet UIButton *editUserPageBtn;
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet UICollectionView *mCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *mfl;

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化数据
    user = [ConstantUtil getUser];
    dataSource = [NSMutableArray array];
    [self loadData];
 
    
    self.navigationItem.title = user.username;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];     //导航栏中文字颜色
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];  //导航栏背景颜色
    
    UIBarButtonItem *settings = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStylePlain
                                                               target:self action:@selector(goSettings)];
    self.navigationItem.rightBarButtonItem = settings;
    
    //编辑个人信息btn边框
    _editUserPageBtn.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _editUserPageBtn.layer.borderWidth = 1.0;
    _editUserPageBtn.layer.cornerRadius = 5.0;
    
    
    //填充user信息
    BmobFile *head = [user objectForKey:@"portrait"];
    [_portrait sd_setImageWithURL:[NSURL URLWithString:head.url]];
    UIImage* oldImage = [ConstantUtil circleImage:_portrait.image] ;
    _portrait.image = oldImage;
    
    _nickName.text = [user objectForKey:@"nickname"];
    NSNumber *likesNum = [user objectForKey:@"likesNum"];
    _stars.text = [NSString stringWithFormat:@"%@",likesNum==nil?@0:likesNum];
    NSNumber *followNum = [user objectForKey:@"followingNum"];
    _fans.text = [NSString stringWithFormat:@"%@",followNum==nil?@0:followNum];
    
    BmobQuery *query = [[BmobQuery alloc]initWithClassName:@"Status"];
    [query whereKey:@"author" equalTo:user];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        _publishNum.text = [NSString stringWithFormat:@"%d",number];
    }];
    
    
    //设置collectionView信息
    _mCollectionView.delegate = self;
    _mCollectionView.dataSource = self;
    [_mCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"www.kinpowoo.collectionViewCell"];
    _mCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^(){
        [_mCollectionView.mj_header beginRefreshing];
        [self loadData];
    }];
    
    
    // flow layout
    float singw = (SW-6)/3;
    self.mfl.itemSize = CGSizeMake(singw,floorf(singw));
    self.mfl.minimumLineSpacing = 5;
    self.mfl.minimumInteritemSpacing = 3;
    self.mfl.sectionInset = UIEdgeInsetsMake(0,0,0,0);
    
    
    //注册广播监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemChange:)
                name:@"itemUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDelete:)
                name:@"StatusDelete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemAdd:)
                name:@"StatusAdd" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userUpdate)
                name:@"UserUpdate" object:nil];
}


//条目被更新
-(void)itemChange:(NSNotification *)notify{
    NSDictionary *dic = notify.userInfo;
    if(dic){
        int index = ((NSNumber *)[dic objectForKey:@"row"]).intValue;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        BmobObject *item = [dataSource objectAtIndex:index];
        
        BmobQuery *query = [BmobQuery queryWithClassName:@"Status"];
        [query includeKey:@"author"];
        [query getObjectInBackgroundWithId:item.objectId block:^(BmobObject *object, NSError *error) {
            [dataSource replaceObjectAtIndex:index withObject:object];
            //更新指定位置
            [_mCollectionView reloadItemsAtIndexPaths:@[indexPath]];
        }];
    }
}



//条目被删除
-(void)itemDelete:(NSNotification *)notify{
    NSDictionary *dic = notify.userInfo;
    if(dic){
        int rowIndex = ((NSNumber *)[dic objectForKey:@"row"]).intValue;
        [dataSource removeObjectAtIndex:rowIndex];
        [_mCollectionView reloadData];
    }
    
    //更新发布数量
    BmobQuery *query = [BmobQuery queryWithClassName:@"Status"];
    [query whereKey:@"author" equalTo:[BmobUser currentUser]];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        _publishNum.text = [NSString stringWithFormat:@"%d",number];
    }];
}



//用户信息被更新
-(void)userUpdate{
    BmobQuery *query = [BmobQuery queryForUser];
    [query getObjectInBackgroundWithId:[BmobUser currentUser].objectId
        block:^(BmobObject *object, NSError *error) {
            if(object){
                BmobFile *head = [object objectForKey:@"portrait"];
                [_portrait sd_setImageWithURL:[NSURL URLWithString:head.url]];
                UIImage* oldImage = [ConstantUtil circleImage:_portrait.image] ;
                _portrait.image = oldImage;
                
                _nickName.text = [object objectForKey:@"nickname"];
            }
    }];
}



//条目被新增
-(void)itemAdd:(NSNotification *)notify{
    NSDictionary *dic = notify.userInfo;
    if(dic){
        NSDate *publishTime = (NSDate *)[dic objectForKey:@"createTime"];
        
        BmobQuery *query = [BmobQuery queryWithClassName:@"Status"];
        [query whereKey:@"author" equalTo:[BmobUser currentUser]];
        [query whereKey:@"createdAt" greaterThan:publishTime];
        [query includeKey:@"author"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            
            if(array){
            //插入新数据并刷新
                for(int i=0;i<array.count;i++){
                    [dataSource insertObject:array[i] atIndex:0];
                }
                [_mCollectionView reloadData];
                
                _publishNum.text = [NSString stringWithFormat:@"%d",(int)dataSource.count];
            }
        }];
    }
}



-(void)goSettings{
    SettingsViewController *settingsVC = [[SettingsViewController alloc]init];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

- (IBAction)editUserPageAction:(id)sender {
    UserSettingsViewController *userSettingsVC = [[UserSettingsViewController alloc]init];
    [self.navigationController pushViewController:userSettingsVC animated:NO];
}



-(void)loadData{
    [dataSource removeAllObjects];
    
    BmobQuery *query = [BmobQuery queryWithClassName:@"Status"];
    [query whereKey:@"author" equalTo:user];
    [query includeKey:@"author"];
    //声明该次查询需要将author关联对象信息一并查询出来
    //[query includeKey:@"author"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if(!error){
            [dataSource removeAllObjects];
            [dataSource addObjectsFromArray:array];
            //刷新布局
            [_mCollectionView.collectionViewLayout invalidateLayout];
            [_mCollectionView reloadData];
            
            _publishNum.text = [NSString stringWithFormat:@"%d",(int)array.count];
        }
        
        
        if(_mCollectionView.mj_header != nil){
            [_mCollectionView.mj_header endRefreshing];
        }
    }];
}





#pragma mark <CollectionView Delegate>

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return dataSource.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"www.kinpowoo.collectionViewCell" forIndexPath:indexPath];
    if(cell == nil){
        cell = [[UICollectionViewCell alloc]init];
    }
    
    for(UIView *view in cell.subviews){
        [view removeFromSuperview];
    }
    
    /**
    if(dataSource.count<=indexPath.row){
        return cell;
    }*/
    BmobObject *obj = [dataSource objectAtIndex:indexPath.row];
    BmobFile *contentImg = [obj objectForKey:@"photo"];
    UIImageView *imgView = [[UIImageView alloc]init];
    imgView.frame = CGRectMake(0,0,CGRectGetMaxX(cell.bounds),CGRectGetMaxY(cell.bounds));
    imgView.contentMode = UIViewContentModeScaleToFill;
    
    [imgView sd_setImageWithURL:[NSURL URLWithString:contentImg.url]];
    [cell addSubview:imgView];
    
    
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    EditStatusViewController *editVC = [[EditStatusViewController alloc]init];
    BmobObject *status = [dataSource objectAtIndex:indexPath.row];
    
    editVC.status = status;
    editVC.indexRow = (int)indexPath.row;
    [self presentViewController:editVC animated:YES completion:nil];
}


//定义每个UICollectionView 的大小
/**
- ( CGSize )collectionView:( UICollectionView *)collectionView layout:( UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:( NSIndexPath *)indexPath {
    return CGSizeMake((SW-40)/3.0,(SW-40)/3.0);
}

//设置水平间距 (同一行的cell的左右间距）

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

//垂直间距 (同一列cell上下间距)
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}*/



-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"itemUpdate" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"StatusDelete" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"StatusAdd" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UserUpdate" object:nil];
}


@end
