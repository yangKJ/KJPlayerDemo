//
//  ViewController.m
//  KJPlayerDemo
//
//  Created by 77。 on 2021/8/8.
//  https://github.com/yangKJ/KJPlayerDemo

#import "ViewController.h"
#import "KJPlayerHeader.h"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,strong) NSArray *temps;
@property(nonatomic,strong) NSArray *setemps;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self setupUI];
    [self setDatas];
}

- (void)initUI{
    self.title = @"KJPlayerDemo 🎷";
    //暗黑模式
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                return UIColor.whiteColor;
            } else {
                return UIColor.blackColor;
            }
        }];
    } else {
        self.view.backgroundColor = UIColor.whiteColor;
    }
}

- (void)setupUI{
    [self.view addSubview:self.tableView];
    
    CGSize size = self.view.frame.size;
    UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
    button.frame = CGRectMake(10, size.height-100-PLAYER_BOTTOM_SPACE_HEIGHT, size.width-20, 100);
    NSDictionary * attributes = @{
        NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle),
        NSForegroundColorAttributeName : UIColor.redColor
    };
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]
                                          initWithString:@"大家觉得好用还请点个星，遇见什么问题请留言，持续更新ing.."
                                          attributes:attributes];
    [button setAttributedTitle:attrStr forState:(UIControlStateNormal)];
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.textAlignment = 1;
    [button addTarget:self action:@selector(kj_button) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:button];
}

- (void)setDatas{
    self.setemps = @[@"流媒体专区",@"控件区",@"功能区",@"其他"];
    [KJPlayerLog openLogRankType:(KJPlayerVideoRankTypeAll)];
}

#pragma mark - action

- (void)kj_button{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/yangKJ/KJPlayerDemo"]];
#pragma clang diagnostic pop
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
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class)];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
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

#pragma mark - lazy

- (UITableView *)tableView{
    if (!_tableView) {
        CGSize size = self.view.frame.size;
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.frame = CGRectMake(0, 0, size.width, size.height-100-PLAYER_BOTTOM_SPACE_HEIGHT);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50;
        _tableView.sectionHeaderHeight = 40;
        _tableView.sectionFooterHeight = 0.01;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
        [_tableView registerClass:UITableViewCell.class
           forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
    }
    return _tableView;
}

- (NSArray *)temps{
    if (!_temps) {
        NSMutableArray *temp = [NSMutableArray array];
        [temp addObject:@{@"VCName":@"KJLivePlayerVC",@"describeName":@"直播流媒体测试"}];
        [temp addObject:@{@"VCName":@"KJM3u8PlayerVC",@"describeName":@"AVPlayer流媒体播放"}];
        [temp addObject:@{@"VCName":@"KJIJKPlayerVC",@"describeName":@"IJKPlayer流媒体播放"}];
        
        NSMutableArray *temp1 = [NSMutableArray array];
        [temp1 addObject:@{@"VCName":@"KJTablePlayerVC",@"describeName":@"无缝衔接列表播放"}];
        [temp1 addObject:@{@"VCName":@"KJListPlayerVC",@"describeName":@"缓存视频列表"}];
//        [temp1 addObject:@{@"VCName":@"KJChangeSourceVC",@"describeName":@"动态切换内核播放测试"}];
        [temp1 addObject:@{@"VCName":@"KJLoadingPlayerVC",@"describeName":@"加载动画和提示框测试"}];
        
        NSMutableArray *temp0 = [NSMutableArray array];
        [temp0 addObject:@{@"VCName":@"KJScreenPlayerVC",@"describeName":@"全屏播放测试"}];
        [temp0 addObject:@{@"VCName":@"KJRecordPlayerVC",@"describeName":@"记录上次播放时间测试"}];
        [temp0 addObject:@{@"VCName":@"KJCachePlayerVC",@"describeName":@"断点续载续播缓存测试"}];
        [temp0 addObject:@{@"VCName":@"KJTryLookPlayerVC",@"describeName":@"试看时间播放测试"}];
        [temp0 addObject:@{@"VCName":@"KJSkipHeadPlayerVC",@"describeName":@"跳过片头播放测试"}];
        [temp0 addObject:@{@"VCName":@"KJScreenshotsPlayerVC",@"describeName":@"视频截图测试"}];
        
        NSMutableArray *temp2 = [NSMutableArray array];
        [temp2 addObject:@{@"VCName":@"KJAVPlayerVC",@"describeName":@"AVPlayer内核播放器"}];
        [temp2 addObject:@{@"VCName":@"KJMidiPlayerVC",@"describeName":@"Midi播放器"}];
        [temp2 addObject:@{@"VCName":@"KJOldPlayerVC",@"describeName":@"老版本播放器"}];
        
        _temps = @[temp,temp1,temp0,temp2];
    }
    return _temps;
}

@end
