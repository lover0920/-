//
//  SDDLineChart.m
//  SDLineChart
//
//  Created by 孙号斌 on 16/10/9.
//  Copyright © 2016年 孙号斌. All rights reserved.
//

#import "SDDLineChart.h"

#define IOS7_OR_LATER [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0
#define SELF_WIDTH  self.frame.size.width
#define SELF_HEIGHT self.frame.size.height

#define UNIT_FONT   [UIFont systemFontOfSize:12]
#define UNIT_COLOR  [UIColor grayColor]

#pragma mark -
#pragma mark - SDDLineChartData
#pragma mark -
@implementation SDDLineChartData
- (instancetype)init
{
    return [self initWithLineTag:@"lineTag"];
}
- (instancetype)initWithLineTag:(NSString *)lineTag
{
    self = [super init];
    if (self)
    {
        [self setDefaultValuesWithLineTag:lineTag];
    }
    return self;
}
- (void)setDefaultValuesWithLineTag:(NSString *)lineTag
{
    _lineTag = lineTag;
    
    _lineColor = [UIColor colorWithRed:239/255.0 green:172/255.0 blue:5/255.0 alpha:1];
    _lineWidth = 1.0f;
    
    _showPointLabel = YES;
    _pointLabelFont = [UIFont systemFontOfSize:12];
    _pointLabelColor = [UIColor grayColor];
    
    _inflexionPointStyle = SDDLineChartPointStyleCircle;
    _inflexionPointColor = _lineColor;
    _inflexionPointWidth = 4.0f;
}
@end


#pragma mark -
#pragma mark - SDDLineChart
#pragma mark -
@interface SDDLineChart ()<CALayerDelegate>
@property (nonatomic, strong) UIScrollView  *scrollView;
@property (nonatomic, strong) UIView        *yAxisView;

@property (nonatomic, assign) CGFloat       yStepHeight;
@property (nonatomic, strong) NSArray       *xLabels;               //x轴坐标的刻度
@property (nonatomic, strong) NSArray       *yLabels;               //y轴坐标的刻度
@property (nonatomic, assign) NSInteger     yLabelNum;              //yLabel个数
@property (nonatomic, assign) CGFloat       axisMarkWidth;          //坐标轴刻度宽

@property (nonatomic, strong) NSMutableDictionary *chartDataLayerDic;


@property (nonatomic, strong) NSMutableArray *xCoordinateAxisLayers;//x坐标轴

@property (nonatomic, strong) NSMutableArray *yCoordinateAxisMarks; //y坐标轴刻度
@property (nonatomic, strong) NSMutableArray *xCoordinateAxisMarks; //x坐标轴刻度

@property (nonatomic, strong) NSMutableArray *yAxisLabelLayers;     //y坐标轴文字
@property (nonatomic, strong) NSMutableArray *xAxisLabelLayers;     //x坐标轴文字

@property (nonatomic, strong) NSMutableArray *yGridLinesArray;
@property (nonatomic, strong) NSMutableArray *xGridLinesArray;

@property (nonatomic, strong) SDDLineChartData *chartDataProperty;
@end


