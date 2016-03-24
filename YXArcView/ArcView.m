//
//  ArcView.m
//  arc
//
//  Created by xc on 15/10/24.
//  Copyright © 2015年 xc. All rights reserved.
#define kradius ([UIScreen mainScreen].bounds.size.width - 20) * 7/30
#define klineWidth 50
#define  kdistance  80 // 等边三角形到圆的距离
#define    kside  8  // 等边三角形边长的一半
#define kWidth [UIScreen mainScreen].bounds.size.width

#import "ArcView.h"

@interface ArcView ()

@property (nonatomic, assign) CGFloat startPoint; // 第一个圆的起始点弧度，默认为- M_Pi_2
@property (nonatomic, assign) CGFloat endPoint0; //  第一个圆弧的终点弧度，也是第二个圆弧的起点
@property (nonatomic, assign) CGFloat endPoint1; // 第二个圆弧的终点弧度

@property (nonatomic, assign) CGPoint arcCenter; // 圆心

@property (nonatomic, strong) UIBezierPath *touch0; // 第一个三角的可触位置
@property (nonatomic, strong) UIBezierPath *touch1;
@property (nonatomic, strong) UIBezierPath *touch2;

@property (nonatomic, assign) CGPoint firstTouch; // 第一次触摸点
@property (nonatomic, assign) CGPoint currentPoint; // 手指触摸的点

@property (nonatomic, assign) NSInteger tagLeft; // 手指离开的标记

@property (nonatomic, assign) float changFloat;

@property (nonatomic, copy) NSString *hbNum; // 以下分别对应三个百分比
@property (nonatomic, copy) NSString *zqNum;
@property (nonatomic, copy) NSString *gpNum;


@end

@implementation ArcView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    // 此处有潜在的内存泄露
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.startPoint = - M_PI/2; // 起始弧度
        [self setNeedsDisplay];
        
    }
    return self;
}

- (void)setFirstPoint:(float)firstPoint{
    
    _firstPoint = firstPoint;
    self.endPoint0 = self.startPoint + M_PI*2 * self.firstPoint / 100;
    
}

- (void)setSecondPoint:(float)secondPoint{
    _secondPoint = secondPoint;
    self.endPoint1 = self.endPoint0 + M_PI*2 * self.secondPoint / 100;
}

