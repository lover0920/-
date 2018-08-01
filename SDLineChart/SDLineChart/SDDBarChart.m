//
//  SDDBarChart.m
//  SDLineChart
//
//  Created by 孙号斌 on 16/12/14.
//  Copyright © 2016年 孙号斌. All rights reserved.
//

#import "SDDBarChart.h"

#define IOS7_OR_LATER   [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0
#define SELF_WIDTH      self.frame.size.width
#define SELF_HEIGHT     self.frame.size.height

#define UNIT_FONT       [UIFont systemFontOfSize:12]
#define UNIT_COLOR      [UIColor grayColor]

#define RGBA(r,g,b,a)                   ([UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a])


@interface SDDBarChart ()<CALayerDelegate>
@property (nonatomic, strong) UIScrollView  *scrollView;
@property (nonatomic, strong) UIView        *yAxisView;

@property (nonatomic, assign) CGFloat       yStepHeight;
@property (nonatomic, assign) NSInteger     yLabelNum;              //yLabel个数

@property (nonatomic, strong) NSMutableArray *yAxisLabelFrames;
@property (nonatomic, strong) NSMutableArray *xAxisLabelFrames;
@property (nonatomic, strong) NSMutableArray *barPositions;


@property (nonatomic, strong) NSMutableArray *xCoordinateAxisLayers;//x坐标轴
@property (nonatomic, strong) NSMutableArray *yCoordinateAxisLayers;//x坐标轴
@property (nonatomic, strong) NSMutableArray *yAxisLabelLayers;     //y坐标轴文字
@property (nonatomic, strong) NSMutableArray *xAxisLabelLayers;     //x坐标轴文字

@property (nonatomic, strong) NSMutableArray *yGridLinesArray;

@property (nonatomic, strong) NSMutableArray *barLayerArray;
@property (nonatomic, strong) NSMutableArray *barTextLayerArray;

@end

@implementation SDDBarChart
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
    _chartMargin = UIEdgeInsetsMake(30, 35, 20, 30);
    /*************** 坐标轴 ***************/
    _showXAxis = YES;
    _showYAxis = YES;
    
    _axisColor = RGBA(127, 127, 127, 1);
    _axisWidth = 1.0f;
    
    /*************** 坐标轴刻度 ***************/
    _showXLabel = YES;
    _showYLabel = YES;
    
    _yLabelFont = [UIFont systemFontOfSize:14];
    _yLabelColor = [UIColor grayColor];
    
    _xLabelFont = [UIFont systemFontOfSize:12];
    _xLabelColor = [UIColor grayColor];
    
    /*************** 网格线 ***************/
    _showYGridLines = YES;
    _yGridLinesColor = RGBA(200, 200, 200, 1);
    _yGridLinesStyle = SDDBarChartGridLinesStyleFullLine;

    
    /*************** 柱状的属性 ***************/
    _itemNumOfGroup = 1;
    _groupSpace = 20.0f;
    _itemSpace = 0.0f;
    _barWidth = 20.0f;
    
    _showNumber = YES;
    
    BarPropertyData *barPropertyData = [[BarPropertyData alloc]init];
    _barProperties = @[barPropertyData];
    
    
    
    /*************** 初始化数组 ***************/
    _yAxisLabelFrames = [NSMutableArray array];
    _xAxisLabelFrames = [NSMutableArray array];
    _barPositions = [NSMutableArray array];
    
    _xCoordinateAxisLayers = [NSMutableArray array];
    _yCoordinateAxisLayers = [NSMutableArray array];
    
    _yAxisLabelLayers = [NSMutableArray array];
    _xAxisLabelLayers = [NSMutableArray array];
    
    _yGridLinesArray = [NSMutableArray array];
    _barLayerArray = [NSMutableArray array];
    _barTextLayerArray = [NSMutableArray array];
}
- (void)createUI
{
    self.backgroundColor = [UIColor whiteColor];
    
    /*************** 创建滚动视图 ***************/
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(_chartMargin.left+_axisWidth,  0,
                                                                SELF_WIDTH-_chartMargin.right-_axisWidth,
                                                                SELF_HEIGHT)];
    _scrollView.contentSize = _scrollView.frame.size;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.bounces = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];
    
    /*************** 创建Y轴的View ***************/
    _yAxisView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _chartMargin.left+3, SELF_HEIGHT)];
    _yAxisView.backgroundColor = [UIColor clearColor];
    [self addSubview:_yAxisView];
}

- (void)setYLabels:(NSArray<NSString *> *)yLabels
{
    _yLabels = yLabels;
    _yLabelNum = yLabels.count;
}



- (void)show
{
    [self calculatePosition];
    [self drawBarChart];
    
}


