//
//  DetailViewController.m
//  CoreAnimationDemo
//
//  Created by 贺文杰 on 2019/9/5.
//  Copyright © 2019 贺文杰. All rights reserved.
//

#import "DetailViewController.h"
#import "HWJScrollView.h"
#import <QuartzCore/QuartzCore.h>
#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>
#import <OpenGLES/OpenGLESAvailability.h>

/**<屏幕宽度*/
#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
/**<屏幕高度*/
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
#define iPhoneX_Series (fabs(SCREEN_HEIGHT) == 812 || fabs(SCREEN_HEIGHT) == 896)
/**<适配顶部高度*/
#define SafeAreaTopHeight (iPhoneX_Series ? 88.0 : 64.0)

@interface DetailViewController ()

@property(nonatomic)dispatch_source_t timer;

@property (nonatomic, strong) EAGLContext *glContext;
@property (nonatomic, strong) CAEAGLLayer *glLayer;
@property (nonatomic, assign) GLuint framebuffer;
@property (nonatomic, assign) GLuint colorRenderbuffer;
@property (nonatomic, assign) GLint framebufferWidth;
@property (nonatomic, assign) GLint framebufferHeight;
@property (nonatomic, strong) GLKBaseEffect *effect;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)dealloc
{
    [self tearDownBuffers];
    [EAGLContext setCurrentContext:nil];
}

- (void)setType:(NSString *)type
{
    _type = type;
    if ([type isEqualToString:@"CALayer"]) {
        [self initLayer];
    }else if ([type isEqualToString:@"CAShapeLayer"]){
        [self initCAShapeLayer];
    }else if ([type isEqualToString:@"CATextLayer"]){
        [self initCATextLayer];
    }else if ([type isEqualToString:@"CATransformLayer"]){
        [self initCATransformLayer];
    }else if ([type isEqualToString:@"CAGradientLayer"]){
        [self initCAGradientLayer];
    }else if ([type isEqualToString:@"CAReplicatorLayer"]){
        [self initCAReplicatorLayer];
    }else if ([type isEqualToString:@"CAScrollLayer"]){
        [self initCAScrollLayer];
    }else if ([type isEqualToString:@"CATiledLayer"]){
        [self initCATiledLayer];
    }else if ([type isEqualToString:@"CAEmitterLayer"]){
        [self initCAEmitterLayer];
    }else if ([type isEqualToString:@"CAEAGLLayer"]){
        [self initCAEAGLLayer];
    }else if ([type isEqualToString:@"AVPlayerLayer"]){
        [self initAVPlayerLayer];
    }
}

/**
 使用CALayer的代理方法，改变layer内部的绘制内容
 当视图在屏幕上出现的时候，-drawRect:方法就会被自动调用。
 当使用了display,就会把重绘的决定权转交给开发者
 
 UIView有frame,bounds和center
 CALayer有frame,bounds和position,position和center都代表同样的值
 frame代表了图层的外部坐标，bounds是内部坐标({0,0}通常是图层的左上角),center和position都代表了相对于父图层anchorPoint所在的位置
 视图中没有anchorPoint这一说，图层中可以移动anchorPoint(锚点),但是position却不会发生相应的变化
 当操纵视图的frame,实际上是在改变位于视图下方CALayer的frame,不能够独立于图层之外改变视图的frame
 */