- (void)drawRect:(CGRect)rect {
    
    // 圆心
    self.arcCenter = CGPointMake(rect.size.width/2, rect.size.height/2);
    
    // 第一个圆弧
    [[UIColor redColor] set];
    CGFloat endAngle0;
    if (self.secondPoint == 0 && self.thirdPoint == 0) {
        endAngle0 = self.startPoint + M_PI*2;
    }else{
        endAngle0 = self.endPoint0;
    }
    UIBezierPath *arcBezier0 = [UIBezierPath bezierPathWithArcCenter:self.arcCenter radius:kradius startAngle:self.startPoint endAngle:endAngle0 clockwise:YES];
    arcBezier0.lineWidth = klineWidth;
    [arcBezier0 stroke];
    self.firstPoint = fabs(100*(self.endPoint0 - self.startPoint)/(M_PI*2));
    if (self.firstPoint <= 0) {
        self.firstPoint = 0;
    }
    NSInteger tag0 = 0;
    [self drawTriangleWithRadian:self.startPoint andTag:tag0];
    // 第二个圆弧
    
    [[UIColor yellowColor] set];
    CGFloat endAngle1;
    if (self.firstPoint == 0 && self.thirdPoint == 0) { // 当第一个和第三个弧为0时
        endAngle1 = self.endPoint0 + M_PI*2;
    }else{
        endAngle1 = self.endPoint1;
    }
    UIBezierPath *arcBezier1 = [UIBezierPath bezierPathWithArcCenter:self.arcCenter radius:kradius startAngle:self.endPoint0 endAngle:endAngle1 clockwise:YES];
    arcBezier1.lineWidth = klineWidth;
    [arcBezier1 stroke];
    self.secondPoint = fabs(100*(self.endPoint1 - self.endPoint0)/(M_PI*2));
    NSInteger tag1 = 1;
    [self drawTriangleWithRadian:self.endPoint0 andTag:tag1];
    
    // 第三个圆弧
    
    [[UIColor blueColor] set];
    CGFloat endAngle2;
    if (self.firstPoint == 0 && self.secondPoint == 0) {// 当第一个和第二个弧为0时
        endAngle2 = self.endPoint1 + M_PI*2;
    }else{
        if (self.firstPoint == 100 || self.secondPoint == 100) {
            endAngle2 = self.endPoint1;
        }else{
            endAngle2 = self.startPoint;
        }
    }
    UIBezierPath *arcBezier2 = [UIBezierPath bezierPathWithArcCenter:self.arcCenter radius:kradius startAngle:self.endPoint1 endAngle:endAngle2 clockwise:YES];
    arcBezier2.lineWidth = klineWidth;
    [arcBezier2 stroke];
    NSInteger tag2 = 2;
    [self drawTriangleWithRadian:self.endPoint1 andTag:tag2];
    self.thirdPoint = 100 *(M_PI*2 - (self.endPoint0 - self.startPoint) - (self.endPoint1 - self.endPoint0))/(M_PI*2);
    int point1 = round(self.firstPoint);
    int point2 = round(self.secondPoint);
    int point3 = round(self.thirdPoint);
    
    // 当其中两个值为0时，第三个不能做到为100
    if (point1 == 0 && point2 == 0) {
        point3 = 100;
    }else if (point1 == 0 && point3 == 0){
        point2 = 100;
    }else if (point2 == 0 && point3 == 0){
        point1 = 100;
    }
    if (point3 != 100) {
        point3 = 100 -point1 -point2;
    }
    self.hbNum = [NSString stringWithFormat:@"%d%%",point1];
    self.zqNum = [NSString stringWithFormat:@"%d%%",point2];
    self.gpNum = [NSString stringWithFormat:@"%d%%",point3];
    NSLog(@"第一个弧：%@",self.hbNum);
    NSLog(@"第二个弧：%@",self.zqNum);
    NSLog(@"第三个弧：%@",self.gpNum);
    
}