@implementation SDDLineChart


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaultValues];
        [self createUI];
    }
    return self;
}
- (void)setDefaultValues
{
    
    /*************** 坐标轴 ***************/
    _showCoordinateAxis = YES;
    
    _axisColor = [UIColor blackColor];
    _axisWidth = 1.0f;
    
    /*************** 坐标轴刻度 ***************/
    _showLabel = YES;
    _yLabelFont = [UIFont systemFontOfSize:14];
    _yLabelColor = [UIColor grayColor];
    
    _xLabelFont = [UIFont systemFontOfSize:14];
    _xLabelColor = [UIColor grayColor];
    
    /*************** 网格线 ***************/
    _showXGridLines = YES;
    _xGridLinesColor = [UIColor lightGrayColor];
    _xGridLinesStyle = SDDLineChartGridLinesStyleDefault;
    
    _showYGridLines = YES;
    _yGridLinesColor = [UIColor lightGrayColor];
    _yGridLinesStyle = SDDLineChartGridLinesStyleFullLine;
    
    /*************** 坐标轴相关的距离 ***************/
    _chartMarginUp = 20.0f;
    _chartMarginBottom = 20.0f;
    _chartMarginLeft = 45.0f;
    _chartMarginRight = 30.0f;
    
    _xStepWidth = 30.0f;
    _firstGridLineWidth = 15.0f;
    
    _axisMarkWidth = 2.0f;
    
    
    
    /*************** 初始化数组 ***************/
    _xCoordinateAxisLayers = [NSMutableArray array];
    
    _xCoordinateAxisMarks = [NSMutableArray array];
    _yCoordinateAxisMarks = [NSMutableArray array];
    
    _xAxisLabelLayers = [NSMutableArray array];
    _yAxisLabelLayers = [NSMutableArray array];
    
    _xGridLinesArray = [NSMutableArray array];
    _yGridLinesArray = [NSMutableArray array];
    
    _chartDataLayerDic = [NSMutableDictionary dictionary];
}
- (void)createUI
{
    self.backgroundColor = [UIColor whiteColor];
    
    /*************** 创建滚动视图 ***************/
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(_chartMarginLeft+_axisWidth,
                                                                0,
                                                                SELF_WIDTH-_chartMarginLeft-_axisWidth,
                                                                SELF_HEIGHT)];
    _scrollView.contentSize = _scrollView.frame.size;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.bounces = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];
    
    /*************** 创建Y轴的View ***************/
    _yAxisView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _chartMarginLeft+3, SELF_HEIGHT)];
    _yAxisView.backgroundColor = [UIColor clearColor];
    [self addSubview:_yAxisView];
}