- (void)initLayer
{
    CALayer *layer = [[CALayer alloc] init];
    layer.frame = CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, 150);
    layer.backgroundColor = [UIColor cyanColor].CGColor;
    [self.view.layer addSublayer:layer];

    //zPosition:可以让这个图层前置,但不能改变事件传递的顺序(谨慎使用)
    //    layer.zPosition = 1.0;
    
    //设置圆角(前置条件是layer的宽高必须一致)
    //    layer.cornerRadius = layer.frame.size.height / 2;
    
    //超出部分进行裁剪
    //    layer.masksToBounds = YES;
    
    //图层边框(沿着图层的bounds绘制,而不是图层的内容)
    //    layer.borderWidth = 2;
    
    //图层线颜色
    //    layer.borderColor = [UIColor redColor].CGColor;
    
    //图层蒙版,蒙版可以通过代码甚至是动画实时生成
    //    UIImage *img = [UIImage imageNamed:@""];
    //    CALayer *maskLayer = [CALayer layer];
    //    maskLayer.contents = (__bridge id)img.CGImage;
    //    maskLayer.frame = layer.bounds;
    //    layer.mask = maskLayer;
    
    //由于CALayer不能直接处理触摸事件或手势,根据点是否在图层范围内，来判断是否点击了相应的图层
    //containsPoint:如果这个点在图层frame范围内就返回YES
    //    BOOL isPoint = [layer containsPoint:CGPointMake(40, 40)];
    
    //hitTest:它返回图层本身,如果这个点在最外面图层的范围之外，则返回nil
    //    CALayer *csLayer = [layer hitTest:CGPointMake(40, 40)];
    
    //geometryFlipped:它决定了一个图层的坐标是否相对于父图层垂直翻转。设置为YES意味着它的子图层将会被垂直翻转
//    self.view.layer.geometryFlipped = YES;
    
    /*
        拉伸过滤算法
        kCAFilterLinear 双线性滤波算法,不适用于放大倍数比较大的图片,会模糊不清
        kCAFilterNearest 最近滤波算法,适用于没有斜线的小图
        kCAFilterTrilinear 三线性滤波算法,和kCAFilterLinear相似，但会结合大图,提高性能
     */
    //缩小图片
//    layer.minificationFilter = kCAFilterLinear;
    //放大图片
//    layer.magnificationFilter = kCAFilterTrilinear;
    
    //设置透明度，会影响子图层，alpha也是如此
//    layer.opacity = 0.5;
    
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(100, 250, 150, 60);
//    [btn setTitle:@"Hello World!" forState:UIControlStateNormal];
//    [self.view addSubview:btn];
//    btn.backgroundColor = [UIColor redColor];
//    btn.alpha = 0.3;
    
    //设置视图的组透明,避免Retina屏幕像素化
//    btn.layer.shouldRasterize = YES;
//    btn.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    /*
      affineTransform是一个CGAffineTrasform类型,用于在二维空间做旋转、缩放和平移。
      2 * 3的矩阵
      CGAffineTransform类型属于Core Graphics框架，实际是2D绘图API
     */
//    layer.affineTransform = CGAffineTransformMakeRotation(M_PI_4); //旋转45度
    
    /*
        transform是一个CATransform3D类型,让图层在3D空间内移动或者旋转
        4 * 4的矩阵
     */
//    CATransform3D trans = CATransform3DIdentity;
//    trans.m34 = -1.0 / 500.f; //设置矩阵的透视效果
//    layer.transform = CATransform3DRotate(trans, M_PI_4, 0, 1, 0);
    
    /*
      doubleSided是控制图层的背面是否要被绘制，默认为YES,如果设置为NO,那么当图层正面从相机视角消失的时候，它将不会被绘制
     */
//    layer.doubleSided = YES;
}


/**
 CAShapeLayer是一个通过矢量图形而不是bitmap来绘制的图层子类
 优点:
 渲染快速，使用了硬件加速，绘制同一图形会比用Core Graphics快很多
 高效使用内存
 不会被图层边界剪裁掉。可以在边界之外绘制。不会像CALayer一样被剪裁掉
 不会出现像素化,给CAShapeLayer做3D变换时，它不像一个有寄宿图的普通图层一样变得像素化
 */
