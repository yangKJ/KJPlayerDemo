//
//  ViewController.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/20.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "ViewController.h"
#import "DBPlayerDataInfo.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSArray *temps;
@property(nonatomic,strong) NSArray *setemps;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"KJPlayerDemo 🎷";
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, width, height-100-PLAYER_BOTTOM_SPACE_HEIGHT)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 50;
    _tableView.sectionHeaderHeight = 40;
    [self.view addSubview:self.tableView];
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame = CGRectMake(10, height-100-PLAYER_BOTTOM_SPACE_HEIGHT, width-20, 100);
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"大家觉得好用还请点个星，遇见什么问题也可issues，持续更新ing.." attributes:@{
        NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle),
        NSForegroundColorAttributeName:UIColor.redColor}];
    [button setAttributedTitle:attrStr forState:(UIControlStateNormal)];
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.textAlignment = 1;
    [button addTarget:self action:@selector(kj_button) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button];
    
    [self test];
    
    self.setemps = @[@"功能区",@"控件区",@"其他"];
}
- (void)kj_button{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/yangKJ/KJPlayerDemo"]];
#pragma clang diagnostic pop
}
- (NSArray*)temps{
    if (!_temps) {
        NSMutableArray *temp0 = [NSMutableArray array];
        [temp0 addObject:@{@"VCName":@"KJLoadingPlayerVC",@"describeName":@"加载动画和提示框测试"}];
        [temp0 addObject:@{@"VCName":@"KJTryLookPlayerVC",@"describeName":@"试看时间播放测试"}];
        [temp0 addObject:@{@"VCName":@"KJCachePlayerVC",@"describeName":@"断点续载续播缓存测试"}];
        [temp0 addObject:@{@"VCName":@"KJRecordPlayerVC",@"describeName":@"记录上次播放时间测试"}];
        [temp0 addObject:@{@"VCName":@"KJM3u8PlayerVC",@"describeName":@"m3u8格式播放"}];
        [temp0 addObject:@{@"VCName":@"KJSkipHeadPlayerVC",@"describeName":@"跳过片头播放测试"}];
        [temp0 addObject:@{@"VCName":@"KJScreenshotsPlayerVC",@"describeName":@"视频截图测试"}];
        
        NSMutableArray *temp1 = [NSMutableArray array];
        [temp1 addObject:@{@"VCName":@"KJListPlayerVC",@"describeName":@"缓存视频列表"}];
        [temp1 addObject:@{@"VCName":@"KJTablePlayerVC",@"describeName":@"列表播放器"}];
        
        NSMutableArray *temp2 = [NSMutableArray array];
        [temp2 addObject:@{@"VCName":@"KJAVPlayerVC",@"describeName":@"AVPlayer内核播放器"}];
        [temp2 addObject:@{@"VCName":@"KJMidiPlayerVC",@"describeName":@"Midi播放器"}];
        [temp2 addObject:@{@"VCName":@"KJOldPlayerVC",@"describeName":@"老版本播放器"}];
        
        _temps = @[temp0,temp1,temp2];
    }
    return _temps;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.setemps.count;
}
- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.temps[section] count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.setemps[section];
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font = [UIFont boldSystemFontOfSize:15];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableViewCell"];
    if (!cell) cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"tableViewCell"];
    NSDictionary *dic = self.temps[indexPath.section][indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld. %@",indexPath.row + 1,dic[@"VCName"]];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    cell.textLabel.textColor = UIColor.blueColor;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.text = dic[@"describeName"];
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:13];
    cell.detailTextLabel.textColor = [UIColor.blueColor colorWithAlphaComponent:0.5];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = self.temps[indexPath.section][indexPath.row];
    UIViewController *vc = [[NSClassFromString(dic[@"VCName"]) alloc]init];
    vc.title = dic[@"describeName"];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)test{
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).lastObject;
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:document];
    NSMutableArray *temps = [NSMutableArray array];
    NSString *imageName;
    while((imageName = [enumerator nextObject]) != nil) {
        [temps addObject:imageName];
    }
    NSLog(@"\n视频文件,%@",temps);
}

@end
