//
//  BarChartViewController.m
//  SDLineChart
//
//  Created by 孙号斌 on 16/12/15.
//  Copyright © 2016年 孙号斌. All rights reserved.
//

#import "BarChartViewController.h"
#import "SDDBarChart.h"

@interface BarChartViewController ()
@property (nonatomic, strong) SDDBarChart *barChart;
@end

@implementation BarChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    BarPropertyData *bar1 = [[BarPropertyData alloc]init];
    BarPropertyData *bar2 = [[BarPropertyData alloc]init];
    bar2.barColor = [UIColor colorWithRed:237/255.0 green:186/255.0 blue:63/255.0 alpha:1];
    bar2.textColor = [UIColor redColor];
    
    _barChart = [[SDDBarChart alloc]initWithFrame:CGRectMake(0, 80, self.view.bounds.size.width, 300)];
//    _barChart.showXAxis = NO;
    _barChart.showYAxis = NO;
//    _barChart.showYGridLines = NO;
    _barChart.yGridLinesStyle = SDDBarChartGridLinesStyleDefault;
//    _barChart.showYLabel = NO;
//    _barChart.xUnit = @"号";
//    _barChart.yUnit = @"次数";
//    _barChart.groupSpace = 35;
    _barChart.barWidth = 35;
    _barChart.itemSpace = -35;
    _barChart.itemNumOfGroup = 1;
    _barChart.barProperties = @[bar1,bar2];
    [self.view addSubview:_barChart];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)show:(UIButton *)sender
{
    _barChart.yLabels = @[@"0",@"5",@"10",@"15",@"20",@"25",];
    _barChart.xLabels = @[@"01号",@"02号",@"03号"];
    _barChart.yMaxNum = 25.0f;
    
    _barChart.barData = @[@14,@12, @17];
    [_barChart show];
}

@end