- (void)initCAShapeLayer
{
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(175, 100)];
    [path addArcWithCenter:CGPointMake(150, 100) radius:25 startAngle:0 endAngle:2*M_PI clockwise:YES];
    [path moveToPoint:CGPointMake(150, 125)];
    [path addLineToPoint:CGPointMake(150, 175)];
    [path addLineToPoint:CGPointMake(125, 225)];
    [path moveToPoint:CGPointMake(150, 175)];
    [path addLineToPoint:CGPointMake(175, 225)];
    [path moveToPoint:CGPointMake(100, 150)];
    [path addLineToPoint:CGPointMake(200, 150)];
    //create shape layer
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = [UIColor redColor].CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = 5;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.path = path.CGPath;
    //add it to our view
    [self.view.layer addSublayer:shapeLayer];
}


/**
 CATextLayer比UILabel渲染快的多，CATextLayer使用了Core text
 */
- (void)initCATextLayer
{
    //create a text layer
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.frame = CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT - SafeAreaTopHeight);
    [self.view.layer addSublayer:textLayer];
    //set text attributes
    textLayer.foregroundColor = [UIColor blackColor].CGColor;
    textLayer.alignmentMode = kCAAlignmentJustified;
    textLayer.wrapped = YES;
    //choose a font
    UIFont *font = [UIFont systemFontOfSize:15];
    //set layer font
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    textLayer.font = fontRef;
    textLayer.fontSize = font.pointSize;
    CGFontRelease(fontRef);
    //choose some text
    NSString *text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque massa arcu, eleifend vel varius in, facilisis pulvinar leo. Nunc quis nunc at mauris pharetra condimentum ut ac neque. Nunc elementum, libero ut porttitor dictum, diam odio congue lacus, vel fringilla sapien diam at purus. Etiam suscipit pretium nunc sit amet lobortis";
    //set layer text
    textLayer.string = text;
    //解决像素化问题
    textLayer.contentsScale = [UIScreen mainScreen].scale;
}

- (void)initCATransformLayer
{
    CATransform3D c2t = CATransform3DIdentity;
    c2t = CATransform3DTranslate(c2t, 100, 0, 0);
    c2t = CATransform3DRotate(c2t, -M_PI_4, 1, 0, 0);
    c2t = CATransform3DRotate(c2t, -M_PI_4, 0, 1, 0);
    CALayer *cube2 = [self cubeWithTransform:c2t];
    [self.view.layer addSublayer:cube2];
}


/**
 CAGradientLayer是用来生成两种或更多颜色平滑渐变的。
 绘制使用了硬件加速
 */
- (void)initCAGradientLayer
{
    //create gradient layer and add it to our container view
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(100, 100, 150, 150);
    [self.view.layer addSublayer:gradientLayer];
    //set gradient colors
    gradientLayer.colors = @[(__bridge id)[UIColor redColor].CGColor, (__bridge id) [UIColor yellowColor].CGColor, (__bridge id)[UIColor greenColor].CGColor];
    //locations和colors数组大小必须对应
    gradientLayer.locations = @[@0.0, @0.25, @0.5];
    //set gradient start and end points
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
}

/**
 CAReplicatorLayer的目的是为了高效生成许多相似的图层
 */
- (void)initCAReplicatorLayer
{
    //create a replicator layer and add it to our view
    CAReplicatorLayer *replicator = [CAReplicatorLayer layer];
    replicator.frame = CGRectMake(100, 100, 150, 150);
    [self.view.layer addSublayer:replicator];
    //指定图层需要重复多少次
    replicator.instanceCount = 10;
    //apply a transform for each instance
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DTranslate(transform, 0, 200, 0);
    transform = CATransform3DRotate(transform, M_PI / 5.0, 0, 0, 1);
    transform = CATransform3DTranslate(transform, 0, -200, 0);
    //指定一个CATransform3D变换
    replicator.instanceTransform = transform;
    //逐步减少蓝色和绿色通道,变成红色
    replicator.instanceBlueOffset = -0.1;
    replicator.instanceGreenOffset = -0.1;
    //用于反射
    //    replicator.instanceAlphaOffset = -0.6;
    //create a sublayer and place it inside the replicator
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(100.0f, 100.0f, 100.0f, 100.0f);
    layer.backgroundColor = [UIColor whiteColor].CGColor;
    [replicator addSublayer:layer];
}

