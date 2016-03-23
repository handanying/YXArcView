//
//  ArcView.h
//  arc
//
//  Created by xc on 15/10/24.
//  Copyright © 2015年 xc. All rights reserved.
// 欢迎与我交流 handanying@126.com

#import <UIKit/UIKit.h>

@interface ArcView : UIView

@property(nonatomic, assign) float firstPoint; // 第一个比例
@property(nonatomic, assign) float secondPoint; // 第二个
@property(nonatomic, assign) float thirdPoint; // 第三

@property(nonatomic, copy) NSString *fisrtColor; // 第一个圆弧颜色
@property(nonatomic, copy) NSString *secondColor;
@property(nonatomic, copy) NSString *thirdColor;

@property (nonatomic, copy) NSString *fisrtName;
@property (nonatomic, copy) NSString *secondName;
@property (nonatomic, copy) NSString *thirdName;

@end