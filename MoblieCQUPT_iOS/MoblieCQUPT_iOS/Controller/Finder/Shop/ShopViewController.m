//
//  ShopViewController.m
//  MoblieCQUPT_iOS
//
//  Created by 张润峰 on 15/8/19.
//  Copyright (c) 2015年 Orange-W. All rights reserved.
//

#import "ShopViewController.h"
#import "ShopTableViewCell.h"
#import "ShopDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+AFNetworking.h"
#import "MJRefresh.h"
#import "WebViewController.h"

#define SHOPLIST_ENDPAGE 4

@interface ShopViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic)UITableView *tableView;
@property (strong, nonatomic)NSMutableArray *data;
@property (assign, nonatomic)NSInteger flag;

@end

@implementation ShopViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    self.navigationItem.title = @"周边小店";
    _flag = 1;
    
    [self setupRefresh];
    [self.view addSubview:self.tableView];
}

/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    
    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    
    // 设置文字(也可以不设置,默认的文字在MJRefreshConst中修改)
    self.tableView.headerPullToRefreshText = @"下拉即可刷新";
    self.tableView.headerReleaseToRefreshText = @"松开即可刷新";
    self.tableView.headerRefreshingText = @"正在刷新中";
    
    self.tableView.footerPullToRefreshText = @"上拉加载更多";
    self.tableView.footerReleaseToRefreshText = @"松开加载更多";
    self.tableView.footerRefreshingText = @"正在刷新中";
}


#pragma mark 开始进入刷新状态
- (void)headerRereshing{
    NSLog(@"下拉刷新");
    [NetWork NetRequestPOSTWithRequestURL:@"http://hongyan.cqupt.edu.cn/cyxbs_api_2014/cqupthelp/index.php/admin/shop/shopList" WithParameter:@{@"pid":@1} WithReturnValeuBlock:^(id returnValue) {
        [_data removeAllObjects];
        [_data addObjectsFromArray:[returnValue objectForKey:@"data"]];
        NSLog(@"data is %@", returnValue);
        // 刷新表格
        [self.tableView reloadData];
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        [self.tableView headerEndRefreshing];
    } WithFailureBlock:nil];
}

- (void)footerRereshing{
    NSLog(@"上拉加载");
    _flag += 1;
    if (_flag <= 3) {
        [NetWork NetRequestPOSTWithRequestURL:@"http://hongyan.cqupt.edu.cn/cyxbs_api_2014/cqupthelp/index.php/admin/shop/shopList" WithParameter:@{@"pid":[NSNumber numberWithInteger:_flag]} WithReturnValeuBlock:^(id returnValue) {
            [_data addObjectsFromArray:[returnValue objectForKey:@"data"]];
            // 刷新表格
            [self.tableView reloadData];
            // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
            [self.tableView footerEndRefreshing];
        } WithFailureBlock:nil];
    }else if (_flag >= 4){
        [self.tableView footerEndRefreshing];
    }
}

//覆盖初始化方法
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_W, MAIN_SCREEN_H)];
       [self dataFlash];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        UINib *nib = [UINib nibWithNibName:@"ShopTableViewCell" bundle:nil];//从当前工程中识别xib文件
        [_tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    }
    
    return _tableView;
}

- (void)dataFlash{
    [NetWork NetRequestPOSTWithRequestURL:@"http://hongyan.cqupt.edu.cn/cyxbs_api_2014/cqupthelp/index.php/admin/shop/shopList" WithParameter:@{@"pid":@1} WithReturnValeuBlock:^(id returnValue) {
        _data = [[NSMutableArray alloc] init];
        [_data addObjectsFromArray:[returnValue objectForKey:@"data"]];
        NSLog(@"data is %@", returnValue);
        [_tableView reloadData];
    } WithFailureBlock:nil];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentify = @"cell";//cell重用标识
    ShopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (!cell) {
        cell = [[ShopTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];//构造一个cell
    }

    [cell.picture setImageWithURL:[NSURL URLWithString:_data[indexPath.row][@"shopimg_src"]]];
    cell.nameLabel.text = _data[indexPath.row][@"name"];
    cell.addressLabel.text = _data[indexPath.row][@"shop_address"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ShopDetailViewController *detailViewController = [[ShopDetailViewController alloc] init];
    detailViewController.detailData = _data[indexPath.row];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end