- (void)setXLables:(NSArray *)xLabels yLables:(NSArray *)yLabels
{
    _xLabels = xLabels;
    
    _yLabels = yLabels;
    _yLabelNum = yLabels.count;
    _yStepHeight = (SELF_HEIGHT - _chartMarginUp - _chartMarginBottom - _firstGridLineWidth) / (_yLabelNum - 1);
    
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];

    /****************************** 修改坐标轴 ******************************/
    if (_showCoordinateAxis)
    {
        /*************** y轴刻度 ***************/
        for (CAShapeLayer *shapeLayer in _yCoordinateAxisMarks)
        {
            [shapeLayer removeFromSuperlayer];
        }
        for (int i = 0; i < _yLabelNum; i++)
        {
            CGFloat y = _chartMarginUp + i * _yStepHeight;
            
            [_yCoordinateAxisMarks addObject:[SDDLineChart drawLine:_yAxisView
                                                          lineWidth:1.0
                                                          lineColor:_axisColor
                                                         startPoint:CGPointMake(_chartMarginLeft, y)
                                                        interPoints:nil
                                                           endPoint:CGPointMake(_chartMarginLeft+_axisWidth+_axisMarkWidth, y)]];
        }
        
        /*************** x轴 ***************/
        [self drawXCoordinateAxis];
        
        /*************** x轴刻度 ***************/
        for (CAShapeLayer *shapeLayer in _xCoordinateAxisMarks)
        {
            [shapeLayer removeFromSuperlayer];
        }
        CGFloat startY = SELF_HEIGHT - _chartMarginBottom - _axisWidth - _axisMarkWidth;
        CGFloat endY = startY + _axisMarkWidth;
        
        for (int i = 0; i < xLabels.count; i++)
        {
            CGFloat x = _firstGridLineWidth + i * _xStepWidth;
            
            [_xCoordinateAxisMarks addObject:[SDDLineChart drawLine:_scrollView
                                                          lineWidth:1.0
                                                          lineColor:_axisColor
                                                         startPoint:CGPointMake(x, startY)
                                                        interPoints:nil
                                                           endPoint:CGPointMake(x, endY)]];
        }
    }
    
    /****************************** 坐标轴label ******************************/
    if (_showLabel)
    {
        /*************** y轴 ***************/
        for (CATextLayer *textLayer in _yAxisLabelLayers)
        {
            [textLayer removeFromSuperlayer];
        }
        for (int i = 0; i < _yLabelNum; i++)
        {
            CGFloat y = _chartMarginUp + i * _yStepHeight - 10;
            
            [_yAxisLabelLayers addObject:[SDDLineChart drawText:_yAxisView
                                                          frame:CGRectMake(0, y, _chartMarginLeft, 20)
                                                           text:[yLabels objectAtIndex:(_yLabelNum - 1 - i)]
                                                      textColor:_yLabelColor
                                                           font:_yLabelFont]];
        }
        
        
        /*************** x轴 ***************/
        for (CATextLayer *textLayer in _xAxisLabelLayers)
        {
            [textLayer removeFromSuperlayer];
        }
        
        CGFloat startY = SELF_HEIGHT - _chartMarginBottom;
        for (int i = 0; i < xLabels.count; i++)
        {
            CGFloat x = _firstGridLineWidth + i * _xStepWidth - _xStepWidth/2;
            
            [_xAxisLabelLayers addObject:[SDDLineChart drawText:_scrollView
                                                          frame:CGRectMake(x, startY, _xStepWidth, _chartMarginBottom)
                                                           text:[xLabels objectAtIndex:i]
                                                      textColor:_yLabelColor
                                                           font:_yLabelFont]];
        }
        /*************** 坐标轴单位 ***************/
        //y轴单位
        NSString *unit;
        if (_yUnit != nil)
        {
            unit = [NSString stringWithFormat:@"(%@)",_yUnit];
            CGSize textSize = [SDDLineChart sizeOfString:unit withWidth:100 font:UNIT_FONT];
            
            CGRect rect = CGRectMake(5, (_chartMarginUp-textSize.height)/2, textSize.width, textSize.height);
            [_xAxisLabelLayers addObject:[SDDLineChart drawText:_scrollView
                                                          frame:rect
                                                           text:unit
                                                      textColor:UNIT_COLOR
                                                           font:UNIT_FONT]];
        }
        //X轴单位
        if (_xUnit != nil)
        {
            unit = [NSString stringWithFormat:@"(%@)",_xUnit];
            CGSize textSize = [SDDLineChart sizeOfString:unit withWidth:100 font:[UIFont systemFontOfSize:12]];
            
            CGRect rect = CGRectMake(_scrollView.contentSize.width-textSize.width, SELF_HEIGHT-_chartMarginBottom-20, textSize.width, textSize.height);
            [_xAxisLabelLayers addObject:[SDDLineChart drawText:_scrollView
                                                          frame:rect
                                                           text:unit
                                                      textColor:UNIT_COLOR
                                                           font:UNIT_FONT]];
        }
    }
    
    /****************************** 垂直Y轴的网格线 ******************************/
    if (_showYGridLines)
    {
        for (CAShapeLayer *shapeLayer in _yGridLinesArray)
        {
            [shapeLayer removeFromSuperlayer];
        }
        
        if (_yGridLinesStyle == SDDLineChartGridLinesStyleDefault)
        {
            for (int i = 0; i < yLabels.count; i++)
            {
                CGFloat y = i * _yStepHeight + _chartMarginUp;
                [_yGridLinesArray addObject:[SDDLineChart drawDashLine:_scrollView
                                                             lineWidth:0.5
                                                             lineColor:_yGridLinesColor
                                                          lineProperty:@[@6,@3]
                                                            startPoint:CGPointMake(0, y)
                                                              endPoint:CGPointMake(_scrollView.contentSize.width-_chartMarginRight, y)]];
            }
        }
        else
        {
            for (int i = 0; i < yLabels.count; i++)
            {
                CGFloat y = i * _yStepHeight + _chartMarginUp;

                [_yGridLinesArray addObject:[SDDLineChart drawLine:_scrollView
                                                         lineWidth:0.5
                                                         lineColor:_yGridLinesColor
                                                        startPoint:CGPointMake(0, y)
                                                       interPoints:nil
                                                          endPoint:CGPointMake(_scrollView.contentSize.width-_chartMarginRight, y)]];
            }
        }
    }
    
    /****************************** 垂直X轴的网格线 ******************************/
    if (_showXGridLines)
    {
        for (CAShapeLayer *shapeLayer in _xGridLinesArray)
        {
            [shapeLayer removeFromSuperlayer];
        }
        
        
        CGFloat startY = SELF_HEIGHT - _chartMarginBottom - _axisMarkWidth;
        if (_xGridLinesStyle == SDDLineChartGridLinesStyleDefault)
        {
            for (int i = 0; i < xLabels.count; i++)
            {
                CGFloat x = _firstGridLineWidth + i * _xStepWidth;
                [_xGridLinesArray addObject:[SDDLineChart drawDashLine:_scrollView
                                                             lineWidth:0.5
                                                             lineColor:_xGridLinesColor
                                                          lineProperty:@[@6,@3]
                                                            startPoint:CGPointMake(x, _chartMarginUp)
                                                              endPoint:CGPointMake(x, startY)]];
            }
        }
        else
        {
            for (int i = 0; i < xLabels.count; i++)
            {
                CGFloat x = _firstGridLineWidth + i * _xStepWidth;
                
                [_xGridLinesArray addObject:[SDDLineChart drawLine:_scrollView
                                                         lineWidth:0.5
                                                         lineColor:_xGridLinesColor
                                                        startPoint:CGPointMake(x, _chartMarginUp)
                                                       interPoints:nil
                                                          endPoint:CGPointMake(x, startY)]];
            }
        }
    }
}

