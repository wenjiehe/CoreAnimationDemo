//
//  ContentDetailViewController.m
//  CoreAnimationDemo
//
//  Created by 贺文杰 on 2019/9/16.
//  Copyright © 2019 贺文杰. All rights reserved.
//

#import "ContentDetailViewController.h"

@interface ContentDetailViewController ()

@property(nonatomic,copy)NSString *textStr;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ContentDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.textView.editable = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.textView.text = self.textStr;
}

- (void)setIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    self.navigationItem.title = self.titleStr;
    self.navigationItem.prompt = self.subTitleStr;
    if (indexPath.section == 0) { //隐式动画
        [self hideAnimation:indexPath];
    }else if (indexPath.section == 1){ //显示动画
        [self showAnimation:indexPath];
    }else if (indexPath.section == 2){ //图层时间
        [self layerTime:indexPath];
    }else if (indexPath.section == 3){ //缓冲
        [self buffer:indexPath];
    }else if (indexPath.section == 4){ //基于定时器的动画
        [self animationTimer:indexPath];
    }else if (indexPath.section == 5){ //性能调优
        [self performanceOptimize:indexPath];
    }else if (indexPath.section == 6){ //高效绘图
        [self efficientDraw:indexPath];
    }else if (indexPath.section == 7){ //图像IO
        [self imageIO:indexPath];
    }else if (indexPath.section == 8){ //图层性能
        [self layerPerformance:indexPath];
    }
}

#pragma mark ------- 隐式动画 ------------------
- (void)hideAnimation:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) { //事务
        self.textStr = @"\t事务实际上是Core Animation用来包含一系列属性动画集合的机制，任何用指定事务去改变可以做动画的图层属性都不会立刻发生变化，而是当事务一旦提交的时候开始用一个动画过渡到新值。事务是通过CATransaction类来做管理，用+begin和+commit分别来入栈或者出栈，任何可以做动画的图层属性都会被添加到栈顶的事务。\n\tCore Animation在每个run loop周期中自动开始一次新的事务（run loop是iOS负责收集用户输入，处理定时器或者网络事件并且重新绘制屏幕的东西），即使你不显式的用[CATransaction begin]开始一次事务，任何在一次run loop循环中属性的改变都会被集中起来，然后做一次0.25秒的动画。\n\t如果你用过UIView的动画方法做过一些动画效果，那么应该对这个模式不陌生。UIView有两个方法，+beginAnimations:context:和+commitAnimations，和CATransaction的+begin和+commit方法类似。实际上在+beginAnimations:context:和+commitAnimations之间所有视图或者图层属性的改变而做的动画都是由于设置了CATransaction的原因。\n\tCATransaction的+begin和+commit方法在+animateWithDuration:animations:内部自动调用，这样block中所有属性的改变都会被事务所包含。这样也可以避免开发者由于对+begin和+commit匹配的失误造成的风险。";
    }else if (indexPath.row == 1){ //完成块
        self.textStr = @"\t基于UIView的block的动画允许你在动画结束的时候提供一个完成的动作。CATranscation接口提供的+setCompletionBlock:方法也有同样的功能。当你在动画完成后设置view进行旋转，会用默认的事务做变换，这时默认的动画时间就变成了0.25秒";
    }else if (indexPath.row == 2){ //图层行为
        self.textStr = @"\t我们把改变属性时CALayer自动应用的动画称作行为，当CALayer的属性被修改时候，它会调用-actionForKey:方法，传递属性的名称。剩下的操作都在CALayer的头文件中有详细的说明，实质上是如下几步：\n\t\t图层首先检测它是否有委托，并且是否实现CALayerDelegate协议指定的-actionForLayer:forKey方法。如果有，直接调用并返回结果。\n\t\t如果没有委托，或者委托没有实现-actionForLayer:forKey方法，图层接着检查包含属性名称对应行为映射的actions字典。\n\t\t如果actions字典没有包含对应的属性，那么图层接着在它的style字典接着搜索属性名。\n\t\t最后，如果在style里面也找不到对应的行为，那么图层将会直接调用定义了每个属性的标准行为的-defaultActionForKey:方法。\n\t所以一轮完整的搜索结束之后，-actionForKey:要么返回空（这种情况下将不会有动画发生），要么是CAAction协议对应的对象，最后CALayer拿这个结果去对先前和当前的值做动画。于是这就解释了UIKit是如何禁用隐式动画的：每个UIView对它关联的图层都扮演了一个委托，并且提供了-actionForLayer:forKey的实现方法。当不在一个动画块的实现中，UIView对所有图层行为返回nil，但是在动画block范围之内，它就返回了一个非空值。";
    }else if (indexPath.row == 3){ //呈现与模型
        /*
         每个图层属性的显示值都被存储在一个叫做呈现图层的独立图层当中，他可以通过-presentationLayer方法来访问。这个呈现图层实际上是模型图层的复制
         ，但是它的属性值代表了在任何指定时刻当前外观效果。
         呈现图层仅仅当图层首次被提交（就是首次第一次在屏幕上显示）的时候创建，所以在那之前调用-presentationLayer将会返回nil
         */
        CALayer *presenLayer = [self.view.layer presentationLayer]; //获取当前的呈现图层
        CALayer *modLayer = presenLayer.modelLayer; //返回它正在呈现所依赖的CALayer
        self.textStr = @"\t在iOS中，屏幕每秒钟重绘60次。如果动画时长比60分之一秒要长，Core Animation就需要在设置一次新值和新值生效之间，对屏幕上的图层进行重新组织。这意味着CALayer除了“真实”值（就是你设置的值）之外，必须要知道当前显示在屏幕上的属性值的记录。\n\t\t每个图层属性的显示值都被存储在一个叫做呈现图层的独立图层当中，他可以通过-presentationLayer方法来访问。这个呈现图层实际上是模型图层的复制，但是它的属性值代表了在任何指定时刻当前外观效果。换句话说，你可以通过呈现图层的值来获取当前屏幕上真正显示出来的值.\n\t所以使用呈现图层来响应交互，使用presentationLayer图层来判断当前图层位置，并使用-hitTest:来判断是否被点击";
    }
}

