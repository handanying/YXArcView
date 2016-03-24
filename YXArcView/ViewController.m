//
//  ViewController.m
//  YXArcView
//
//  Created by 王王 on 16/1/13.
//  Copyright © 2016年 王王. All rights reserved.
//

#import "ViewController.h"
#import "ArcView.h"

@interface ViewController ()

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    ArcView *arc=[[ArcView alloc]initWithFrame:CGRectMake(10, 50, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.width - 20)];
    arc.backgroundColor = [UIColor cyanColor];
    arc.firstPoint = 20;
    arc.secondPoint = 30;
    [self.view addSubview:arc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