- (void)addChartData:(NSArray *)chartData chartDataProperty:(SDDLineChartData *)dataProperty
{
    _chartDataProperty = dataProperty;
    
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    
    
    NSMutableArray *allLayer = [_chartDataLayerDic objectForKey:dataProperty.lineTag];
    for (CALayer *layer in allLayer)
    {
        [layer removeFromSuperlayer];
    }
    [_chartDataLayerDic removeObjectForKey:dataProperty.lineTag];
    
    
    /*************** 计算数据的坐标 ***************/
    NSMutableArray *pointArray = [NSMutableArray array];
    float mDifference = _yValueMax - _yValueMin;
    CGFloat mYStep = (_yLabels.count - 1) * _yStepHeight;
    
    for (int i = 0; i < chartData.count; i++)
    {
        float dataY = [[chartData objectAtIndex:i] floatValue];
        
        CGPoint point = CGPointMake(_firstGridLineWidth + i * _xStepWidth,
                                    ((_yValueMax - dataY) * mYStep / mDifference) + _chartMarginUp);
        
        [pointArray addObject:[NSValue valueWithCGPoint:point]];
    }
    
    
    NSMutableArray *allLayerArray = [NSMutableArray array];
    /*************** 画线 ***************/
    CGFloat startTime = 0.0f;
    CGFloat duration = 0.1f;
    for (int i = 0; i < chartData.count - 1; i++)
    {
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        basicAnimation.duration = startTime+duration;
        basicAnimation.fromValue = [NSNumber numberWithFloat:-startTime/duration];
        basicAnimation.toValue = [NSNumber numberWithFloat:0.5];
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:[[pointArray objectAtIndex:i] CGPointValue]];
        [path addLineToPoint:[[pointArray objectAtIndex:i+1] CGPointValue]];
        
        CAShapeLayer *pathLayer = [CAShapeLayer layer];
        pathLayer.frame = _scrollView.bounds;
        pathLayer.path = path.CGPath;
        pathLayer.strokeColor = _chartDataProperty.lineColor.CGColor;
        pathLayer.lineWidth = _chartDataProperty.lineWidth;
        pathLayer.lineJoin = kCALineJoinBevel;
        [pathLayer addAnimation:basicAnimation forKey:@"strokeEnd"];
        
        [_scrollView.layer addSublayer:pathLayer];
        [allLayerArray addObject:pathLayer];
        
        startTime+=0.1;
    }
    
    /*************** 画拐点 ***************/
    if (_chartDataProperty.inflexionPointStyle != SDDLineChartPointStyleNone)
    {
        startTime = 0.0f;
        float width = _chartDataProperty.inflexionPointWidth;
        
        for (int i = 0; i < chartData.count; i++)
        {
            CGPoint centerPoint = [[pointArray objectAtIndex:i] CGPointValue];
            
            CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            basicAnimation.duration = startTime+duration;
            basicAnimation.fromValue = [NSNumber numberWithFloat:-startTime/duration];
            basicAnimation.toValue = [NSNumber numberWithFloat:0.5];
            
            UIBezierPath *path = [UIBezierPath bezierPath];
            switch (_chartDataProperty.inflexionPointStyle)
            {
                case SDDLineChartPointStyleCircle:
                    [path addArcWithCenter:centerPoint radius:width/2 startAngle:0 endAngle:2 * M_PI clockwise:YES];
                    break;
                case SDDLineChartPointStyleSquare:
                {
                    [path moveToPoint:CGPointMake(centerPoint.x-width/2, centerPoint.y-width/2)];
                    [path addLineToPoint:CGPointMake(centerPoint.x-width/2, centerPoint.y+width/2)];
                    [path addLineToPoint:CGPointMake(centerPoint.x+width/2, centerPoint.y+width/2)];
                    [path addLineToPoint:CGPointMake(centerPoint.x+width/2, centerPoint.y-width/2)];
                    [path closePath];
                }
                    break;
                case SDDLineChartPointStyleTriangle:
                {
                    [path moveToPoint:CGPointMake(centerPoint.x, centerPoint.y-width/2)];
                    [path addLineToPoint:CGPointMake(centerPoint.x+width/2, centerPoint.y+width/2)];
                    [path addLineToPoint:CGPointMake(centerPoint.x-width/2, centerPoint.y+width/2)];
                    [path closePath];
                }
                    break;
                default:
                    break;
            }
            
            CAShapeLayer *pathLayer = [CAShapeLayer layer];
            pathLayer.frame = _scrollView.bounds;
            pathLayer.path = path.CGPath;
            pathLayer.strokeColor = _chartDataProperty.inflexionPointColor.CGColor;
            pathLayer.fillColor = self.backgroundColor.CGColor;
            pathLayer.lineWidth = _chartDataProperty.lineWidth;
            [pathLayer addAnimation:basicAnimation forKey:@"strokeEnd"];
            
            [_scrollView.layer addSublayer:pathLayer];
            [allLayerArray addObject:pathLayer];

            startTime+=0.1;
        }

    }
    
    
    /*************** 画拐点Label ***************/
    if (_chartDataProperty.showPointLabel)
    {
        CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeAnimation.fromValue = [NSNumber numberWithFloat:0.0];
        fadeAnimation.toValue = [NSNumber numberWithFloat:1.0];
        fadeAnimation.duration = 2.0;

        float textLayerHeight = [SDDLineChart sizeOfString:@"11" withWidth:_xStepWidth font:_chartDataProperty.pointLabelFont].height;
        
        for (int i = 0; i < chartData.count; i++)
        {
            CGPoint centerPoint = [[pointArray objectAtIndex:i] CGPointValue];
            
            CGRect frame = CGRectMake(centerPoint.x-_xStepWidth/2,
                                      centerPoint.y-_chartDataProperty.inflexionPointWidth-textLayerHeight,
                                      _xStepWidth, textLayerHeight);
            NSString *text = self.centerLabels.count ? self.centerLabels[i] : [NSString stringWithFormat:@"%@",[chartData objectAtIndex:i]];
            
            CATextLayer *textLayer = [SDDLineChart drawText:_scrollView
                                                      frame:frame
                                                       text:text
                                                  textColor:_chartDataProperty.pointLabelColor
                                                       font:_chartDataProperty.pointLabelFont];
            [textLayer addAnimation:fadeAnimation forKey:nil];
            
            [allLayerArray addObject:textLayer];
        }
    }
    
    [_chartDataLayerDic setValue:allLayerArray forKey:_chartDataProperty.lineTag];
}

