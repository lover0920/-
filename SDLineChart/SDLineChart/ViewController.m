//
//  ViewController.m
//  SDLineChart
//
//  Created by 孙号斌 on 16/10/9.
//  Copyright © 2016年 孙号斌. All rights reserved.
//

#import "ViewController.h"
#import "SDDLineChart.h"

@interface ViewController ()
@property (nonatomic, strong) SDDLineChart *lineChart;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor purpleColor];
    
    _lineChart = [[SDDLineChart alloc]initWithFrame:CGRectMake(0, 80, self.view.bounds.size.width, 300)];
    _lineChart.xUnit = @"期数";
    _lineChart.yUnit = @"号";
    _lineChart.yGridLinesStyle = SDDLineChartGridLinesStyleDefault;
    [self.view addSubview:_lineChart];
    
    [self addCoordinate:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addCoordinate:(UIButton *)sender
{
    _lineChart.yValueMax = 10;
    _lineChart.yValueMin = 1;
    [_lineChart setXLables:@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19"]
                   yLables:@[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"]];
}

- (IBAction)addData:(UIButton *)sender
{
    _lineChart.centerLabels = @[@"2.12期",@"5.7期",@"1期",@"2期",@"4期",@"1期",
                                @"6.5期",@"2期",@"1.5期",@"2期",@"2.12期",@"5.7期",
                                @"1期",@"2期",@"4期",@"1期",@"6.5期",@"2期",
                                @"1.5期",@"2期",@"2.12期",@"5.7期",@"1期",@"2期",
                                @"4期",@"1期",@"6.5期",@"2期",@"1.5期",@"2期",];
    [_lineChart addChartData:@[@"2.12",@"5.7",@"1",@"2",@"4",@"1",@"6.5",@"2",@"1.5",@"2",@"2.12",@"5.7",@"1",@"2",@"4",@"1",@"6.5",@"2",@"1.5",@"2",@"2.12",@"5.7",@"1",@"2",@"4",@"1",@"6.5",@"2",@"1.5",@"2",] chartDataProperty:[[SDDLineChartData alloc] init]];
    
}
- (IBAction)removeLine1:(UIButton *)sender
{
    [_lineChart removeChartDateWithLineTag:nil];
}








- (IBAction)changeData:(UIButton *)sender
{
    SDDLineChartData *lineChart = [[SDDLineChartData alloc]init];
    lineChart.lineTag = @"afdadfs";
    lineChart.lineColor = [UIColor blueColor];
    lineChart.inflexionPointStyle = SDDLineChartPointStyleTriangle;
    lineChart.inflexionPointColor = [UIColor blueColor];
    lineChart.inflexionPointWidth = 4.0f;
    lineChart.showPointLabel = YES;
    lineChart.pointLabelColor = [UIColor blueColor];
    
    [_lineChart addChartData:@[@"3.12",@"7",@"2",@"3",@"5",@"2",@"1",@"2.5",@"3.5",@"2.5",] chartDataProperty:lineChart];
}
- (IBAction)removeLine2:(UIButton *)sender
{
    [_lineChart removeChartDateWithLineTag:@"afdadfs"];
}


@end