/**
 实现图层滑动
 */
- (void)initCAScrollLayer
{
    self.view.backgroundColor = [UIColor blueColor];
    
    HWJScrollView *sv = [[HWJScrollView alloc] init];
    sv.frame = CGRectMake(40, 100, 150, 150);
    
    UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ziran.png"]];
    imgV.frame = CGRectMake(20, 80, 600, 500);
    [sv addSubview:imgV];
    
    [self.view addSubview:sv];
}

- (void)initCATiledLayer
{
    
}

/**
 CAEmitterLayer是一个高性能的粒子引擎，被用来创建实时例子动画，如:烟雾、火、雨等效果
 CAEmitterCell是粒子单元
 
 emitterShape 设置发射的形状
 kCAEmitterLayerPoint 点
 kCAEmitterLayerLine 线
 kCAEmitterLayerRectangle 矩形
 kCAEmitterLayerCuboid 立方体
 kCAEmitterLayerCircle 圆形
 kCAEmitterLayerSphere 球形
 
 emitterMode 设置发射的模式
 kCAEmitterLayerPoints 从发射器中
 kCAEmitterLayerOutline 边缘
 kCAEmitterLayerSurface 表面
 kCAEmitterLayerVolume 中心
 
 renderMode 设置渲染的模式
 kCAEmitterLayerUnordered 粒子是无序出现的，多个发射源将混合
 kCAEmitterLayerOldestFirst 粒子已先进后出渲染在最上层
 kCAEmitterLayerOldestLast 粒子已先进先出渲染在最上层
 kCAEmitterLayerBackToFront 粒子的渲染按照Z轴的前后顺序进行
 kCAEmitterLayerAdditive 进行粒子混合

 */
- (void)initCAEmitterLayer
{
    UIView *layerView = [[UIView alloc] init];
    layerView.frame = CGRectMake(0, 100, SCREEN_WIDTH, SCREEN_HEIGHT - 110);
    layerView.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:layerView];
    
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    emitter.frame = layerView.bounds;
    emitter.emitterPosition = CGPointMake(SCREEN_WIDTH / 2, 0); //发射位置
    emitter.emitterSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - 110); //发射器的尺寸
    emitter.emitterShape = kCAEmitterLayerCuboid; //发射的形状
    emitter.renderMode = kCAEmitterLayerOldestFirst; //渲染的模式
    emitter.emitterMode = kCAEmitterLayerSurface; //发射的模式
    emitter.birthRate = 1; //粒子产生系数，默认为1,关闭粒子效果即设置为0
    emitter.masksToBounds = NO;
    
    CAEmitterCell *cell = [[CAEmitterCell alloc] init];
    cell.contents = (__bridge id)[UIImage imageNamed:@"love.png"].CGImage; //粒子展示的内容
    cell.birthRate = 500; //每秒粒子产生个数的乘数因子，会和emitter的birthRate相乘，然后确定每秒产生的粒子个数
    cell.lifetime = 5.f; //每个粒子存活时长
//    cell.color = [UIColor greenColor].CGColor; //指定颜色和图片内容颜色混合
    cell.lifetimeRange = 0.3; //粒子生命周期范围
    cell.alphaSpeed = -0.2f; //每过一秒减少0.2的透明度
    cell.velocity = 40; //粒子速度
    cell.velocityRange = 20; //粒子的速度范围
//    cell.emissionRange = M_PI * 2.f; //位置反射 M_PI * 2.0代表360度任意位置反射
    //随机粒子颜色
    cell.redRange = 0.3;
    cell.blueRange = 0.5;
    cell.greenRange = 0.9;
    cell.alphaRange = 0.5;
    cell.scale = 0.5; //缩放比例
    cell.scaleRange = 0.02; //缩放比例范围
    cell.scaleSpeed = -0.15; //每秒缩小原始尺寸的15%
    cell.emissionLatitude = M_PI; //粒子的初始发射方向
    cell.yAcceleration = 70; //Y方向的加速度
