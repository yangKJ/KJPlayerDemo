//
//  ViewController.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2019/7/20.
//  Copyright © 2019 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSArray *temps;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 44;
    [self.view addSubview:self.tableView];
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

@end