#pragma mark - 计算坐标
- (void)calculatePosition
{
    /*************** 计算Y轴label位置 ***************/
    if (_yLabels.count != 0)
    {
        [_yAxisLabelFrames removeAllObjects];
        
        CGFloat yTextHeight = [SDDBarChart sizeOfString:@"20" withWidth:MAXFLOAT font:_yLabelFont].height;
        CGFloat yInterval = (SELF_HEIGHT - _chartMargin.top - _chartMargin.bottom - _axisWidth) / (_yLabels.count - 1);
        _yStepHeight = yInterval;
        CGFloat textOriginY = 0.0f;
        for (NSInteger i = 0; i < _yLabels.count; i++)
        {
            textOriginY = SELF_HEIGHT - _chartMargin.bottom - yTextHeight/2 - yInterval * i;
            CGRect rect = CGRectMake(0, textOriginY, _chartMargin.left, yTextHeight);
            [_yAxisLabelFrames addObject:[NSValue valueWithCGRect:rect]];
        }
    }
    
    /*************** 计算X轴Label的位置 ***************/
    NSInteger xCount = _xLabels.count;
    if (xCount != 0)
    {
        [_xAxisLabelFrames removeAllObjects];
        
        CGFloat xGroupWidth = _barWidth * _itemNumOfGroup + _itemSpace * (_itemNumOfGroup - 1);
        
        //自适应
        CGFloat totalWidth = (_groupSpace + xGroupWidth) * xCount + _groupSpace;
        CGFloat scrollViewWidth = _scrollView.bounds.size.width - _chartMargin.right;
        self.scrollView.contentSize = CGSizeMake(totalWidth + _chartMargin.right, SELF_HEIGHT);
        if (totalWidth < scrollViewWidth)
        {
            _groupSpace = (scrollViewWidth - xGroupWidth * xCount) / (xCount + 1);
            self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, SELF_HEIGHT);
        }
        
        //位置
        CGFloat centerLabelX = 0.0f;
        CGFloat labelWidth = 0.0f;
        for (NSInteger i = 0; i < xCount; i++)
        {
            centerLabelX = (_groupSpace + xGroupWidth) * (i+1) - xGroupWidth/2;
            labelWidth = [SDDBarChart sizeOfString:[_xLabels objectAtIndex:i]
                                         withWidth:MAXFLOAT
                                              font:_xLabelFont].width;
            CGRect rect = CGRectMake(centerLabelX-labelWidth/2,
                                     SELF_HEIGHT-_chartMargin.bottom,
                                     labelWidth,
                                     _chartMargin.bottom);
            [_xAxisLabelFrames addObject:[NSValue valueWithCGRect:rect]];
        }
    }
    
    /*************** 计算bar的起始点终止点的位置 ***************/
    if (_barData.count != 0)
    {
        [_barPositions removeAllObjects];
        
        CGFloat xGroupWidth = _barWidth * _itemNumOfGroup + _itemSpace * (_itemNumOfGroup - 1);
        
        
        NSInteger group = 0;
        NSInteger item = 0;
        CGFloat startPointY = SELF_HEIGHT - _chartMargin.bottom - _axisWidth;
        
        for (NSInteger i = 0; i < _barData.count; i++)
        {
            group = i / _itemNumOfGroup;
            item = i % _itemNumOfGroup;
            
            //开始点坐标
            CGFloat x = _groupSpace*(group+1) + xGroupWidth*group + (_barWidth+_itemSpace)*item + _barWidth/2;
            NSValue *startPoint = [NSValue valueWithCGPoint:CGPointMake(x, startPointY)];
            
            //结束点坐标
            CGFloat barHeight = [[_barData objectAtIndex:i] floatValue] * (SELF_HEIGHT-_chartMargin.bottom-_chartMargin.top-_axisWidth) / _yMaxNum;
            CGFloat endPointY = SELF_HEIGHT - _chartMargin.bottom - _axisWidth - barHeight;
            NSValue *endPoint = [NSValue valueWithCGPoint:CGPointMake(x, endPointY)];
            
            //添加到数组中
            [_barPositions addObject:@{@"startPoint":startPoint,@"endPoint":endPoint}];
        }
    }
}