- (void)removeChartDateWithLineTag:(NSString *)lineTag
{
    NSString *key = lineTag;
    if (lineTag == nil)
    {
        key = @"lineTag";
    }
    
    NSMutableArray *allLayer = [_chartDataLayerDic objectForKey:key];
    for (CALayer *layer in allLayer)
    {
        [layer removeFromSuperlayer];
    }
    [_chartDataLayerDic removeObjectForKey:key];
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (_showCoordinateAxis)
    {
        //画Y轴
        [SDDLineChart drawLine:_yAxisView
                     lineWidth:_axisWidth
                     lineColor:_axisColor
                    startPoint:CGPointMake(_chartMarginLeft, 0)
                   interPoints:nil
                      endPoint:CGPointMake(_chartMarginLeft, SELF_HEIGHT-_chartMarginBottom)];
        
        [SDDLineChart drawLine:_yAxisView
                     lineWidth:_axisWidth
                     lineColor:_axisColor
                    startPoint:CGPointMake(_chartMarginLeft-3, 6)
                   interPoints:[NSArray arrayWithObject:[NSValue valueWithCGPoint:CGPointMake(_chartMarginLeft, 0)]]
                      endPoint:CGPointMake(_chartMarginLeft+3, 6)];
        
        //画X轴
        CGFloat pointY = SELF_HEIGHT-_chartMarginBottom-_axisWidth;
        
        [_xCoordinateAxisLayers addObject:[SDDLineChart drawLine:_scrollView
                                                       lineWidth:_axisWidth
                                                       lineColor:_axisColor
                                                      startPoint:CGPointMake(0, pointY)
                                                     interPoints:nil
                                                        endPoint:CGPointMake(_scrollView.contentSize.width, pointY)]];
        //画箭头
        NSArray *interPoints = [NSArray arrayWithObject:[NSValue valueWithCGPoint:CGPointMake(_scrollView.contentSize.width, pointY)]];
        [_xCoordinateAxisLayers addObject:[SDDLineChart drawLine:_scrollView
                                                       lineWidth:_axisWidth
                                                       lineColor:_axisColor
                                                      startPoint:CGPointMake(_scrollView.contentSize.width-6, pointY-3)
                                                     interPoints:interPoints
                                                        endPoint:CGPointMake(_scrollView.contentSize.width-6, pointY+3)]];
    }
}
- (void)setScrollViewContentSize
{
    CGFloat originWidth = SELF_WIDTH - _chartMarginLeft - _axisWidth;
    
    CGFloat width = _firstGridLineWidth + (_xLabels.count - 1) * _xStepWidth + _chartMarginRight;
    
    if (originWidth > width)
    {
        _scrollView.contentSize = CGSizeMake(originWidth, SELF_HEIGHT);
    }
    else
    {
        _scrollView.contentSize = CGSizeMake(width, SELF_HEIGHT);
    }
}

