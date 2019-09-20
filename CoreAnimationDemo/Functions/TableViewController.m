//
//  TableViewController.m
//  CoreAnimationDemo
//
//  Created by 贺文杰 on 2019/9/9.
//  Copyright © 2019 贺文杰. All rights reserved.
//

#import "TableViewController.h"
#import "DetailViewController.h"
#import <CoreText/CoreText.h>
#import <CoreGraphics/CoreGraphics.h>
#import "ContentTableViewController.h"

#warning iOS核心动画高级技巧：https://www.bookstack.cn/read/ios_core_animation_advanced_techniques/README.md

@interface TableViewController ()<CALayerDelegate>

@property(nonatomic,strong)NSArray *titleAry;
@property(nonatomic,strong)NSArray *contentAry;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.titleAry = @[@"CALayer", @"CAShapeLayer", @"CATextLayer", @"CATransformLayer", @"CAGradientLayer", @"CAReplicatorLayer", @"CAScrollLayer", @"CATiledLayer", @"CAEmitterLayer", @"CAEAGLLayer", @"AVPlayerLayer", @"动画及优化"];
    
    [self initLayer];
}


- (void)initLayer
{
    CALayer *layer = [[CALayer alloc] init];
    layer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 150);
    layer.backgroundColor = [UIColor cyanColor].CGColor;
    layer.delegate = self;
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 150)];
    //geometryFlipped:它决定了一个图层的坐标是否相对于父图层垂直翻转。设置为YES意味着它的子图层将会被垂直翻转
    headView.layer.geometryFlipped = YES;
    [headView.layer addSublayer:layer];
    self.tableView.tableHeaderView = headView;
    
    [layer display];
}

/**
 当图层的bounds发生改变，或者图层的-setNeedsLayout方法被调用时，这个函数将会被执行.
 重新调整图层的位置及大小
 @param layer 获取对应的layer
 */
- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGRect bounds = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 40, 35, 80, 80);
    //绘制圆形
    CGContextSetFillColorWithColor(ctx, [UIColor yellowColor].CGColor);
    CGContextFillEllipseInRect(ctx, bounds);
    //翻转画布，由于OS中坐标系原点在左下角，iOS在左上角
//    CGContextTranslateCTM(ctx, 0, layer.frame.size.height);
//    CGContextScaleCTM(ctx, 1.0, -1.0);
    CFStringRef text = CFSTR("夕阳下的池塘");
    //0不用限制，maxLength是提示系统有需要多少内部空间需要保留
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    CFAttributedStringReplaceString(attrString, CFRangeMake(0, 0), text);
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(attrString);
    CGSize coreTextSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, 0), nil, CGSizeMake(80, 80), nil);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - coreTextSize.width / 2, 150 / 2 - coreTextSize.height / 2, coreTextSize.width, coreTextSize.height));
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    CTFrameDraw(frame, ctx);
    CFRelease(frame);
    CFRelease(frameSetter);
    CFRelease(attrString);
    CGPathRelease(path);
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [NSString stringWithFormat:@"%@", self.titleAry[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.titleAry.count - 1) {
        ContentTableViewController *contentVC = [[ContentTableViewController alloc] init];
        [self.navigationController pushViewController:contentVC animated:YES];
        return;
    }
    DetailViewController *detailVC = [[DetailViewController alloc] init];
    detailVC.type = self.titleAry[indexPath.row];
    [self.navigationController pushViewController:detailVC animated:YES];
}


@end
