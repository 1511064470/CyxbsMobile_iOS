//
//  ReportViewController.m
//  MoblieCQUPT_iOS
//
//  Created by xiaogou134 on 2018/2/11.
//  Copyright © 2018年 Orange-W. All rights reserved.
//

#import "ReportViewController.h"
#import "ReportSortButton.h"
#import "ReportTextView.h"
#import "ReportModel.h"

@interface ReportViewController ()<UITableViewDelegate, UITableViewDataSource, ReportSuccess>
@property (strong, nonatomic) UITableView *reportTableView;
@property (strong, nonatomic) NSMutableArray *btnArray;
@property (strong, nonatomic) ReportTextView *textView;
@property (strong, nonatomic) UIButton *commitBtn;
@property (strong, nonatomic) NSMutableString *selectedStr;
@property (strong, nonatomic) ReportModel *dataModel;
@property (strong, nonatomic) NSString *qusId;
@property (strong, nonatomic) MBProgressHUD *hud;
@end

@implementation ReportViewController

- (instancetype)initWithId:(NSString *)qusId{
    if (self = [super init]) {
        _qusId = qusId.copy;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.reportTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.reportTableView.delegate = self;
    self.reportTableView.dataSource = self;
    
    self.reportTableView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    [self.view addSubview:self.reportTableView];
    
    _commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _commitBtn.frame = CGRectMake(self.view.width/2 - 150, self.reportTableView.bottom - 300, 300, 100);
    [_commitBtn addTarget:self action:@selector(tryCommit) forControlEvents:UIControlEventTouchUpInside];
    [_commitBtn setImage:[UIImage imageNamed:@"commit"] forState:UIControlStateNormal];
    [self.reportTableView addSubview:_commitBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//btn的响应
- (void)reportType:(UIButton *)sender{
    BOOL select = sender.selected;
    for (UIButton * btn in _btnArray) {
        btn.selected = NO;
    }
    sender.selected = !select;
    _selectedStr = sender.currentTitle.copy;
}

- (void)tryCommit{
    BOOL flag = NO;
    for (UIButton *btn in _btnArray) {
        if (btn.selected == YES) {
            flag = YES;
            break;
        }
    }
    if (_textView.text.length == 0 || flag == NO) {
        UIAlertController *alertcv = [UIAlertController alertControllerWithTitle:@"提示" message:@"请完善信息" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertcv addAction:confirmAction];
        [self presentViewController:alertcv animated:YES completion:nil];
    }
    else{
        _dataModel = [[ReportModel alloc] init];
        _dataModel.delegate = self;
        _dataModel.type = _selectedStr;
        _dataModel.content = _textView.text;
        _dataModel.qusId = _qusId;
        [_dataModel setReport];
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.labelText = @"正在上传";
        _hud.removeFromSuperViewOnHide = YES;
    }
}

- (void)report:(BOOL)success{
    [_hud hide:YES];
    if (success) {
        UIAlertController *alertcv = [UIAlertController alertControllerWithTitle:@"提示" message:@"已成功提交" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertcv addAction:confirmAction];
        [self presentViewController:alertcv animated:YES completion:nil];
    }
    else {
        UIAlertController *alertcv = [UIAlertController alertControllerWithTitle:@"提示" message:@"网络异常，请重新提交" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertcv addAction:confirmAction];
        [self presentViewController:alertcv animated:YES completion:nil];
    }
    
}

#pragma mark tableview协议
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [_reportTableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    //取消cell选择变色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //举报类型
    if (indexPath.section == 0) {
        _btnArray = [NSMutableArray array];
        NSArray *word = @[@"色情低俗", @"广告骚扰", @"违法信息", @"辱骂威胁", @"欺诈骗钱", @"政治敏感"];
        for (int i = 0; i < 6; i ++) {
            ReportSortButton *btn = [[ReportSortButton alloc] initWithFrame:CGRectMake(20 + 120 * (i % 3), 20 + 40 * (i / 3) , 100, 30) someWord:word[i]];
            btn.tag = i;
            [cell.contentView addSubview:btn];
            [btn addTarget:self action:@selector(reportType:) forControlEvents:UIControlEventTouchUpInside];
            [_btnArray addObject:btn];
        }
        
    }
    else{
        _textView = [[ReportTextView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
        [cell.contentView addSubview:_textView];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    UILabel *headViewLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH, 20)];
    headViewLab.textColor = kDetailTextColor;
    headViewLab.font = [UIFont fontWithName:@"Arial" size:12];
    if (section == 0) {
        headViewLab.text = @"请选择举报愿意";
    }
    else{
        headViewLab.text = @"请输入具体投诉原因(选填)";
    }
    [headView addSubview:headViewLab];
    return headView;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        return 100;
    }
    else{
        return 200;
    }
}

@end
