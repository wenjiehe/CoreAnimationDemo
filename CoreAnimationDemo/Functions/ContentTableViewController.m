//
//  ContentTableViewController.m
//  CoreAnimationDemo
//
//  Created by 贺文杰 on 2019/9/16.
//  Copyright © 2019 贺文杰. All rights reserved.
//

#import "ContentTableViewController.h"
#import "ContentDetailViewController.h"

@interface ContentTableViewController ()

@property(nonatomic,strong)NSArray *headTitleArray;
@property(nonatomic,strong)NSMutableArray *mtbAry;

@end

@implementation ContentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.tableHeaderView = nil;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"contentIdentifiercell"];
    
    self.headTitleArray = @[
                            @"隐式动画",
                            @"显示动画",
                            @"图层时间",
                            @"缓冲",
                            @"基于定时器的动画",
                            @"性能调优",
                            @"高效绘图",
                            @"图像IO",
                            @"图层性能"];
    self.mtbAry = [NSMutableArray arrayWithObjects:
                   @[@"事务", @"完成块", @"图层行为", @"呈现与模型"],
                   @[@"属性动画", @"动画组", @"过渡", @"在动画过程中取消动画"],
                   @[@"CAMediaTiming协议", @"层级关系时间", @"手动动画"],
                   @[@"动画速度", @"自定义缓冲函数"], @[@"定时帧", @"物理模拟"],
                   @[@"CPU VS GPU", @"测量，而不是猜测", @"instruments"],
                   @[@"软件绘图", @"矢量图形", @"脏矩形", @"异步绘制"],
                   @[@"加载和潜伏", @"缓存", @"文件格式"],
                   @[@"隐式绘制", @"离屏渲染", @"混合和过渡绘制", @"减少图层数量"], nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.headTitleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *ary = self.mtbAry[section];
    return ary.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contentIdentifiercell" forIndexPath:indexPath];
    
    NSArray *ary = self.mtbAry[indexPath.section];
    cell.textLabel.text = ary[indexPath.row];
    cell.textLabel.textColor = [UIColor grayColor];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"headIdentifier"];
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(15, 0, [UIScreen mainScreen].bounds.size.width - 30, 30);
    label.text = self.headTitleArray[section];
    [headView addSubview:label];
    return headView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击了section = %ld, row = %ld", indexPath.section, indexPath.row);
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ContentDetailViewController *vc = [sb instantiateViewControllerWithIdentifier:@"contentDetailSB"];
    vc.titleStr = self.headTitleArray[indexPath.section];
    NSArray *ary = self.mtbAry[indexPath.section];
    vc.subTitleStr = ary[indexPath.row];
    vc.indexPath = indexPath;
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSMutableArray *)mtbAry
{
    if (!_mtbAry) {
        _mtbAry = [NSMutableArray new];
    }
    return _mtbAry;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
