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
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSArray *temps;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, width, height-100)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 44;
    [self.view addSubview:self.tableView];
    
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame = CGRectMake(10, height-100, width-20, 100);
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"大家觉得好用还请点个星，遇见什么问题也可issues，持续更新ing.." attributes:@{
        NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle),
        NSForegroundColorAttributeName:UIColor.redColor}];
    [button setAttributedTitle:attrStr forState:(UIControlStateNormal)];
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.textAlignment = 1;
    [button addTarget:self action:@selector(kj_button) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button];
    
    [self test];
}
- (void)kj_button{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/yangKJ/KJPlayerDemo"]];
#pragma clang diagnostic pop
}
- (NSArray*)temps{
    if (!_temps) {
        NSMutableArray *temp = [NSMutableArray array];
        [temp addObject:@{@"VCName":@"KJOldPlayerVC",@"describeName":@"播放器处理"}];
        [temp addObject:@{@"VCName":@"KJAVPlayerVC",@"describeName":@"AVPlayer内核播放器处理"}];
        [temp addObject:@{@"VCName":@"KJMidiPlayerVC",@"describeName":@"Midi播放器"}];
        _temps = temp.mutableCopy;
    }
    return _temps;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.temps.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableViewCell"];
    if (!cell) cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"tableViewCell"];
    NSDictionary *dic = self.temps[indexPath.row];
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
    NSDictionary *dic = self.temps[indexPath.row];
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
