//
//  ContentDetailViewController.h
//  CoreAnimationDemo
//
//  Created by 贺文杰 on 2019/9/16.
//  Copyright © 2019 贺文杰. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContentDetailViewController : UIViewController

@property(nonatomic,strong)NSIndexPath *indexPath;
@property(nonatomic,copy)NSString *titleStr;
@property(nonatomic,copy)NSString *subTitleStr;

@end

NS_ASSUME_NONNULL_END
