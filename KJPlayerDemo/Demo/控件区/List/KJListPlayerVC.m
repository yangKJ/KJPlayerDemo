//
//  KJListPlayerVC.m
//  KJPlayerDemo
//
//  Created by 杨科军 on 2021/2/10.
//  Copyright © 2021 杨科军. All rights reserved.
//  https://github.com/yangKJ/KJPlayerDemo

#import "KJListPlayerVC.h"
#import "KJCacheManager.h"
#import "KJVideoPlayVC.h"
@interface KJListPlayerVC ()<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *temps;
@end

@implementation KJListPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.temps = [NSMutableArray array];
    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 90;
    [self.view addSubview:tableView];
    PLAYER_WEAKSELF;
    kGCD_player_async(^{
        NSArray *array = [DBPlayerDataManager kj_checkData:nil];
        weakself.temps = [NSMutableArray arrayWithArray:array];
        //剔除未缓存完整的数据
        for (DBPlayerData *data in array) {
            if (data.videoIntact) continue;
            [weakself.temps removeObject:data];
        }
        kGCD_player_main(^{
            [weakself.tableView reloadData];            
        });
    });
    NSLog(@"\n全部文件：%@\n文件大小：%lld",[KJCacheManager kj_videoAllFileNames],[KJCacheManager kj_videoCachedSize]);
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.temps count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    DBPlayerData *data = self.temps[indexPath.row];
    CGFloat w = tableView.frame.size.width;
    {
        UILabel *label = [UILabel new];
        label.frame = CGRectMake(20, 5, w-20, 40);
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor.blueColor colorWithAlphaComponent:0.7];
        [cell.contentView addSubview:label];
        label.text = [@"视频链接：" stringByAppendingString:data.videoUrl];
    }{
        UILabel *label = [UILabel new];
        label.frame = CGRectMake(20, 5+40, w-20, 20);
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:label];
        label.text = [@"dbid：" stringByAppendingString:data.dbid];
    }{
        UILabel *label = [UILabel new];
        label.frame = CGRectMake(20, 5+40+20, w-20, 20);
        label.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:label];
        label.text = [@"存储时间：" stringByAppendingString:[self ConvertStrToTime:data.saveTime]];
    }{
        UILabel *label = [UILabel new];
        label.frame = CGRectMake(20, 5+40+20, w-30, 20);
        label.textAlignment = NSTextAlignmentRight;
        label.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:label];
        label.text = [@"视频大小：" stringByAppendingFormat:@"%lld kb",data.videoContentLength/1024];
    }
    return cell;
}
//时间戳变为格式时间
- (NSString *)ConvertStrToTime:(NSInteger)time{
    NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:time];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString*timeString=[formatter stringFromDate:date];
    return timeString;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"\n--%@",self.temps[indexPath.row]);
    KJVideoPlayVC *vc = [KJVideoPlayVC new];
    vc.url = [NSURL URLWithString:((DBPlayerData*)self.temps[indexPath.row]).videoUrl];
    [self.navigationController pushViewController:vc animated:YES];
}
- (UISwipeActionsConfiguration*)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        DBPlayerData *data = self.temps[indexPath.row];
        if ([KJCacheManager kj_crearVideoCachedAndDatabase:data]) {
            NSLog(@"删除成功!!");
        }else{
            return;
        }
        [self.temps removeObjectAtIndex:indexPath.row];
        completionHandler(YES);
        [self.tableView reloadData];
    }];
//    deleteRowAction.image = [UIImage imageNamed:@"p"];
    deleteRowAction.backgroundColor = [UIColor redColor];
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction]];
    return config;
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