#pragma mark ------- 显示动画 --------------------
- (void)showAnimation:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) { //属性动画
        self.textStr = @"\tCAKeyframeAnimation同样是CAPropertyAnimation的一个子类，它依然作用于单一的一个属性，但是和CABasicAnimation不一样的是，它不限制于设置一个起始和结束的值，而是可以根据一连串随意的值来做动画。\n\t关键帧起源于传动动画，意思是指主导的动画在显著改变发生时重绘当前帧（也就是关键帧），每帧之间剩下的绘制（可以通过关键帧推算出）将由熟练的艺术家来完成。CAKeyframeAnimation也是同样的道理：你提供了显著的帧，然后Core Animation在每帧之间进行插入。";
    }else if (indexPath.row == 1){ //动画组
        self.textStr = @"\tCABasicAnimation和CAKeyframeAnimation仅仅作用于单独的属性，而CAAnimationGroup可以把这些动画组合在一起。CAAnimationGroup是另一个继承于CAAnimation的子类，它添加了一个animations数组的属性，用来组合别的动画。";
    }else if (indexPath.row == 2){ //过渡
        /*
         CATransition的type类型
         kCATransitionFade 默认过渡类型
         kCATransitionMoveIn
         kCATransitionPush
         kCATransitionReveal
         */
        self.textStr = @"\tCATransition并不作用于指定的图层属性，这就是说你可以在即使不能准确得知改变了什么的情况下对图层做动画，例如，在不知道UITableView哪一行被添加或者删除的情况下，直接就可以平滑地刷新它，或者在不知道UIViewController内部的视图层级的情况下对两个不同的实例做过渡动画";
    }else if (indexPath.row == 3){ //在动画过程中取消动画
        self.textStr = @"\t一般说来，动画在结束之后被自动移除，除非设置removedOnCompletion为NO，如果你设置动画在结束之后不被自动移除，那么当它不需要的时候你要手动移除它；否则它会一直存在于内存中，直到图层被销毁。\n\t-animationDidStop:finished:方法中的flag参数表明了动画是自然结束还是被打断，我们可以在控制台打印出来。如果你用停止按钮来终止动画，它会打印NO，如果允许它完成，它会打印YES。";
    }
}