//    cell.xAcceleration = 20; //X方向的加速度
    
    emitter.emitterCells = @[cell];
    [layerView.layer addSublayer:emitter];
}

/**
 CAEAGLLayer是CALayer的一个子类，用来显示任意的OpenGL图形
 GLKit是用来替换OpenGL的一些复杂性，提供了一个叫做CLKView的UIView的子类，帮你处理大部分的设置和绘制工作
 适用范围是iOS 3.0~12.0
 */
- (void)initCAEAGLLayer
{
    //set up context
    self.glContext = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.glContext];
    //set up layer
    self.glLayer = [CAEAGLLayer layer];
    self.glLayer.frame = CGRectMake(100, 100, 150, 200);
    [self.view.layer addSublayer:self.glLayer];
    self.glLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking:@NO, kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
    //set up base effect
    self.effect = [[GLKBaseEffect alloc] init];
    //set up buffers
    [self setUpBuffers];
    //draw frame
    [self drawFrame];
}

/**
 AVPlayerLayer是用来在iOS上播放视频的,属于AVFoundation
 AVPlayerLayer是CALayer的子类，继承了父类的所有特性
 
 拉伸模式
 AVLayerVideoGravityResizeAspect 按原视频比例显示
 AVLayerVideoGravityResizeAspectFill 以原比例拉伸至两边屏幕占满
 AVLayerVideoGravityResize 拉伸视频内容达到边框占满，不按原比例拉伸

 */
- (void)initAVPlayerLayer
{
    //get video URL
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"ceshi_video" withExtension:@"mp4"];
    //create player and player layer
    AVPlayer *player = [AVPlayer playerWithURL:URL];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    //set player layer frame and attach it to our view
    playerLayer.frame = CGRectMake(30, 120, SCREEN_WIDTH - 60, 200);
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:playerLayer];
    //play the video
    [player play];
}

#pragma mark --------- private method ------------------
- (CALayer *)faceWithTransform:(CATransform3D)transform
{
    //create cube face layer
    CALayer *face = [CALayer layer];
    face.frame = CGRectMake(-50, -50, 100, 100);
    //apply a random color
    CGFloat red = (arc4random() / (double)INT_MAX);
    CGFloat green = (arc4random() / (double)INT_MAX);
    CGFloat blue = (arc4random() / (double)INT_MAX);
    face.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0].CGColor;
    face.transform = transform;
    return face;
}

- (CALayer *)cubeWithTransform:(CATransform3D)transform
{
    //create cube layer
    CATransformLayer *cube = [CATransformLayer layer];
    //add cube face 1
    CATransform3D ct = CATransform3DMakeTranslation(0, 0, 50);
    [cube addSublayer:[self faceWithTransform:ct]];
    //add cube face 2
    ct = CATransform3DMakeTranslation(50, 0, 0);
    ct = CATransform3DRotate(ct, M_PI_2, 0, 1, 0);
    [cube addSublayer:[self faceWithTransform:ct]];
    //add cube face 3
    ct = CATransform3DMakeTranslation(0, -50, 0);
    ct = CATransform3DRotate(ct, M_PI_2, 1, 0, 0);
    [cube addSublayer:[self faceWithTransform:ct]];
    //add cube face 4
    ct = CATransform3DMakeTranslation(0, 50, 0);
    ct = CATransform3DRotate(ct, -M_PI_2, 1, 0, 0);
    [cube addSublayer:[self faceWithTransform:ct]];
    //add cube face 5
    ct = CATransform3DMakeTranslation(-50, 0, 0);
    ct = CATransform3DRotate(ct, -M_PI_2, 0, 1, 0);
    [cube addSublayer:[self faceWithTransform:ct]];
    //add cube face 6
    ct = CATransform3DMakeTranslation(0, 0, -50);
    ct = CATransform3DRotate(ct, M_PI, 0, 1, 0);
    [cube addSublayer:[self faceWithTransform:ct]];
    //center the cube layer within the container
    CGSize containerSize = CGSizeMake(150, SCREEN_HEIGHT);
    cube.position = CGPointMake(containerSize.width / 2.0, containerSize.height / 2.0);
    //apply the transform and return
    cube.transform = transform;
    return cube;
}

