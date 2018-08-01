//
//  SDDLineChart.h
//  SDLineChart
//
//  Created by 孙号斌 on 16/10/9.
//  Copyright © 2016年 孙号斌. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


typedef NS_ENUM(NSUInteger, SDDLineChartPointStyle) {
    SDDLineChartPointStyleNone = 0,     //无
    SDDLineChartPointStyleCircle = 1,   //圆形
    SDDLineChartPointStyleSquare = 3,   //正方形
    SDDLineChartPointStyleTriangle = 4  //三角形
};

typedef NS_ENUM(NSUInteger, SDDLineChartGridLinesStyle) {
    SDDLineChartGridLinesStyleDefault = 0,          //虚线
    SDDLineChartGridLinesStyleFullLine = 1,         //实线
};



@class SDDLineChartData;

@interface SDDLineChart : UIView

/*************** 坐标轴刻度 ***************/
@property (nonatomic, assign) BOOL      showLabel;              //是否显示xy轴刻度

@property (nonatomic, strong) UIFont    *xLabelFont;            //x轴坐标的刻度字体大小
@property (nonatomic, strong) UIColor   *xLabelColor;           //x轴坐标的刻度字体颜色

@property (nonatomic, strong) UIFont    *yLabelFont;            //y轴坐标的刻度字体大小
@property (nonatomic, strong) UIColor   *yLabelColor;           //y轴坐标的刻度字体颜色


/*************** 坐标轴 ***************/
@property (nonatomic, getter = isShowCoordinateAxis) BOOL showCoordinateAxis;//是否显示坐标轴，默认NO
@property (nonatomic, strong) UIColor   *axisColor;             //坐标轴颜色
@property (nonatomic, assign) CGFloat   axisWidth;              //坐标轴宽度

@property (nonatomic, copy )  NSString  *xUnit;                 //x轴单位
@property (nonatomic, copy )  NSString  *yUnit;                 //y轴单位


/*************** 网格线 ***************/
@property (nonatomic, assign) BOOL      showXGridLines;         //是否显示Y轴网格线
@property (nonatomic, assign) BOOL      showYGridLines;         //是否显示Y轴网格线
@property (nonatomic, assign) SDDLineChartGridLinesStyle xGridLinesStyle;
@property (nonatomic, assign) SDDLineChartGridLinesStyle yGridLinesStyle;
@property (nonatomic, strong) UIColor   *xGridLinesColor;       //与X轴垂直网格线的颜色
@property (nonatomic, strong) UIColor   *yGridLinesColor;       //与Y轴垂直网格线的颜色


/*************** 坐标轴相关的距离 ***************/
@property (nonatomic, assign) CGFloat   chartMarginLeft;        //Y轴距self左边距
@property (nonatomic, assign) CGFloat   chartMarginRight;       //X轴最大值距self的右边距
@property (nonatomic, assign) CGFloat   chartMarginUp;          //Y轴最大值距self的上边距
@property (nonatomic, assign) CGFloat   chartMarginBottom;      //X轴距self下边距

@property (nonatomic, assign) CGFloat   xStepWidth;             //x轴坐标的刻度宽
@property (nonatomic, assign) CGFloat   firstGridLineWidth;




/*************** 数据 ***************/
@property (nonatomic, assign) CGFloat   yValueMax;              //y最大值
@property (nonatomic, assign) CGFloat   yValueMin;              //y最小值


- (void)setXLables:(NSArray *)xLabels yLables:(NSArray *)yLabels;
@property (nonatomic, strong) NSArray *centerLabels;

- (void)addChartData:(NSArray *)chartData chartDataProperty:(SDDLineChartData *)dataProperty;
- (void)removeChartDateWithLineTag:(NSString *)lineTag;

@end



@interface SDDLineChartData : NSObject
@property (nonatomic, copy) NSString    *lineTag;           //key

/*************** 线的属性 ***************/
@property (nonatomic, strong) UIColor   *lineColor;         //线的颜色
@property (nonatomic, assign) CGFloat   lineWidth;          //线的宽度

/*************** 拐点Label的属性 ***************/
@property (nonatomic, assign) BOOL      showPointLabel;     //是否显示拐点文字
@property (nonatomic, strong) UIColor   *pointLabelColor;   //拐点文字颜色
@property (nonatomic, strong) UIFont    *pointLabelFont;    //拐点文字大小

/*************** 拐点的属性 ***************/
@property (nonatomic, assign) SDDLineChartPointStyle inflexionPointStyle;   //拐点类型
@property (nonatomic, strong) UIColor   *inflexionPointColor;               //拐点颜色
/**
 * If PNLineChartPointStyle is circle, this returns the circle's diameter.
 * If PNLineChartPointStyle is square, each point is a square with each side equal in length to this value.
 */
@property (nonatomic, assign) CGFloat   inflexionPointWidth;    //拐点宽

- (instancetype)initWithLineTag:(NSString *)lineTage;

@end