- (void)drawXCoordinateAxis
{
    for (CAShapeLayer *shapeLayer in _xCoordinateAxisLayers)
    {
        [shapeLayer removeFromSuperlayer];
    }
    
    //设置scrollView的contentSize
    [self setScrollViewContentSize];
    
    /*************** 画X轴 ***************/
    CGFloat pointY = SELF_HEIGHT-_chartMarginBottom-_axisWidth;
    
    [_xCoordinateAxisLayers addObject:[SDDLineChart drawLine:_scrollView
                                                   lineWidth:_axisWidth
                                                   lineColor:_axisColor
                                                  startPoint:CGPointMake(0, pointY)
                                                 interPoints:nil
                                                    endPoint:CGPointMake(_scrollView.contentSize.width, pointY)]];
    //画箭头
    NSArray *interPoints = [NSArray arrayWithObject:[NSValue valueWithCGPoint:CGPointMake(_scrollView.contentSize.width, pointY)]];
    [_xCoordinateAxisLayers addObject:[SDDLineChart drawLine:_scrollView
                                                   lineWidth:_axisWidth
                                                   lineColor:_axisColor
                                                  startPoint:CGPointMake(_scrollView.contentSize.width-6, pointY-3)
                                                 interPoints:interPoints
                                                    endPoint:CGPointMake(_scrollView.contentSize.width-6, pointY+3)]];
}