- (void)drawTriangleWithRadian:(CGFloat)radian  andTag:(NSInteger)tag{
    // 顺时针滑动，当超过一周时
    if (radian >= M_PI *2) {
        radian = radian - M_PI*2;
    }else if (radian <= -M_PI){
        radian = M_PI*2 + radian;
    }
    
    [[UIColor grayColor] set];
    UIBezierPath *line = [UIBezierPath bezierPath];
    line.lineWidth = 1;
    line.lineCapStyle = kCGLineCapRound;
    line.lineJoinStyle = kCGLineCapRound;
    // 线的起点
    CGPoint startPoint = CGPointMake(self.frame.size.width / 2, self.frame.size.width / 2);
    // 线的第二个点
    CGPoint secondPoint = CGPointMake(self.frame.size.width / 2 + (kradius + kdistance) *  cos(radian), self.frame.size.width / 2 + (kradius + kdistance) * sin(radian));
    // 用来计算三角形外面两个点的一个过渡点（外面那个边的中点）
    CGPoint transit = CGPointMake(self.frame.size.width / 2 + (kradius + kdistance + kside) *  cos(radian), self.frame.size.width / 2 + (kradius + kdistance + kside) * sin(radian)); // 过渡点
    CGPoint thirdPoint;
    CGPoint fourthPoint;
    // 要判断三角形所在位置
    if (self.currentPoint.x <= self.arcCenter.x && self.currentPoint.y < self.arcCenter.y) {
        thirdPoint = CGPointMake(transit.x + sin(radian)*kside, transit.y - cos(radian)*kside);
        fourthPoint =  CGPointMake(transit.x - sin(radian)*kside, transit.y + cos(radian)*kside);
    }else if (self.currentPoint.x > self.arcCenter.x && self.currentPoint.y < self.arcCenter.y) {
        thirdPoint = CGPointMake(transit.x + sin(radian)*kside, transit.y - cos(radian)*kside);
        fourthPoint = CGPointMake(transit.x - sin(radian)*kside, transit.y + cos(radian)*kside);
    }else if( self.currentPoint.x >= self.arcCenter.x && self.currentPoint.y >= self.arcCenter.y){
        thirdPoint = CGPointMake(transit.x + sin(radian)*kside, transit.y - cos(radian)*kside);
        fourthPoint = CGPointMake(transit.x - sin(radian)*kside, transit.y + cos(radian)*kside);
        
    }else if (self.currentPoint.x <= self.arcCenter.x && self.currentPoint.y >= self.arcCenter.y){
        thirdPoint = CGPointMake(transit.x + cos(radian - M_PI/2)*kside, transit.y + sin(radian - M_PI/2)*kside);
        fourthPoint = CGPointMake(transit.x - cos(radian - M_PI/2)*kside, transit.y - sin(radian - M_PI/2)*kside);
    }
    [line moveToPoint:startPoint];
    [line addLineToPoint:secondPoint];
    [line addLineToPoint:thirdPoint];
    [line addLineToPoint:fourthPoint];
    [line addLineToPoint:secondPoint];
    [line closePath];
    [line fill];
    [line stroke];
    
    UIBezierPath *path =nil;
    // 根据tag，来确定可触摸的滑动区域
    if (tag == 0) {
        path = [UIBezierPath bezierPathWithArcCenter:transit radius:15 startAngle:0 endAngle:M_PI*2 clockwise:YES];
        if (self.touch0) {
            if (self.tagLeft) {
                self.touch0 = path;
            }
        }else{
            self.touch0 = path;
        }
    }else if (tag == 1){
        path = [UIBezierPath bezierPathWithArcCenter:transit radius:15 startAngle:0 endAngle:M_PI*2 clockwise:YES];
        if (self.touch1) {
            if (self.tagLeft) {
                self.touch1 = path;
            }
        }else{
            self.touch1 = path;
        }
    }else if (tag == 2){
        path = [UIBezierPath bezierPathWithArcCenter:transit radius:15 startAngle:0 endAngle:M_PI*2 clockwise:YES];
        if (self.touch2) {
            if (self.tagLeft) {
                self.touch2 = path;
            }
        }else{
            
            self.touch2 = path;
        }
    }
    [[UIColor whiteColor] set];
    UIBezierPath *coverArc = [UIBezierPath bezierPathWithArcCenter:self.arcCenter radius:kradius- klineWidth/2 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    [coverArc fill];
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    self.tagLeft = 0;
    UITouch *firstTouch = [touches allObjects].firstObject;
    CGPoint firstPoint = [firstTouch locationInView:self];
    self.firstTouch = firstPoint;
    
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *currentTouch = [touches allObjects].firstObject;
    CGPoint currentPoint = [currentTouch locationInView:self];
    CGPoint previousPoint = [currentTouch previousLocationInView:self];
    NSInteger rotation = [self getRotationWithCurrentPoint:currentPoint  andPreviousPoint:previousPoint]; // 0为顺时针，1为逆时针,2什么都不是
    if ([self.hbNum isEqualToString:@"100%"]) {
        self.touch1 = nil;
        self.touch2 = nil;
    }else if ([self.zqNum isEqualToString:@"100%"]){
        self.touch0 = nil;
        self.touch2 = nil;
    }else if ([self.gpNum isEqualToString:@"100%"]){
        self.touch0 = nil;
        self.touch1 = nil;
    }
    if ([self.touch0 containsPoint:self.firstTouch] ) {
        if ((self.firstPoint > 0 && self.thirdPoint > 0) || (self.firstPoint <= 0 && rotation == 1) || (self.thirdPoint <= 0 && rotation == 0)) {
            float thirdP = 100 *(M_PI*2 - (self.endPoint0 - (self.startPoint + self.changFloat)) - (self.endPoint1 - self.endPoint0))/(M_PI*2);
            
            if ( thirdP <= 0 || self.startPoint + self.changFloat >= self.endPoint0) {
                
            }else{
                self.startPoint = self.startPoint + self.changFloat;
                self.currentPoint = currentPoint;
                [self setNeedsDisplay];
            }
        }
        
    }else if ([self.touch1 containsPoint:self.firstTouch]){
        
        if ((self.firstPoint >= 0 && self.secondPoint > 0) || (self.firstPoint <= 0 && rotation == 0) || (self.secondPoint <= 0 && rotation == 1)) {
            
            float firstP = fabs(100*(self.endPoint0 + self.changFloat - self.startPoint)/(M_PI*2));
            if (firstP <= 0 || self.endPoint0 + self.changFloat >= self.endPoint1) {
                
            }else{
                self.endPoint0 += self.changFloat;
                self.currentPoint = currentPoint;
                [self setNeedsDisplay];
            }
        }
        
    }else if ([self.touch2 containsPoint:self.firstTouch]){
        
        if ((self.thirdPoint > 0 && self.secondPoint > 0) || (self.thirdPoint <= 0 && rotation == 1) || (self.secondPoint <= 0 && rotation == 0)) {
            if ((self.endPoint1 + self.changFloat - self.startPoint) >= M_PI *2 || self.endPoint1 + self.changFloat <= self.endPoint0 ) {
                
            }else{
                self.endPoint1 += self.changFloat;
                self.currentPoint = currentPoint;
                [self setNeedsDisplay];
            }
            
        }
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([self.touch0 containsPoint:self.firstTouch] || [self.touch1 containsPoint:self.firstTouch] ||[self.touch2 containsPoint:self.firstTouch]) {
        self.tagLeft = 1;
        [self setNeedsDisplay];
    }
    self.firstTouch = CGPointZero;
}


// 判断顺逆时针
- (NSInteger)getRotationWithCurrentPoint:(CGPoint)currentPoint andPreviousPoint:(CGPoint)previousPoint {
    CGFloat previousFloat = [self getFloat:previousPoint];
    CGFloat currentFloat = [self getFloat:currentPoint];
    self.changFloat = fabs(currentFloat - previousFloat);
    if (previousPoint.x < self.arcCenter.x && currentPoint.x < self.arcCenter.x) {
        if (previousFloat > currentFloat) {
            
            return 0; // 顺
        }else{
            self.changFloat = - self.changFloat;
            return 1;
        }
    }else if (previousPoint.x > self.arcCenter.x && currentPoint.x > self.arcCenter.x){
        if (previousFloat > currentFloat) {
            self.changFloat = - self.changFloat;
            return 1;
        }else{
            return 0;
        }
    }else if (previousPoint.x <= self.arcCenter.x && currentPoint.x > self.arcCenter.x){
        if (previousPoint.y < self.arcCenter.y) {
            self.changFloat =  currentFloat + previousFloat;
            return 0;
        }else{
            self.changFloat = - ( M_PI *2 - currentFloat - previousFloat );
            return 1;
        }
    }else if (previousPoint.x >= self.arcCenter.x && currentPoint.x < self.arcCenter.x){
        if (previousPoint.y < self.arcCenter.y) {
            self.changFloat = - (currentFloat + previousFloat);
            return 1;
        }else{
            self.changFloat = M_PI *2 - currentFloat - previousFloat;
            return 0;
        }
    }else{
        return 2;
    }
    
}

// 计算角度
- (CGFloat)getFloat:(CGPoint)point{
    CGPoint pointCopare = CGPointMake(self.arcCenter.x, 0);
    CGFloat sideA = sqrtf((point.x - self.arcCenter.x)*(point.x - self.arcCenter.x) + (point.y - self.arcCenter.y)*(point.y - self.arcCenter.y));
    CGFloat sideB = self.arcCenter.y;
    CGFloat sideC = sqrtf((point.x - pointCopare.x)*(point.x - pointCopare.x) + (point.y - pointCopare.y)*(point.y - pointCopare.y));
    float calculateFloat = acosf((sideA *sideA + sideB * sideB - sideC * sideC)/(2 *sideA*sideB));
    return calculateFloat;
}


@end