- (void)tailorImage
{
    UIImage *image = [UIImage imageNamed:@"ziran.png"];
//    CGFloat smallW = image.size.width /
//    NSString *path = [NSString stringWithFormat:@""];
//    //input file
//    NSString *inputFile = [NSString stringWithCString:path encoding:NSUTF8StringEncoding];
//    //tile size
//    CGFloat tileSize = 256; //output path
//    NSString *outputPath = [inputFile stringByDeletingPathExtension];
//    //load image
//    UIImage *image = [[UIImage alloc] initWithContentsOfFile:inputFile];
//    CGSize size = [image size];
//    NSArray *representations = [image representations];
//    if ([representations count]){
//        NSBitmapImageRep *representation = representations[0];
//        size.width = [representation pixelsWide];
//        size.height = [representation pixelsHigh];
//    }
//    NSRect rect = NSMakeRect(0.0, 0.0, size.width, size.height);
//    CGImageRef imageRef = [image CGImageForProposedRect:&rect context:NULL hints:nil];
//    //calculate rows and columns
//    NSInteger rows = ceil(size.height / tileSize);
//    NSInteger cols = ceil(size.width / tileSize);
//    //generate tiles
//    for (int y = 0; y < rows; ++y) {
//        for (int x = 0; x < cols; ++x) {
//            //extract tile image
//            CGRect tileRect = CGRectMake(x*tileSize, y*tileSize, tileSize, tileSize);
//            CGImageRef tileImage = CGImageCreateWithImageInRect(imageRef, tileRect);
//            //convert to jpeg data
//            NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithCGImage:tileImage];
//            NSData *data = [imageRep representationUsingType: NSJPEGFileType properties:nil];
//            CGImageRelease(tileImage);
//            //save file
//            NSString *path = [outputPath stringByAppendingFormat: @"_%02i_%02i.jpg", x, y];
//            [data writeToFile:path atomically:NO];
//        }
//    }
}

#pragma mark ---------------- CAEAGLLayer -------------------------
- (void)setUpBuffers
{
    //set up frame buffer
    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    //set up color render buffer
    glGenRenderbuffers(1, &_colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderbuffer);
    [self.glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.glLayer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_framebufferWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_framebufferHeight);
    //check success
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to make complete framebuffer object: %i", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
}

- (void)tearDownBuffers
{
    if (_framebuffer) {
        //delete framebuffer
        glDeleteFramebuffers(1, &_framebuffer);
        _framebuffer = 0;
    }
    if (_colorRenderbuffer) {
        //delete color render buffer
        glDeleteRenderbuffers(1, &_colorRenderbuffer);
        _colorRenderbuffer = 0;
    }
}
- (void)drawFrame {
    //bind framebuffer & set viewport
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glViewport(0, 0, _framebufferWidth, _framebufferHeight);
    //bind shader program
    [self.effect prepareToDraw];
    //clear the screen
    glClear(GL_COLOR_BUFFER_BIT); glClearColor(0.0, 0.0, 0.0, 1.0);
    //set up vertices
    GLfloat vertices[] = {
        -0.5f, -0.5f, -1.0f, 0.0f, 0.5f, -1.0f, 0.5f, -0.5f, -1.0f,
    };
    //set up colors
    GLfloat colors[] = {
        0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f,
    };
    //draw triangle
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glVertexAttribPointer(GLKVertexAttribColor,4, GL_FLOAT, GL_FALSE, 0, colors);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    //present render buffer
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    [self.glContext presentRenderbuffer:GL_RENDERBUFFER];
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