#pragma mark - Common Units
//画虚线
+ (CAShapeLayer *)drawDashLine:(UIView *)superView
                     lineWidth:(CGFloat)lineWidth
                     lineColor:(UIColor *)lineColor
                  lineProperty:(NSArray *)lineProperty
                    startPoint:(CGPoint)startPoint
                      endPoint:(CGPoint)endPoint
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = superView.bounds;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = lineWidth;                       //虚线宽度
    shapeLayer.strokeColor = lineColor.CGColor;             //虚线颜色
    shapeLayer.lineJoin = kCALineCapRound;
    shapeLayer.lineDashPattern = lineProperty;              //@[@6,@3]  6表示线宽，3表示线间隔
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, startPoint.x, startPoint.y);
    CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);
    
    shapeLayer.path = path;
    CGPathRelease(path);
    
    [superView.layer addSublayer:shapeLayer];
    return shapeLayer;
}
//画实线
+ (CAShapeLayer *)drawLine:(UIView *)superView
                 lineWidth:(CGFloat)lineWidth
                 lineColor:(UIColor *)lineColor
                startPoint:(CGPoint)startPoint
               interPoints:(NSArray *)interPoints
                  endPoint:(CGPoint)endPoint
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    for (NSValue *pointValue in interPoints)
    {
        [path addLineToPoint:pointValue.CGPointValue];
    }
    [path addLineToPoint:endPoint];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = superView.bounds;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = lineWidth;                       //虚线宽度
    shapeLayer.strokeColor = lineColor.CGColor;             //虚线颜色
    shapeLayer.lineJoin = kCALineJoinBevel;
    shapeLayer.path = path.CGPath;
    
    [superView.layer addSublayer:shapeLayer];
    return shapeLayer;
}
//画文字
+ (CATextLayer *)drawText:(UIView *)superView
                    frame:(CGRect)frame
                     text:(NSString *)text
                textColor:(UIColor *)textColor
                     font:(UIFont *)font
{
    CATextLayer *textLayer = [[CATextLayer alloc] init];
    [textLayer setFrame:frame];
    [textLayer setAlignmentMode:kCAAlignmentCenter];
    [textLayer setForegroundColor:[textColor CGColor]];
    [textLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
    [textLayer setContentsScale:[UIScreen mainScreen].scale];
    [textLayer setTruncationMode:kCATruncationEnd];                 //如何将字符串截断以适应图层大小
    
    
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    textLayer.font = fontRef;
    textLayer.fontSize = font.pointSize;
    CGFontRelease(fontRef);
    
    [textLayer setString:text];
    
    [superView.layer addSublayer:textLayer];
    return textLayer;
}

+ (CGSize)sizeOfString:(NSString *)text
             withWidth:(float)width
                  font:(UIFont *)font
{
    CGSize size = CGSizeMake(width, MAXFLOAT);
    
    if ([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSDictionary *tdic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
        size = [text boundingRectWithSize:size
                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                               attributes:tdic
                                  context:nil].size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        size = [text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
#pragma clang diagnostic pop
    }
    
    return size;
}
































#pragma mark - 无用的方法
//画直线
- (void)drawStraightLinesInContext:(CGContextRef)ctx
                         lineWidth:(CGFloat)lineWidth
                         lineColor:(UIColor *)lineColor
                        startPoint:(CGPoint)startPoint
                       interPoints:(NSArray *)interPoints
                          endPoint:(CGPoint)endPoint
{
//    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(ctx);
    CGContextSetLineWidth(ctx, lineWidth);
    CGContextSetStrokeColorWithColor(ctx, lineColor.CGColor);
    
    CGContextMoveToPoint(ctx, startPoint.x, startPoint.y);
    CGPoint interPoint;
    for (NSInteger i = 0; i < interPoints.count; i++)
    {
        interPoint = [[interPoints objectAtIndex:i] CGPointValue];  //[NSValue valueWithCGPoint:point];
        CGContextAddLineToPoint(ctx, interPoint.x, interPoint.y);
    }
    CGContextAddLineToPoint(ctx, endPoint.x, endPoint.y);
    
    CGContextStrokePath(ctx);
}
//画网格线
- (void)drawGridLinesInContext:(CGContextRef)ctx
                     lineColor:(UIColor *)lineColor
                    startPoint:(CGPoint)startPoint
                      endPoint:(CGPoint)endPoint
{
    CGContextSetStrokeColorWithColor(ctx, lineColor.CGColor);
    
    CGContextMoveToPoint(ctx, startPoint.x, startPoint.y);
    // add dotted style grid
    CGFloat dash[] = {6, 5};
    // dot diameter is 20 points
    CGContextSetLineWidth(ctx, 0.5);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineDash(ctx, 0.0, dash, 2);
    CGContextAddLineToPoint(ctx, endPoint.x, endPoint.y);
    CGContextStrokePath(ctx);
}
//画文字
- (void)drawTextInContext:(CGContextRef)ctx
                     text:(NSString *)text
                   inRect:(CGRect)rect
                     font:(UIFont *)font
{
    if (IOS7_OR_LATER)
    {
        NSMutableParagraphStyle *priceParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        priceParagraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        priceParagraphStyle.alignment = NSTextAlignmentLeft;
        
        [text drawInRect:rect
          withAttributes:@{NSParagraphStyleAttributeName : priceParagraphStyle, NSFontAttributeName : font}];
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [text drawInRect:rect
                withFont:font
           lineBreakMode:NSLineBreakByTruncatingTail
               alignment:NSTextAlignmentLeft];
#pragma clang diagnostic pop
    }
}
@end
