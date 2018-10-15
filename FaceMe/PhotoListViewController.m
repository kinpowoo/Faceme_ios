//
//  PhotoListViewController.m
//  FaceMe
//
//  Created by JIANBO WANG on 2018/9/8.
//  Copyright © 2018年 JIANBO WANG. All rights reserved.
//

#import "PhotoListViewController.h"
#import "PhotoViewCell.h"
#import "MJRefresh.h"
#import "CommentViewController.h"

@interface PhotoListViewController ()  <UITableViewDelegate,UITableViewDataSource>{
    UITableView *m_tableView;
    NSMutableArray *dataSource;
    NSMutableDictionary *heightAtIndexPath;//缓存高度所用字典
}

@end

@implementation PhotoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"动态";
    self.navigationController.navigationBar.barTintColor = [UIColor greenColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //将状态栏的背景颜色和文字颜色做出改变
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, -20,SW, 20)];
    statusBarView.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar addSubview:statusBarView];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    
    //table View 初始化
    m_tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0,SW,SH) style:UITableViewStylePlain];
    m_tableView.delegate = self;
    m_tableView.dataSource = self;
    [self.view addSubview:m_tableView];
    [m_tableView registerNib:[UINib nibWithNibName:@"PhotoViewCell" bundle:nil] forCellReuseIdentifier:@"www.kinpowoo.cell"];
    
    m_tableView.estimatedRowHeight = SH+200;
    m_tableView.rowHeight = UITableViewAutomaticDimension;
    m_tableView.mj_header = [MJRefreshGifHeader headerWithRefreshingBlock:^(){
        [m_tableView.mj_header beginRefreshing];
        [self loadData:NO];
    }];
    
    //初始化数组，并将重将加载的下标初始化为-1
    dataSource = [NSMutableArray array];
    [self loadData:YES];
    
    
    //注册item更新,删除监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemChange:) name:
     @"itemUpdate" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDelete:) name:
     @"StatusDelete" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemAdd:) name:
     @"StatusAdd" object:nil];
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
            [m_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
}



//条目被删除
-(void)itemDelete:(NSNotification *)notify{
    NSDictionary *dic = notify.userInfo;
    if(dic){
        int rowIndex = ((NSNumber *)[dic objectForKey:@"row"]).intValue;
        [dataSource removeObjectAtIndex:rowIndex];
        [m_tableView reloadData];
    }
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
            //插入新数据并刷新
            for(int i=0;i<array.count;i++){
                [dataSource insertObject:array[i] atIndex:0];
            }
            [m_tableView reloadData];
        }];
    }
}




#pragma mark <UITableDelegate>

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataSource.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PhotoViewCell *cell = [PhotoViewCell getCell:tableView indexPath:indexPath];
    NSLog(@"section: %d",(int)indexPath.section);
    BmobObject *obj = [dataSource objectAtIndex:indexPath.row];
    [cell setData:obj];
    
    cell.commentClick = ^(){
        CommentViewController *commentVC = [[CommentViewController alloc]init];
        commentVC.item = obj;
        commentVC.indexRow = (int)indexPath.row;
        [self.navigationController presentViewController:commentVC animated:YES completion:nil];
    };
    
    __weak typeof(cell) weakCell = cell;
    cell.likeClick = ^(){
        [weakCell syncLikeStatus:obj];
    };
    
    return cell;
}


/**
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}*/
//设置tableView的预估高度
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *height = [heightAtIndexPath objectForKey:indexPath];
    if(height)
    {
        return height.floatValue;
    }
    else
    {
        return SH+200;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *height = @(cell.frame.size.height);
    [heightAtIndexPath setObject:height forKey:indexPath];
}




-(void)loadData:(BOOL)isFirstLoad{
    NSUserDefaults *favor = [NSUserDefaults standardUserDefaults];
    NSDate* lastUpdate = [favor objectForKey:@"lastUpdateTime"];
    //[favor removeObjectForKey:@"lastUpdateTime"];
    //[favor synchronize];
    
    /**
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *lastTimeStr = [formatter stringFromDate:d];
   
    */
    NSLog(@"lastTimeStr: %@",lastUpdate);
     
    BmobQuery *query = [BmobQuery queryWithClassName:@"Status"];
    [query whereKey:@"author" equalTo:[ConstantUtil getUser]];
    //声明该次查询需要将author关联对象信息一并查询出来
    [query includeKey:@"author"];
    [query orderByDescending:@"createdAt"];
    if(lastUpdate!=nil && !isFirstLoad){
        [query whereKey:@"createdAt" greaterThan:lastUpdate];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        NSLog(@"更新了%ld条数据!",(long)array.count);
        if(!error && array.count > 0){
            //先清空数据源
            [dataSource removeAllObjects];
            
            [dataSource addObjectsFromArray:array];
            [m_tableView reloadData];
            
            NSUserDefaults *favor = [NSUserDefaults standardUserDefaults];
            NSDate *now = [[NSDate alloc]init];
            [favor setObject:now forKey:@"lastUpdateTime"];
            [favor synchronize];
        }
        
         [m_tableView.mj_header endRefreshing];
    }];
}


-(void)viewWillDisappear:(BOOL)animated{
    NSUserDefaults *favor = [NSUserDefaults standardUserDefaults];
    [favor removeObjectForKey:@"lastUpdateTime"];
    [favor synchronize];
}


-(void)dealloc{
    //移除广播监听
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"itemUpdate" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"StatusDelete" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"StatusAdd" object:nil];
}

@end