#pragma mark -------- 图层时间 --------------------
- (void)layerTime:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) { //CAMediaTiming协议
        self.textStr = @"\tCAMediaTiming协议定义了在一段动画内用来控制逝去时间的属性的集合，CALayer和CAAnimation都实现了这个协议，所以时间可以被任意基于一个图层或者一段动画的类控制。";
        CABasicAnimation *animation = [CABasicAnimation animation];
        animation.beginTime = 3.f; //指定了动画开始之前的的延迟时间
        animation.speed = 2.f; //是一个时间的倍数，默认1.0，减少它会减慢图层/动画的时间，增加它会加快速度。如果2.0的速度，那么对于一个duration为1的动画，实际上在0.5秒的时候就已经完成了。
        animation.timeOffset = 0.5; //timeOffset只是让动画快进到某一点，例如，对于一个持续1秒的动画来说，设置timeOffset为0.5意味着动画将从一半的地方开始。
        /*
         kCAFillModeForwards
         kCAFillModeBackwards
         kCAFillModeBoth
         kCAFillModeRemoved  默认，当动画不再播放的时候就显示图层模型指定的值剩下的三种类型向前，
         向后或者即向前又向后去填充动画状态，使得动画在开始前或者结束后仍然保持开始和结束那一刻的值
         */
    }else if (indexPath.row == 1){ //层级关系时间
        self.textStr = @"\tCoreAnimation有一个全局时间的概念，也就是所谓的马赫时间（“马赫”实际上是iOS和MacOS系统内核的命名）。马赫时间在设备上所有进程都是全局的—但是在不同设备上并不是全局的\n\t\tCFTimeInterval time = CACurrentMediaTime();\n\t这个函数返回的值其实无关紧要（它返回了设备自从上次启动后的秒数，并不是你所关心的），它真实的作用在于对动画的时间测量提供了一个相对值。注意当设备休眠的时候马赫时间会暂停，也就是所有的CAAnimations（基于马赫时间）同样也会暂停。\n\t每个CALayer和CAAnimation实例都有自己本地时间的概念，是根据父图层/动画层级关系中的beginTime，timeOffset和speed属性计算。方法转换:\n\t- (CFTimeInterval)convertTime:(CFTimeInterval)t fromLayer:(CALayer *)l;\n\t- (CFTimeInterval)convertTime:(CFTimeInterval)t toLayer:(CALayer *)l;\n\t如果把图层的speed设置成0，它会暂停任何添加到图层上的动画。类似的，设置speed大于1.0将会快进，设置成一个负值将会倒回动画。";
    }else if (indexPath.row == 2){ //手动动画
        self.textStr = @"\ttimeOffset一个很有用的功能在于你可以它可以让你手动控制动画进程，通过设置speed为0，可以禁用动画的自动播放，然后来使用timeOffset来来回显示动画序列。这可以使得运用手势来手动控制动画变得很简单。";
    }
}

#pragma mark --------- 缓冲 --------------------
- (void)buffer:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) { //动画速度
        /*
         kCAMediaTimingFunctionLinear选项创建了一个线性的计时函数，同样也是CAAnimation的timingFunction属性为空时候的默认函数。
         kCAMediaTimingFunctionEaseIn常量创建了一个慢慢加速然后突然停止的方法。
         kCAMediaTimingFunctionEaseOut则恰恰相反，它以一个全速开始，然后慢慢减速停止。
         kCAMediaTimingFunctionEaseInEaseOut创建了一个慢慢加速然后再慢慢减速的过程。当使用UIView的动画方法时，他的确是默认的，但当创建CAAnimation的时候，就需要手动设置它了
         */
    }else if (indexPath.row == 1){ //自定义缓冲函数
        self.textStr = @"自定义缓冲函数是指根据设置动画的曲线(使用贝塞尔曲线或者帧动画)";
    }
}