#pragma mark - 绘制barChart
- (void)drawBarChart
{
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:NO];

    
    /*************** 绘制坐标轴 ***************/
    if (_showXAxis)
    {
        for (CAShapeLayer *shapeLayer in _xCoordinateAxisLayers)
        {
            [shapeLayer removeFromSuperlayer];
        }
        //画X轴
        CGFloat pointY = SELF_HEIGHT-_chartMargin.bottom;
        CGFloat endPointX = _scrollView.contentSize.width-_chartMargin.right;
        
        [_xCoordinateAxisLayers addObject:[SDDBarChart drawLine:_scrollView
                                                       lineWidth:_axisWidth
                                                       lineColor:_axisColor
                                                      startPoint:CGPointMake(0, pointY)
                                                     interPoints:nil
                                                        endPoint:CGPointMake(endPointX, pointY)]];
        //画箭头
        NSArray *interPoints = [NSArray arrayWithObject:[NSValue valueWithCGPoint:CGPointMake(endPointX, pointY)]];
        [_xCoordinateAxisLayers addObject:[SDDBarChart drawLine:_scrollView
                                                       lineWidth:_axisWidth
                                                       lineColor:_axisColor
                                                      startPoint:CGPointMake(endPointX-6, pointY-3)
                                                     interPoints:interPoints
                                                        endPoint:CGPointMake(endPointX-6, pointY+3)]];
    }
    
    if (_showYAxis)
    {
        for (CAShapeLayer *shapeLayer in _yCoordinateAxisLayers)
        {
            [shapeLayer removeFromSuperlayer];
        }
        //画Y轴
        [_yCoordinateAxisLayers addObject:[SDDBarChart drawLine:_yAxisView
                                                      lineWidth:_axisWidth
                                                      lineColor:_axisColor
                                                     startPoint:CGPointMake(_chartMargin.left, 0)
                                                    interPoints:nil
                                                       endPoint:CGPointMake(_chartMargin.left, SELF_HEIGHT-_chartMargin.bottom)]];
        //画箭头
        [_yCoordinateAxisLayers addObject:[SDDBarChart drawLine:_yAxisView
                                                      lineWidth:_axisWidth
                                                      lineColor:_axisColor
                                                     startPoint:CGPointMake(_chartMargin.left-3, 6)
                                                    interPoints:[NSArray arrayWithObject:[NSValue valueWithCGPoint:CGPointMake(_chartMargin.left, 0)]]
                                                       endPoint:CGPointMake(_chartMargin.left+3, 6)]];
    }
    
    
    /*************** 绘制坐标轴label ***************/
    if (_showYLabel)
    {
        for (CATextLayer *textLayer in _yAxisLabelLayers)
        {
            [textLayer removeFromSuperlayer];
        }
        for (int i = 0; i < _yLabelNum; i++)
        {
            [_yAxisLabelLayers addObject:[SDDBarChart drawText:_yAxisView
                                                         frame:[[_yAxisLabelFrames objectAtIndex:i] CGRectValue]
                                                          text:[_yLabels objectAtIndex:i]
                                                     textColor:_yLabelColor
                                                          font:_yLabelFont]];
        }
    }
    if (_showXLabel)
    {
        for (CATextLayer *textLayer in _xAxisLabelLayers)
        {
            [textLayer removeFromSuperlayer];
        }
        
        for (int i = 0; i < _xLabels.count; i++)
        {
            
            [_xAxisLabelLayers addObject:[SDDBarChart drawText:_scrollView
                                                         frame:[[_xAxisLabelFrames objectAtIndex:i] CGRectValue]
                                                          text:[_xLabels objectAtIndex:i]
                                                     textColor:_xLabelColor
                                                          font:_xLabelFont]];
        }
    }
    
    
    /*************** 坐标轴单位 ***************/
    //y轴单位
    NSString *unit;
    if (_yUnit != nil)
    {
        unit = [NSString stringWithFormat:@"(%@)",_yUnit];
        CGSize textSize = [SDDBarChart sizeOfString:unit withWidth:100 font:UNIT_FONT];
        
        CGRect rect = CGRectMake(5, (_chartMargin.top-textSize.height)/2, textSize.width, textSize.height);
        [_xAxisLabelLayers addObject:[SDDBarChart drawText:_scrollView
                                                      frame:rect
                                                       text:unit
                                                  textColor:UNIT_COLOR
                                                       font:UNIT_FONT]];
        
    }
    //X轴单位
    if (_xUnit != nil)
    {
        unit = [NSString stringWithFormat:@"(%@)",_xUnit];
        CGSize textSize = [SDDBarChart sizeOfString:unit withWidth:100 font:UNIT_FONT];
        
        CGRect rect = CGRectMake(_scrollView.contentSize.width-_chartMargin.right-textSize.width, SELF_HEIGHT-_chartMargin.bottom-20, textSize.width, textSize.height);
        [_xAxisLabelLayers addObject:[SDDBarChart drawText:_scrollView
                                                      frame:rect
                                                       text:unit
                                                  textColor:UNIT_COLOR
                                                       font:UNIT_FONT]];
    }
    
    /*************** 画网格线 ***************/
    if (_showYGridLines)
    {
        for (CAShapeLayer *shapeLayer in _yGridLinesArray)
        {
            [shapeLayer removeFromSuperlayer];
        }
        
        if (_yGridLinesStyle == SDDBarChartGridLinesStyleDefault)
        {
            for (int i = 0; i < _yLabelNum-1; i++)
            {
                CGFloat y = i * _yStepHeight + _chartMargin.top;
                [_yGridLinesArray addObject:[SDDBarChart drawDashLine:_scrollView
                                                             lineWidth:0.5
                                                             lineColor:_yGridLinesColor
                                                          lineProperty:@[@6,@3]
                                                            startPoint:CGPointMake(0, y)
                                                              endPoint:CGPointMake(_scrollView.contentSize.width-_chartMargin.right, y)]];
            }
        }
        else
        {
            for (int i = 0; i < _yLabelNum-1; i++)
            {
                CGFloat y = i * _yStepHeight + _chartMargin.top;
                
                [_yGridLinesArray addObject:[SDDBarChart drawLine:_scrollView
                                                         lineWidth:0.5
                                                         lineColor:_yGridLinesColor
                                                        startPoint:CGPointMake(0, y)
                                                       interPoints:nil
                                                          endPoint:CGPointMake(_scrollView.contentSize.width-_chartMargin.right, y)]];
            }
        }
    }
    
    /*************** 绘制Bar ***************/
    for (CAShapeLayer *pathLayer in _barLayerArray)
    {
        [pathLayer removeFromSuperlayer];
    }
    
    for (CATextLayer *textLayer in _barTextLayerArray)
    {
        [textLayer removeFromSuperlayer];
    }
    
    
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointZero;
    CGSize textsize = CGSizeZero;
    CGRect textRect = CGRectZero;
    BOOL mutilBarPropeties = _barProperties.count < _itemNumOfGroup;
    for (int i = 0; i < _barData.count; i++)
    {
        BarPropertyData *barProperty = [[BarPropertyData alloc]init];
        if (mutilBarPropeties)
        {
            barProperty = [[BarPropertyData alloc]init];
        }
        else
        {
            barProperty = [_barProperties objectAtIndex:i%_itemNumOfGroup];
        }
        
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        basicAnimation.duration = 1.0;
        basicAnimation.fromValue = [NSNumber numberWithFloat:0.0];
        basicAnimation.toValue = [NSNumber numberWithFloat:1.0];
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        startPoint = [[[_barPositions objectAtIndex:i] objectForKey:@"startPoint"] CGPointValue];
        endPoint = [[[_barPositions objectAtIndex:i] objectForKey:@"endPoint"] CGPointValue];
        
        NSLog(@"endPointX:%f   endPointY:%f",endPoint.x,endPoint.y);
        [path moveToPoint:startPoint];
        [path addLineToPoint:endPoint];
        
        CAShapeLayer *pathLayer = [CAShapeLayer layer];
        pathLayer.frame = _scrollView.bounds;
        pathLayer.path = path.CGPath;
        pathLayer.strokeColor = barProperty.barColor.CGColor;
        pathLayer.lineWidth = _barWidth;
        pathLayer.lineJoin = kCALineJoinBevel;
        [pathLayer addAnimation:basicAnimation forKey:@"strokeEnd"];
        
        [_scrollView.layer addSublayer:pathLayer];
        [_barLayerArray addObject:pathLayer];

        
        if (_showNumber)
        {
            
            CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            fadeAnimation.fromValue = [NSNumber numberWithFloat:0.0];
            fadeAnimation.toValue = [NSNumber numberWithFloat:1.0];
            fadeAnimation.duration = 1.0;
            
            NSString *barString = [NSString stringWithFormat:@"%@",[_barData objectAtIndex:i]];
            textsize = [SDDBarChart sizeOfString:barString
                                       withWidth:MAXFLOAT
                                            font:barProperty.textFont];

            textRect = CGRectMake(startPoint.x-textsize.width/2,
                                  endPoint.y-textsize.height,
                                  textsize.width,
                                  textsize.height);
            
            CATextLayer *textLayer = [SDDBarChart drawText:_scrollView
                                                     frame:textRect
                                                      text:barString
                                                 textColor:barProperty.textColor
                                                      font:barProperty.textFont];
            [textLayer addAnimation:fadeAnimation forKey:nil];
            
            [_barTextLayerArray addObject:textLayer];
        }
    }
    
    
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
//    [textLayer setTruncationMode:kCATruncationEnd];                 //如何将字符串截断以适应图层大小
    
    
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


@end



#pragma mark -
#pragma mark - BarPropertyData
#pragma mark -
@implementation BarPropertyData

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.textColor = [UIColor blackColor];
        self.textFont = [UIFont systemFontOfSize:12];
        self.barColor = [UIColor colorWithRed:253/255.0 green:237/255.0 blue:204/255.0 alpha:1];
    }
    return self;
}

@end
