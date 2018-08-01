/***************************************************************************
 *版权所有 ©2016 陕西深度网络科技有限公司
 *
 *文件名称： SDDBarChart
 *内容摘要： 柱状图
 *其他说明： 改进点：1、加入颜色的书名
 *当前版本： 1.0.0
 *作   者： 孙号斌
 *完成日期： 2016年12月14日
 
 *修改记录1： <#修改历史记录#>
 *    修改日期： <##>
 *    版 本 号： <##>
 *    修 改 人： <##>
 *    修改内容： <#修改原因以及修改内容说明#>
 *修改记录2：...
 *
 ***************************************************************************/

#import <UIKit/UIKit.h>


@class BarPropertyData;

typedef NS_ENUM(NSUInteger, SDDBarChartGridLinesStyle) {
    SDDBarChartGridLinesStyleDefault = 0,          //虚线
    SDDBarChartGridLinesStyleFullLine = 1,         //实线
};


@interface SDDBarChart : UIView

@property (nonatomic, assign) UIEdgeInsets chartMargin;// 中间图标区域(不包含坐标轴)的边距


/*************** 坐标轴刻度 ***************/
@property (nonatomic, assign) BOOL      showYLabel;
@property (nonatomic, assign) BOOL      showXLabel;

@property (nonatomic, strong) UIFont    *xLabelFont;            //x轴坐标的刻度字体大小
@property (nonatomic, strong) UIColor   *xLabelColor;           //x轴坐标的刻度字体颜色

@property (nonatomic, strong) UIFont    *yLabelFont;            //y轴坐标的刻度字体大小
@property (nonatomic, strong) UIColor   *yLabelColor;           //y轴坐标的刻度字体颜色

/*************** 坐标轴 ***************/
@property (nonatomic, assign) BOOL      showYAxis;
@property (nonatomic, assign) BOOL      showXAxis;

@property (nonatomic, strong) UIColor   *axisColor;             //坐标轴颜色
@property (nonatomic, assign) CGFloat   axisWidth;              //坐标轴宽度

@property (nonatomic, copy )  NSString  *xUnit;                 //x轴单位
@property (nonatomic, copy )  NSString  *yUnit;                 //y轴单位

/*************** 网格线 ***************/
@property (nonatomic, assign) BOOL      showYGridLines;         //是否显示Y轴网格线
@property (nonatomic, strong) UIColor   *yGridLinesColor;       //与Y轴垂直网格线的颜色
@property (nonatomic, assign) SDDBarChartGridLinesStyle yGridLinesStyle;


/*************** 柱状的属性 ***************/
@property (nonatomic, assign) NSInteger itemNumOfGroup;         //每组中item的个数
@property (nonatomic, strong) NSArray<BarPropertyData *> *barProperties;
@property (nonatomic, assign) CGFloat   groupSpace;             //大的分组的间距
@property (nonatomic, assign) CGFloat   itemSpace;              //单个组内的每个 item 间距
@property (nonatomic, assign) CGFloat   barWidth;

@property (nonatomic, assign) BOOL      showNumber;             // 柱形顶部是否显示数值

/*************** 数据 ***************/
@property (nonatomic, strong) NSArray<NSString *> *xLabels;
@property (nonatomic, strong) NSArray<NSString *> *yLabels;
@property (nonatomic, assign) CGFloat yMaxNum;//y 轴最大值
@property (nonatomic, strong) NSArray<NSNumber *> *barData;

- (void)show;

@end


@interface BarPropertyData : NSObject
@property (nonatomic, strong) UIColor   *barColor;
@property (nonatomic, strong) UIColor   *textColor;
@property (nonatomic, strong) UIFont    *textFont;

@end