#pragma mark ---------- 基于定时器的动画 ----------------
- (void)animationTimer:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) { //定时帧
        self.textStr = @"\tiOS上的每个线程都管理了一个NSRunloop，字面上看就是通过一个循环来完成一些任务列表。\n\t\t处理触摸事件\n\t\t发送和接受网络数据包\n\t\t执行使用gcd的代码\n\t\t处理计时器行为\n\t\t屏幕重绘\n\t当你设置一个NSTimer，他会被插入到当前任务列表中，然后直到指定时间过去之后才会被执行。但是何时启动定时器并没有一个时间上限，而且它只会在列表中上一个任务完成之后开始执行。这通常会导致有几毫秒的延迟，但是如果上一个任务过了很久才完成就会导致延迟很长一段时间。\n\t我们可以用CADisplayLink让更新频率严格控制在每次屏幕刷新之后。\n\t基于真实帧的持续时间而不是假设的更新频率来做动画。\n\t调整动画计时器的run loop模式，这样就不会被别的事件干扰。\n\t每个添加到run loop的任务都有一个指定了优先级的模式，为了保证用户界面保持平滑，iOS会提供和用户界面相关任务的优先级，而且当UI很活跃的时候的确会暂停一些别的任务。一个典型的例子就是当是用UIScrollview滑动的时候，重绘滚动视图的内容会比别的任务优先级更高，所以标准的NSTimer和网络请求就不会启动，一些常见的run loop模式如下：\n\tNSDefaultRunLoopMode - 标准优先级\n\tNSRunLoopCommonModes - 高优先级\n\tUITrackingRunLoopMode - 用于UIScrollView和别的控件的动画";
    }else if (indexPath.row == 1){ //物理模拟
        self.textStr = @"纯C的物理引擎:https://github.com/slembcke/Chipmunk2D";
    }
}

#pragma mark ----------- 性能调优 --------------
- (void)performanceOptimize:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) { //CPU VS GPU
        self.textStr = @"关于绘图和动画有两种处理的方式：CPU（中央处理器）和GPU（图形处理器）。";
    }else if (indexPath.row == 1){ //测量，而不是猜测
        self.textStr = @"\t性能测试一定要用发布配置，而不是调试模式。因为当用发布环境打包的时候，编译器会引入一系列提高性能的优化，例如去掉调试符号或者移除并重新组织代码。你也可以自己做到这些，例如在发布环境禁用NSLog语句。你只关心发布性能，那才是你需要测试的点。";
    }else if (indexPath.row == 2){ //instruments
    }
}

#pragma mark ----------- 高效绘图 --------------
- (void)efficientDraw:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) { //软件绘图
        self.textStr = @"\t一旦你实现了CALayerDelegate协议中的-drawLayer:inContext:方法或者UIView中的-drawRect:方法（其实就是前者的包装方法），图层就创建了一个绘制上下文，这个上下文需要的大小的内存可从这个算式得出：图层宽*图层高*4字节，宽高的单位均为像素。对于一个在Retina iPad上的全屏图层来说，这个内存量就是 2048*1526*4字节，相当于12MB内存，图层每次重绘的时候都需要重新抹掉内存然后重新分配。\n\t提高绘制性能的秘诀就在于尽量避免去绘制。";
    }else if (indexPath.row == 1){ //矢量图形
    }else if (indexPath.row == 2){ //脏矩形
    }else if (indexPath.row == 3){ //异步绘制
    }
}

#pragma mark ----------- 图像IO ---------------
- (void)imageIO:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) { //加载和潜伏
        
    }else if (indexPath.row == 1){ //缓存
    }else if (indexPath.row == 2){ //文件格式
    }
}

#pragma mark ----------- 图层性能 ------------------
- (void)layerPerformance:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) { //隐式绘制
        
    }else if (indexPath.row == 1){ //离屏渲染
    }else if (indexPath.row == 2){ //混合和过渡绘制
        self.textStr = @"\tGPU每一帧可以绘制的像素有一个最大限制（就是所谓的fill rate），这个情况下可以轻易地绘制整个屏幕的所有像素。但是如果由于重叠图层的关系需要不停地重绘同一区域的话，掉帧就可能发生了。\n\tGPU会放弃绘制那些完全被其他图层遮挡的像素，但是要计算出一个图层是否被遮挡也是相当复杂并且会消耗处理器资源。同样，合并不同图层的透明重叠像素（即混合）消耗的资源也是相当客观的。所以为了加速处理进程，不到必须时刻不要使用透明图层。任何情况下，你应该这样做：\n\t\t给视图的backgroundColor属性设置一个固定的，不透明的颜色\n\t\t设置opaque属性为YES\n\t样做减少了混合行为（因为编译器知道在图层之后的东西都不会对最终的像素颜色产生影响）并且计算得到了加速，避免了过度绘制行为因为Core Animation可以舍弃所有被完全遮盖住的图层，而不用每个像素都去计算一遍。\n\t如果用到了图像，尽量避免透明除非非常必要。如果图像要显示在一个固定的背景颜色或是固定的背景图之前，你没必要相对前景移动，你只需要预填充背景图片就可以避免运行时混色了。";
    }else if (indexPath.row == 3){ //减少图层数量
    }
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
